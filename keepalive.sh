#!/bin/bash
# keepalive.sh - restart rclonetest.sh automatically if it exits

SCRIPT_PATH="/.../rclonetest.sh"
LOGFILE="/volume2/rclone_keepalive.log"
RESTART_DELAY=30

echo "=== Starting keepalive for rclone script ==="
echo "Logging to: $LOGFILE"

while true; do
    echo "[$(date)] Starting rclone sync..." | tee -a "$LOGFILE"
    source "$SCRIPT_PATH" 2>&1 | tee -a "$LOGFILE"
    EXIT_CODE=${PIPESTATUS[0]}
    echo "[$(date)] rclone exited with code $EXIT_CODE" | tee -a "$LOGFILE"
    echo "Sleeping $RESTART_DELAY seconds before restart..." | tee -a "$LOGFILE"
    sleep "$RESTART_DELAY"
done
