# Services and Security Controls

Born2beRoot teaches trust boundaries: who can log in, what they can execute, which ports are reachable, and how privileged actions are recorded.

## SSH

SSH provides encrypted remote login and command execution. Typical hardening includes the required port, disabled direct root login, limited users, strong authentication, and matching firewall rules.

```bash
sudo systemctl status ssh
sudo ss -ltnp
sudo sshd -t
```

Validate `/etc/ssh/sshd_config` with `sshd -t` before reloading. Keep the current session open until a second connection succeeds.

## Firewall

Debian commonly uses UFW:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 4242/tcp
sudo ufw enable
sudo ufw status verbose
```

Rocky commonly uses firewalld:

```bash
sudo firewall-cmd --permanent --add-port=4242/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

Open only ports backed by an intentional service. A nonstandard SSH port is not a replacement for authentication and updates.

## sudo

`sudo` provides controlled privilege escalation and auditing. Always edit its policy with `visudo`:

```bash
sudo visudo
sudo visudo -f /etc/sudoers.d/born2beroot
sudo -l
```

Understand every required timeout, retry, TTY, secure-path, and logging rule instead of copying a policy blindly.

## Password policy

A full policy combines:

- **Aging:** minimum/maximum age and warnings, commonly via `/etc/login.defs` and `chage`.
- **Quality:** length, complexity, repetition, and username checks, commonly enforced by PAM.

```bash
sudo chage -l username
getent passwd username
id username
```

A bad PAM rule can block all authentication. Keep VM console recovery access while testing.

## AppArmor and SELinux

These mandatory access control systems add restrictions after normal Unix permissions:

- Debian commonly uses **AppArmor**, based mainly on path profiles.
- Rocky commonly uses **SELinux**, based on labels, domains, types, and policy.

```bash
sudo aa-status
getenforce
sestatus
```

Only the commands for your distribution will be available.

## Users and groups

```bash
sudo adduser username
sudo groupadd user42
sudo usermod -aG user42 username
id username
getent group user42
```

The `-a` matters: omitting it can replace supplementary groups.

For every service, be able to explain why it exists, whether it starts at boot, which port/process it uses, and which config/log proves it works:

```bash
systemctl --type=service --state=running
systemctl is-enabled ssh
ss -lntup
journalctl -u ssh --since today
```
