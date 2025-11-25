# utils.sh - Utility functions and path configs for NAS-related scripts.

## Edit the variables below, according to your own environment:
#
NAS_HOST="192.168.1..."
NAS_USER="..."

VOLUME="/volume2"
LOG_FILE="clonetask.log"
LOG_PATH="${VOLUME}/${LOG_FILE}"


# RCLONE_SYNC_PATH: The LOCAL path to sync TO (files FROM remote will be synced here):
RCLONE_SYNC_PATH="${VOLUME}/..."

# RCLONE_REMOTE: The rclone remote name to synchronize FROM.
# Identical to one of the remote names listed via `rclone listremotes`.
# Include the remote folder path after the colon, e.g., "gdrive:MyFolder"
# (ALL CONTENTS of the local directory are continuously DELETED
#  and replaced with the contents FROM RCLONE_REMOTE)
RCLONE_REMOTE="..."

# POLL_INTERVAL: How often to check for remote changes (in seconds):
# Set lower for more responsive syncing, higher to reduce API calls
POLL_INTERVAL=60

# SYNC_DELAY: Wait this many seconds after an event, before synchronizing:
SYNC_DELAY=5

# SYNC_INTERVAL: Wait this many seconds between forced synchronizations:
SYNC_INTERVAL=36000

# RESTART_DELAY: The delay in seconds before restarting the sync.sh script after a failure.
RESTART_DELAY=30
