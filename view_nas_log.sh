#!/bin/bash
# view_nas_log.sh - View rclone keepalive logs from NAS via SSH

source utils.sh

## Usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --follow    Follow log output in real-time (like tail -f)"
    echo "  -n, --lines N   Show last N lines (default: all)"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Show entire log"
    echo "  $0 -n 50        # Show last 50 lines"
    echo "  $0 -f           # Follow log in real-time"
    echo ""
    echo "Note: You will be prompted for the password for ${NAS_USER}@${NAS_HOST}"
}

## Parse command line arguments
FOLLOW=false
LINES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

## Build the remote command
if [ "$FOLLOW" = true ]; then
    REMOTE_CMD="tail -f ${LOG_PATH}"
    echo "Following log from ${NAS_USER}@${NAS_HOST}:${LOG_PATH}"
    echo "Press Ctrl+C to stop..."
    echo "----------------------------------------"
elif [ -n "$LINES" ]; then
    REMOTE_CMD="tail -n ${LINES} ${LOG_PATH}"
    echo "Showing last ${LINES} lines from ${NAS_USER}@${NAS_HOST}:${LOG_PATH}"
    echo "----------------------------------------"
else
    REMOTE_CMD="cat ${LOG_PATH}"
    echo "Showing full log from ${NAS_USER}@${NAS_HOST}:${LOG_PATH}"
    echo "----------------------------------------"
fi

## Execute SSH command
ssh ${NAS_USER}@${NAS_HOST} "${REMOTE_CMD}"

## Check for errors
if [ $? -ne 0 ]; then
    echo ""
    echo "Error: Failed to retrieve log from NAS"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Verify NAS is reachable: ping ${NAS_HOST}"
    echo "  2. Test SSH connection: ssh ${NAS_USER}@${NAS_HOST}"
    echo "  3. Verify log file exists: ssh ${NAS_USER}@${NAS_HOST} 'ls -l ${LOG_PATH}'"
    echo ""
    echo "Tip: Set up SSH key authentication to avoid password prompts:"
    echo "  ssh-copy-id ${NAS_USER}@${NAS_HOST}"
    exit 1
fi
