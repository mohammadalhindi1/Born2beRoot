# Building the Virtual Machine with Oracle VirtualBox

This guide explains the infrastructure decisions behind the VM. Menu labels may vary slightly between VirtualBox versions.

## What a virtual machine is

A virtual machine (VM) is a software-defined computer. VirtualBox is the **hypervisor**: it exposes virtual CPU, RAM, disk, and network devices to a guest operating system while the host computer keeps running normally.

- **Host:** your physical computer and its operating system.
- **Hypervisor:** Oracle VirtualBox.
- **Guest:** Debian or Rocky Linux installed inside the VM.
- **Virtual disk:** a file on the host that behaves like a disk inside the guest.

A VM boots its own kernel. A container normally shares the host kernel, so these are different isolation models.

## Download and verify the ISO

Download only from the official Debian or Rocky Linux website. Compare its SHA-256 checksum with the published value:

```bash
sha256sum debian-*.iso
# Windows PowerShell
Get-FileHash .\debian-*.iso -Algorithm SHA256
```

## Create the VM

In VirtualBox select **New**, then use sensible lab values:

| Setting | Recommended value | Reason |
|---|---:|---|
| Type | Linux | Sensible virtual hardware defaults |
| Version | Debian (64-bit) or Red Hat (64-bit) | Matches the guest family |
| RAM | 1–2 GB | Enough for a CLI-only lab |
| CPUs | 1–2 | Keeps the VM light |
| Disk | 10–30 GB VDI, dynamically allocated | Grows as data is written |
| Graphics | Minimal/default | No desktop is required |
| EFI | Follow the current subject | Changes the boot method |

Choose values your host can afford and be ready to explain each decision.

## Networking

Start with **NAT**. The guest can reach the internet, while unsolicited inbound LAN traffic cannot normally reach it.

For SSH from the host, add a NAT port-forwarding rule:

| Field | Value |
|---|---|
| Protocol | TCP |
| Host IP | 127.0.0.1 |
| Host port | 4242 |
| Guest IP | empty or the guest IP |
| Guest port | 4242 |

```bash
ssh -p 4242 username@127.0.0.1
```

**Bridged Adapter** gives the VM its own LAN address. It is useful in a trusted lab but exposes the guest more directly.

## Installation flow

Attach the ISO and boot the VM:

1. Select language, keyboard, timezone, and hostname.
2. Do not install a graphical desktop unless explicitly allowed.
3. Create the required administrator and regular account.
4. Choose encrypted LVM partitioning if required.
5. Install only necessary services.
6. Reboot, eject the ISO, and update the system.

## Snapshots and backups

Useful snapshot checkpoints are the clean OS, completed storage/users, completed security, and final validated state. A snapshot is not a backup because it depends on the original VM files. Export or copy the VM separately for recovery.

## VM signature warning

Some evaluations use a disk signature. Cloning, recreating, or reformatting the disk can change it. Record the expected signature only after the layout is stable and follow the current subject exactly.
