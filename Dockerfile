FROM python:3.11-slim

# Install cron and other necessary packages
RUN apt-get update && apt-get install -y \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install the package and its dependencies
RUN pip install -e . && \
    # Verify installation worked
    python -c "import spotify_to_tidal; print('Package imported successfully')" && \
    # Add the source directory to Python path for module execution
    echo 'export PYTHONPATH="/app/src:$PYTHONPATH"' >> /root/.bashrc

# Create config directory
RUN mkdir -p /config

# Create log directory for cron logs
RUN mkdir -p /var/log/spotify-to-tidal

# Create a script that will be called by cron
RUN echo '#!/bin/bash' > /app/run_sync.sh && \
    echo 'cd /app' >> /app/run_sync.sh && \
    echo 'export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"' >> /app/run_sync.sh && \
    echo 'export PYTHONPATH="/app/src:$PYTHONPATH"' >> /app/run_sync.sh && \
    echo '# Build command with optional --atmos flag' >> /app/run_sync.sh && \
    echo 'CMD="/usr/local/bin/python -m spotify_to_tidal --config /config/config.yml"' >> /app/run_sync.sh && \
    echo 'if [ "$ENABLE_ATMOS" = "true" ]; then' >> /app/run_sync.sh && \
    echo '  CMD="$CMD --atmos"' >> /app/run_sync.sh && \
    echo 'fi' >> /app/run_sync.sh && \
    echo 'echo "Running: $CMD"' >> /app/run_sync.sh && \
    echo '$CMD >> /var/log/spotify-to-tidal/sync.log 2>&1' >> /app/run_sync.sh && \
    chmod +x /app/run_sync.sh

# Environment variables
ENV CRON_SCHEDULE="0 2 * * *"
ENV ENABLE_ATMOS="false"

# Create entrypoint script
RUN echo '#!/bin/bash' > /app/entrypoint.sh && \
    echo 'set -e' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo '# Create crontab with the schedule from environment variable' >> /app/entrypoint.sh && \
    echo 'echo "$CRON_SCHEDULE /app/run_sync.sh" > /etc/cron.d/spotify-sync' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo '# Set proper permissions on crontab file' >> /app/entrypoint.sh && \
    echo 'chmod 0644 /etc/cron.d/spotify-sync' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo '# Apply cron job' >> /app/entrypoint.sh && \
    echo 'crontab /etc/cron.d/spotify-sync' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo '# Create the log file to be able to run tail' >> /app/entrypoint.sh && \
    echo 'touch /var/log/spotify-to-tidal/sync.log' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo 'echo "Cron job scheduled: $CRON_SCHEDULE"' >> /app/entrypoint.sh && \
    echo 'echo "Config will be read from: /config/config.yml"' >> /app/entrypoint.sh && \
    echo 'echo "Logs will be written to: /var/log/spotify-to-tidal/sync.log"' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo '# Start cron daemon' >> /app/entrypoint.sh && \
    echo 'cron' >> /app/entrypoint.sh && \
    echo '' >> /app/entrypoint.sh && \
    echo '# Keep the container running and tail the log file' >> /app/entrypoint.sh && \
    echo 'tail -f /var/log/spotify-to-tidal/sync.log' >> /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# Volume mount point for config
VOLUME ["/config"]

# Expose volume for logs (optional)
VOLUME ["/var/log/spotify-to-tidal"]

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"] 