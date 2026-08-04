FROM alpine:3.21

# Install rclone
RUN apk add --no-cache rclone bash

# Create app directory
WORKDIR /app

# Copy scripts
COPY sync.sh utils.sh /app/
RUN chmod +x /app/sync.sh

# Rclone config will be mounted at /config
# Sync destination will be mounted at /sync

ENV RCLONE_CONFIG=/config/rclone.conf
ENV RCLONE_SYNC_PATH=/sync
ENV RCLONE_REMOTE=gdrive:
ENV POLL_INTERVAL=60

ENTRYPOINT ["/app/sync.sh"]
