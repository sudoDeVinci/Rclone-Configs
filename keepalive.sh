#!/bin/bash
# keepalive.sh - restart rclonetest.sh automatically if it exits

source utils.sh

# Check if we're already running the script
if pgrep -f "$MANAGER_FILE" > /dev/null 2>&1; then
    echo "Keepalive script already running. Exiting."
    exit 0
fi

echo "=== Starting keepalive for rclone script ==="
echo "Logging to: $LOG_PATH"

while true; do
    echo "[$(date)] Starting rclone sync..." | tee -a "$LOG_PATH"
    source "$SCRIPT_PATH" 2>&1 | tee -a "$LOG_PATH"
    EXIT_CODE=${PIPESTATUS[0]}
    echo "[$(date)] rclone exited with code $EXIT_CODE" | tee -a "$LOG_PATH"
    echo "Sleeping $RESTART_DELAY seconds before restart..." | tee -a "$LOG_PATH"
    sleep "$RESTART_DELAY"
done
