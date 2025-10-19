#!/bin/bash
## One-way, continuous, recursive, directory synchronization
##  FROM a remote Rclone URL to local storage (Google Drive, S3, SFTP, etc.)
## Optional desktop notifications on sync events or errors.
## Uses polling to check for remote changes (no inotify needed for remote).
## Think use-case: Sync Google Drive changes to NAS storage
## Think use-case: Pull remote backups to local storage
## Think use-case: Mirror cloud storage to local server

## Setup: Install `rclone` from package manager (inotify-tools not needed).
## Run: `rclone config` to setup the remote, including the full remote
##   subdirectory path to sync FROM.
## MAKE SURE that the local directory (RCLONE_SYNC_PATH) exists or
##   will be created - ALL CONTENTS will be replaced with remote contents.
## If unsure, add `--dry-run` to the RCLONE_CMD variable below,
##   to simulate what would be copied/deleted.
## Enable your user for Systemd Linger: sudo loginctl enable-linger $USER
## (Reference https://wiki.archlinux.org/title/Systemd/User#Automatic_start-up_of_systemd_user_instances)
## Copy this script any place on your filesystem, and make it executable: `chmod +x sync.sh`
## Edit all the variables below, before running the script.
## Run: `./sync.sh systemd_setup` to create and enable systemd service.
## Run: `journalctl --user --unit rclone_sync_from_remote` to view the logs.
## For desktop notifications, make sure you have installed a notification daemon (eg. dunst)

source utils.sh

# Check if we're already running the script
if pgrep -f "$SCRIPT_FILE" > /dev/null 2>&1; then
    echo "Sync Script already running. Exiting."
    exit 0
fi

# RCLONE_CMD: The sync command and arguments:
## (This syncs FROM remote TO local - reversed from original script):
## (Consider using other modes like `bisync` for two-way sync [see `man rclone` for details]):
RCLONE_CMD="rclone -v sync ${RCLONE_REMOTE} ${RCLONE_SYNC_PATH}"

# WATCH_EVENTS: Not used in polling mode (kept for compatibility)
WATCH_EVENTS="modify,delete,create,move"

# NOTIFY_ENABLE: Enable Desktop notifications (set to false for NAS/headless servers)
NOTIFY_ENABLE=false

# SYNC_SCRIPT: dynamic reference to the current script path
SYNC_SCRIPT=$(realpath $0)

notify() {
    MESSAGE=$1
    if test ${NOTIFY_ENABLE} = "true"; then
        notify-send "rclone ${RCLONE_REMOTE}" "${MESSAGE}"
    fi
}

rclone_sync() {
    set -x
    # Do initial sync immediately:
    notify "Startup - syncing from remote"
    ${RCLONE_CMD}
    # Poll for remote changes at regular intervals:
    while [[ true ]] ; do
        echo "Waiting ${POLL_INTERVAL} seconds before next sync check..."
        sleep ${POLL_INTERVAL}

        # Check if there are changes using rclone check
        echo "Checking for remote changes..."
        if ! rclone check ${RCLONE_REMOTE} ${RCLONE_SYNC_PATH} --one-way --quiet 2>/dev/null; then
            echo "Changes detected, syncing..."
            if ${RCLONE_CMD}; then
                notify "Synchronized new changes from remote"
                echo "Sync completed successfully"
            else
                notify "Sync failed - check logs"
                echo "Sync failed with exit code $?"
            fi
        else
            echo "No changes detected"
        fi
    done
}

systemd_setup() {
    set -x
    if loginctl show-user ${USER} | grep "Linger=no"; then
	    echo "User account does not allow systemd Linger."
	    echo "To enable lingering, run as root: loginctl enable-linger $USER"
	    echo "Then try running this command again."
	    exit 1
    fi
    mkdir -p ${HOME}/.config/systemd/user

    # Remove special characters from remote name
    SAFE_REMOTE_NAME=$(echo "${RCLONE_REMOTE}" | sed 's/[^a-zA-Z0-9_-]/_/g')
    SERVICE_FILE=${HOME}/.config/systemd/user/rclone_sync_from_${SAFE_REMOTE_NAME}.service

    if test -f ${SERVICE_FILE}; then
	    echo "Unit file already exists: ${SERVICE_FILE} - Not overwriting."
    else
	    cat <<EOF > ${SERVICE_FILE}
[Unit]
Description=rclone sync FROM ${RCLONE_REMOTE} TO ${RCLONE_SYNC_PATH}

[Service]
ExecStart=${SYNC_SCRIPT}
Restart=on-failure
RestartSec=30

[Install]
WantedBy=default.target
EOF
    fi
    systemctl --user daemon-reload
    systemctl --user enable --now rclone_sync_from_${SAFE_REMOTE_NAME}
    systemctl --user status rclone_sync_from_${SAFE_REMOTE_NAME}
    echo "You can watch the logs with this command:"
    echo "   journalctl --user --unit rclone_sync_from_${SAFE_REMOTE_NAME} -f"
}

if test $# = 0; then
    rclone_sync
else
    CMD=$1; shift;
    ${CMD} $@
fi
