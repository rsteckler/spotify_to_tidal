# Docker Setup for Spotify to Tidal Sync

This Docker setup allows you to run the Spotify to Tidal sync application on a scheduled basis using cron.

## Features

- **Scheduled execution**: Uses cron to run the sync on a configurable schedule
- **Environment variable configuration**: Set your cron schedule via `CRON_SCHEDULE` environment variable
- **Volume mounting**: Mount your `config.yml` from the host filesystem
- **Persistent logging**: Logs are stored in a volume for easy access
- **Automatic restart**: Container restarts automatically unless manually stopped

## Quick Start

### 1. Prepare your configuration

Ensure your `config.yml` file is in the project root directory:

```bash
# Make sure your config.yml is in the project root
ls config.yml
# If not, copy it there
cp your_existing_config.yml config.yml
```

### 2. Build and run with Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### 3. Alternative: Run with Docker directly

```bash
# Build the image
docker build -t spotify-to-tidal .

# Run the container
docker run -d \
  --name spotify-to-tidal-sync \
  -e CRON_SCHEDULE="0 2 * * *" \
  -e ENABLE_ATMOS="false" \
  -v $(pwd):/config \
  -v $(pwd)/logs:/var/log/spotify-to-tidal \
  --restart unless-stopped \
  spotify-to-tidal
```

## Configuration

### Cron Schedule

Set the `CRON_SCHEDULE` environment variable to control when the sync runs. The format is:

```
minute hour day_of_month month day_of_week
```

**Examples:**
- `"0 2 * * *"` - Daily at 2 AM (default)
- `"0 */6 * * *"` - Every 6 hours
- `"0 8,20 * * *"` - Twice daily at 8 AM and 8 PM
- `"0 2 * * 0"` - Weekly on Sunday at 2 AM
- `"*/30 * * * *"` - Every 30 minutes

### Dolby Atmos Support

Set the `ENABLE_ATMOS` environment variable to `"true"` to prefer Dolby Atmos tracks when available during sync:

- `"false"` - Standard sync without Atmos preference (default)
- `"true"` - Prefer Dolby Atmos tracks when available

### Volumes

- `/config` - Mount your entire project directory to persist `config.yml`, cache files, and other application state
- `/var/log/spotify-to-tidal` - Log files (optional, for persistence)

### Config File

Your `config.yml` should follow the same format as described in the main README. The container will look for it at `/config/config.yml`. Additionally, any cache files, databases, or other persistent state will be stored in the same mounted directory.

## Monitoring

### View logs

```bash
# With docker-compose
docker-compose logs -f

# With docker directly
docker logs -f spotify-to-tidal-sync

# View sync logs specifically
tail -f logs/sync.log
```

### Check cron status

```bash
# Access the container
docker exec -it spotify-to-tidal-sync bash

# View crontab
crontab -l

# Check if cron is running
ps aux | grep cron
```

## Troubleshooting

### Container stops immediately
- Check that your `config.yml` file exists in the project root directory
- Verify the cron schedule format is correct
- Check container logs: `docker logs spotify-to-tidal-sync`

### Sync not running
- Verify the cron schedule is what you expect
- Check if the time zone in the container matches your expectations
- Look at the sync logs for any errors

### Permission issues
- Ensure the project directory and files are readable/writable by the container
- The container runs as root, so file permissions should not be an issue
- Make sure the project directory has write permissions for cache and state files

## Timezone

By default, the container uses UTC time. To set a specific timezone, uncomment and modify the timezone environment variable in `docker-compose.yml`:

```yaml
environment:
  - TZ=America/New_York
  - CRON_SCHEDULE=0 2 * * *
  - ENABLE_ATMOS=true
```

## Security Notes

- The project directory is mounted with read-write access to allow cache and state persistence
- Logs are written to a separate volume to avoid permission issues
- Consider using Docker secrets for sensitive configuration in production environments
- Be aware that the entire project directory is accessible from within the container 