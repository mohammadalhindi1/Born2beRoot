#!/bin/bash

# Born2beRoot system monitoring report.
# Install as root and run from cron every 10 minutes.

arch=$(uname -a)

# CPU
cpuf=$(lscpu -p=Socket | grep -v '^#' | sort -u | wc -l)
cpuv=$(nproc)

# MEMORY
read -r ram_total ram_use ram_percent < <(
    free --mega | awk '/^Mem:/ {printf "%d %d %.2f", $2, $3, ($3 / $2) * 100}'
)

# DISK (real filesystems, excluding temporary pseudo-filesystems)
read -r disk_total disk_use disk_percent < <(
    df -BM --total -x tmpfs -x devtmpfs         | awk '/^total/ {
            total=$2; used=$3;
            gsub("M", "", total); gsub("M", "", used);
            printf "%.1fGB %dMB %d", total / 1024, used, (used / total) * 100
        }'
)

# CPU LOAD
cpu_idle=$(vmstat 1 2 | tail -1 | awk '{print $15}')
cpu_load=$(awk -v idle="$cpu_idle" 'BEGIN {printf "%.1f", 100 - idle}')

# SYSTEM
last_boot=$(who -b | awk '{print $3 " " $4}')
lvm_use=$(lsblk -o TYPE | grep -q lvm && echo yes || echo no)
tcp_connections=$(ss -Htan state established | wc -l)
logged_users=$(who | awk '{print $1}' | sort -u | wc -l)

# NETWORK
ip_address=$(hostname -I | awk '{print $1}')
mac_address=$(ip -o link | awk '$2 != "lo:" && /link\/ether/ {print $17; exit}')

# SUDO COMMANDS
sudo_commands=$(journalctl _COMM=sudo --no-pager 2>/dev/null | grep -c 'COMMAND=')

wall "Architecture: $arch
CPU physical: $cpuf
vCPU: $cpuv
Memory Usage: ${ram_use}/${ram_total}MB (${ram_percent}%)
Disk Usage: ${disk_use}/${disk_total} (${disk_percent}%)
CPU load: ${cpu_load}%
Last boot: $last_boot
LVM use: $lvm_use
Connections TCP: $tcp_connections ESTABLISHED
User log: $logged_users
Network: IP $ip_address ($mac_address)
Sudo: $sudo_commands cmd"
