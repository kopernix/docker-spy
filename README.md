# docker-spy

A lightweight Bash script to collect system metrics, disk usage, and Docker container states, saving the results as CSV files.

## Requirements

- Bash shell
- `docker` CLI installed and user with appropriate permissions
- `awk`, `df`, `free`, `uname`, and standard coreutils

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/kopernix/docker-spy.git
   cd docker-spy
   ```

2. Make the script executable:
   ```bash
   chmod +x docker_spy.sh
   ```

## Usage

Run the script:
```bash
./docker_spy.sh
```

- **Disk usage** will be saved to `logs/disk_usage_<YYYYMMDD_HHMMSS>.csv`.
- **Docker container state** will be saved to `logs/containers_<YYYYMMDD_HHMMSS>.csv`.
- **System metrics** (date/time, uptime, load average, CPU usage, RAM usage, CPU cores, total memory) will be saved to `logs/system_metrics_<YYYYMMDD_HHMMSS>.csv`.

You can set up a cron job to run this script daily or horly:
Change logs location LOG_DIR 

```bash
# Edit the root crontab:
sudo crontab -e

# Add a line to run at 00:05 every day:
5 0 * * * /path/to/docker-spy/docker_spy.sh
```
or place it on your cron.hourly

```bash
sudo cp docker_spy.sh /etc/cron.hourly/
sudo chown root:root /etc/cron.hourly/docker_spy.sh
sudo chmod +x /etc/cron.hourly/docker_spy.sh

```

Logrotate.d config:

```bash
sudo cp config/logrotate-docker-spy /etc/logrotate.d/logrotate-docker-spy
sudo chown root:root /etc/logrotate.d/logrotate-docker-spy
```



