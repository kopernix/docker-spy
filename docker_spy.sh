#!/usr/bin/env bash

# =================================================================
# docker_spy.sh
#
# https://github.com/kopernix/docker-spy
#
# Description:
#   Collects system metrics, disk usage, and Docker container states,
#   and saves the results as CSV files in the logs/ directory.
#
# Usage:
#   ./docker_spy.sh
#
# Requirements:
#   - Docker CLI accessible by the user running this script
#   - awk, df, free, uname, uptime commands
# =================================================================

# Directory to store log files
LOG_DIR="docker-spy-logs"
# LOG_DIR="/var/log/docker-spy-logs"

# Ensure log directory exists
ensure_log_dir() {
  if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
  fi
}

# Get current timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")

# Collect system metrics and save to CSV
collect_system_metrics() {
  local metrics_file="$LOG_DIR/system_metrics_${timestamp}.csv"
  echo "metric_name,metric_value" > "$metrics_file"

  # Date and time
  echo "date_time,$(date +'%Y-%m-%d %H:%M:%S')" >> "$metrics_file"

  # Uptime
  echo "uptime,"$(uptime -p)"" >> "$metrics_file"

  # Load average
  read load1 load5 load15 _ < /proc/loadavg
  echo "load_1min,$load1" >> "$metrics_file"
  echo "load_5min,$load5" >> "$metrics_file"
  echo "load_15min,$load15" >> "$metrics_file"

  # CPU usage (user, system, iowait) from top
  local cpu_line
  cpu_line=$(top -bn1 | grep "Cpu(s)")
  local cpu_us cpu_sy cpu_wa
  cpu_us=$(echo "$cpu_line" | awk -F',' '{print $1}' | sed 's/.*: *\([0-9.]*\) us/\1/')
  cpu_sy=$(echo "$cpu_line" | awk -F',' '{print $2}' | sed 's/ *\([0-9.]*\) sy.*/\1/')
  cpu_wa=$(echo "$cpu_line" | awk -F',' '{print $5}' | sed 's/ *\([0-9.]*\) wa.*/\1/')
  echo "cpu_user_percent,$cpu_us" >> "$metrics_file"
  echo "cpu_system_percent,$cpu_sy" >> "$metrics_file"
  echo "cpu_iowait_percent,$cpu_wa" >> "$metrics_file"

  # RAM usage (total, used, free) in MB
  read mem_total mem_used mem_free _ < <(free -m | awk '/^Mem:/ {print $2, $3, $4}')
  echo "ram_total_MB,$mem_total" >> "$metrics_file"
  echo "ram_used_MB,$mem_used" >> "$metrics_file"
  echo "ram_free_MB,$mem_free" >> "$metrics_file"

  # CPU cores
  echo "cpu_cores,$(nproc)" >> "$metrics_file"

  # Total memory
  echo "memory_physical_total_MB,$mem_total" >> "$metrics_file"
}

# Collect disk usage and save to CSV
collect_disk_usage() {
  local disk_file="$LOG_DIR/disk_usage_${timestamp}.csv"
  echo "filesystem,total_size,used_size,available_size,use_percentage,mountpoint" > "$disk_file"
  df -P -B1M | awk 'NR>1 {print $1","$2","$3","$4","$5","$6}' >> "$disk_file"
}

# Collect Docker containers info and save to CSV
collect_docker_containers() {
  local containers_file="$LOG_DIR/containers_${timestamp}.csv"
  echo "container_id,image,command,created,status,ports,names" > "$containers_file"
  docker ps -a --format '"{{.ID}}","{{.Image}}","{{.Command}}","{{.RunningFor}}","{{.Status}}","{{.Ports}}","{{.Names}}"' >> "$containers_file" 2>/dev/null
}

# Main function
main() {
  ensure_log_dir
  collect_system_metrics
  collect_disk_usage
  collect_docker_containers
}

# Run main
main
