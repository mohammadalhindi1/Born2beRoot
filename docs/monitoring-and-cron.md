# Monitoring Script and cron

The monitoring script broadcasts a short status report to logged-in terminals. It practices observability, shell text processing, permissions, and scheduling.

## Install and test

```bash
sudo install -o root -g root -m 755 script.sh /usr/local/sbin/monitoring.sh
sudo /usr/local/sbin/monitoring.sh
```

`/usr/local/sbin` keeps locally maintained administrative programs separate from distribution-managed files.

## Schedule it

```bash
sudo crontab -e
```

`crontab -e` opens the selected user's cron table. With `sudo`, it edits root's table. Add:

```cron
*/10 * * * * /usr/local/sbin/monitoring.sh
```

The five fields are minute, hour, day of month, month, and day of week. `*/10` means every ten minutes. Cron has a small environment, so use an absolute path.

## Verify

```bash
sudo crontab -l
sudo journalctl -u cron --since "30 minutes ago"    # Debian
sudo journalctl -u crond --since "30 minutes ago"   # Rocky
```

## Metrics

| Metric | Source | Meaning |
|---|---|---|
| Architecture | `uname -a` | Kernel and machine details |
| Physical CPUs | `lscpu` | Unique sockets visible to the guest |
| vCPU | `nproc` | Available logical processors |
| Memory | `free` | Used and total RAM |
| Disk | `df` | Mounted filesystem usage |
| CPU load | `vmstat` | 100 minus idle percentage |
| Last boot | `who -b` | Latest boot time |
| LVM | `lsblk` | Whether an LVM layer exists |
| TCP | `ss` | Established TCP sessions |
| Users | `who` | Unique logged-in users |
| Network | `hostname`, `ip` | Primary IP and interface MAC |
| sudo | `journalctl` | Logged sudo commands |

This is an educational snapshot, not production monitoring. Production systems normally centralize time-series metrics and logs with retention and alerts.
