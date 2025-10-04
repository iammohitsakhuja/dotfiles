# Development Environment Setup

This guide explains how to set up a safe UTM-based virtual machine environment for testing dotfiles installation without
risking your host system.

## Table of Contents

- [Development Environment Setup](#development-environment-setup)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Caveats](#caveats)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
    - [1. Run Setup Script](#1-run-setup-script)
    - [2. Create UTM Virtual Machine](#2-create-utm-virtual-machine)
    - [3. Install macOS](#3-install-macos)
    - [4. SSH Setup (One-time)](#4-ssh-setup-one-time)
    - [5. NFS Setup](#5-nfs-setup)
      - [Automating NFS Mount on Guest Startup](#automating-nfs-mount-on-guest-startup)
  - [Code Quality Tools](#code-quality-tools)
    - [Available Tools](#available-tools)
    - [Run Tools](#run-tools)
  - [Testing Workflow](#testing-workflow)
    - [Core Testing Principles](#core-testing-principles)
    - [Recommended Testing Process](#recommended-testing-process)
    - [Testing Commands Framework](#testing-commands-framework)
      - [Basic Testing Pattern](#basic-testing-pattern)
      - [Error Testing](#error-testing)
    - [Multiple VM Configurations](#multiple-vm-configurations)
  - [Troubleshooting](#troubleshooting)
    - [Shared Directory File Synchronization Issues](#shared-directory-file-synchronization-issues)
    - [Other Common Issues](#other-common-issues)

## Overview

The development environment uses [UTM](https://mac.getutm.app) to create macOS virtual machines where you can safely
test dotfiles installation, configuration changes, and system modifications.

### Caveats

- Since Apple Account login is not possible inside the VM, you won't be able to test functionality related to App Store
    apps (installed via `mas`).

## Prerequisites

- macOS host system
- At least 8GB available RAM
- 100GB+ available disk space
- Homebrew
- UTM installed (handled automatically by setup script)
- Docker running (required for code quality tools: shellcheck, shfmt, markdownlint)

## Setup

### 1. Run Setup Script

```bash
# Use latest macOS installer
./setup-development.sh

# Or specify a specific version
./setup-development.sh --version 15.6
```

This script will:

- Install UTM and mist-cli if not present
- Download the specified macOS IPSW firmware (or latest available)
- Reuse existing IPSW files when possible to save time and bandwidth

### 2. Create UTM Virtual Machine

After the setup script completes:

1. **Open UTM** from Applications or Launchpad

2. **Create New VM**:
    - Click "Create a New Virtual Machine"
    - Select "Virtualize"
    - Choose "macOS 12+" (or appropriate version)
    - (If asked) Provide the IPSW file which was downloaded earlier

3. **Configure VM Settings**:
    - **Name**: Set VM name to `dotfiles-test` (enables CLI management via utmctl)
    - **IPSW**: Browse and select the IPSW file path shown by the setup script
    - **Memory**: Minimum 8192 MB (8GB)
    - **Storage**: 100GB

4. **Finish Setup**: Complete the VM creation wizard

### 3. Install macOS

1. **Start the VM** and follow the macOS installation process
2. **Complete initial setup** - create user account and **remember the username and password** (required for SSH
    access). Name the VM user the same as your host user for consistency and easier logins. Get your host username by
    running `whoami` in the terminal of the **host**.
3. **Configure sleep settings** to prevent shared directory sync issues (see Troubleshooting section below for details)

### 4. SSH Setup (One-time)

Get the VM's IP address from within the macOS VM:

1. Open the VM via UTM GUI
2. Once macOS is running, first open **System Settings**, and go to **General**, then to **Sharing**, then enable
    **Remote Login**. *Note down the guest IP being shown here in the format: `username@192.168.64.3`*.
3. Test SSH access from the host machine:

    ```bash
    ssh $(whoami)@192.168.64.3 # Replace with your VM's actual IP
    ```

**Get the Guest IP**

1. To get the IP of the guest machine, if not already done so, open **Terminal** within the VM
2. Run one of these commands in the VM's Terminal:

    ```bash
    # Inside the VM's Terminal, run one of these commands:
    ifconfig en0 | grep "inet " | awk '{print $2}'
    # or
    hostname -I
    ```

This is the last step that requires using the VM GUI - after getting the IP, you can manage everything via CLI.

**SSH Login & Password-less SSH Setup**

Once you have the VM's IP address, set up password-less SSH access:

1. **Generate SSH key pair on host** (if you don't already have one):

   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   # Press Enter to accept default location (~/.ssh/id_ed25519)
   # Optionally set a passphrase or press Enter for no passphrase
   ```

2. **Copy public key to VM**:

   ```bash
   # Replace 192.168.64.3 with your VM's actual IP
   ssh-copy-id $(whoami)@192.168.64.3
   ```

   You'll be prompted for the VM user's password one last time.

3. **Test password-less login**:

   ```bash
   ssh $(whoami)@192.168.64.3
   ```

   You should now be able to SSH into the VM without entering a password.

4. **Optional: Add SSH config entry** for easier access:

   ```bash
   # Add to ~/.ssh/config on your host machine
   cat >> ~/.ssh/config << 'EOF'

   Host dotfiles-test
       HostName 192.168.64.3
       User $(whoami)
       ForwardAgent yes
       ServerAliveInterval 60
   EOF
   ```

   Then connect simply with: `ssh dotfiles-test`

**Quick Reference:**

- **VM Username**: Usually same as your host machine username
- **VM IP Pattern**: UTM typically assigns IPs like `192.168.64.3`, `192.168.64.4`, etc.
- **Example SSH**: `ssh $(whoami)@192.168.64.3`

**⚠️ CRITICAL: Always test installation scripts in VM, never on host machine!**

### 5. NFS Setup

1. On the **host**, add the following line to `/etc/exports`:

    ```conf
    /path/to/dotfiles -alldirs -mapall=username -network 192.168.64.0 -mask 255.255.255.0
    ```

    Replace `/path/to/dotfiles` with the actual path, e.g. `/Users/username/Documents/dotfiles`.<br />
    Replace `username` with your actual username.

    You might need `sudo` access to write to the above file. Try `sudo nano /etc/exports` or `sudo vim /etc/exports`.

2. **macOS Sandbox Fix**: On modern macOS, NFS daemon requires full disk access.
    - Open **System Settings** > **Privacy & Security** > **Full Disk Access**
    - Click the `+` button and add `/sbin/nfsd` to the list

3. Now, run following on the **host**:

    ```bash
    # Restart the NFS service
    $ sudo nfsd restart

    # Check for errors
    $ sudo nfsd checkexports

    # Check that the exports are correct
    $ showmount -e
    # Expected: /path/to/dotfiles 192.168.64.0
    ```

4. On the **guest**, mount the NFS share:

    ```bash
    # Create a mount point
    $ sudo mkdir -p /Volumes/dotfiles

    # Mount the NFS share
    $ sudo mount -t nfs -o resvport,rw,noac,locallocks,vers=3 192.168.64.1:/path/to/dotfiles /Volumes/dotfiles
    ```

    Again, replace `/path/to/dotfiles` with their actual path on the **host**, e.g. `/Users/username/Documents/dotfiles`.

*Disclaimer*: By just following the above, you might need to run the mount commands on the guest every time it boots.
In order to setup automatic mounting, continue reading.

#### Automating NFS Mount on Guest Startup

To automate the NFS mount on guest startup, on the **guest**:

1. Add the following line to the `/etc/auto_master` file:

    ```conf
    /-          auto_nfs        -nobrowse,nosuid
    ```

2. Then add the following line to `/etc/auto_nfs` (create the file if it doesn't exist):

    ```conf
    /System/Volumes/Data/../Data/Volumes/dotfiles -fstype=nfs,resvport,rw,noac,locallocks,vers=3 192.168.64.1:/path/to/dotfiles
    ```

    Again, replace `/path/to/dotfiles` with the actual path on the **host**.

3. Make sure you set appropriate permissions on `auto_nfs`:

    ```bash
    sudo chmod 644 /etc/auto_nfs
    ```

4. Then use `automount` to enable the NFS share to mount automatically:

    ```bash
    sudo automount -cv
    ```

5. Now, the NFS share should mount automatically on guest startup.

Reference: <https://gist.github.com/L422Y/8697518>

## Code Quality Tools

The repository includes automated code quality tools that run as pre-commit hooks. These tools use Docker containers and
require Docker to be running on your host system.

### Available Tools

- **Pre-commit hooks**: Automatic code quality checks on commit
- **ShellCheck**: Shell script analysis and best practices (runs in Docker)
- **shfmt**: Shell script formatting (runs in Docker)
- **markdownlint**: Markdown file linting and formatting (runs in Docker)
- **Additional formatters**: YAML and JSON formatting tools

### Run Tools

```bash
# Install pre-commit hooks (one-time setup)
pre-commit install

# Run hooks manually on all files
pre-commit run --all-files

# Run hooks on specific files
pre-commit run --files path/to/file.sh

# Run shellcheck locally (if installed)
shellcheck path/to/script.sh
shellcheck macos/scripts/*.sh

# Run shfmt locally (if installed) - matches pre-commit config
shfmt -d -s -i 4 .          # Check formatting differences
shfmt -w -s -i 4 .          # Format files in place
shfmt -l -s -i 4 .          # List files that need formatting
```

**Note**: Ensure Docker is running before committing changes or running pre-commit commands, as the linting tools
execute in Docker containers.

## Testing Workflow

### Core Testing Principles

**⚠️ NEVER test installation scripts on the host machine!** Always use VM environment to prevent:

- Git configuration corruption
- System setting changes
- Unwanted file modifications
- SSH key overwrites

### Recommended Testing Process

1. **Initial Setup**: Setup VM environment as described above.

2. **SSH-Based Testing Pattern**:

   ```bash
   # Start VM
   utmctl start dotfiles-test

   # Wait for VM to boot, then test via SSH (never run scripts directly on host)
   ssh $(whoami)@192.168.64.3 "cd /Volumes/dotfiles && ./macos/install.sh --email test@example.com --name 'Test User'"

   # Or connect interactively for more control:
   ssh $(whoami)@192.168.64.3
   cd "/Volumes/dotfiles"
   ./macos/install.sh --email test@example.com --name "Test User"

   # Verify results via SSH
   ssh $(whoami)@192.168.64.3 "ls -la ~ && git config --global --list"

   # Stop VM
   utmctl stop dotfiles-test
   ```

### Testing Commands Framework

#### Basic Testing Pattern

```bash
# Connection verification (username usually same as host, IP typically 192.168.64.x)
ssh $(whoami)@192.168.64.3 "echo 'VM ready for testing'"

# Script execution (replace with actual script and params)
ssh $(whoami)@192.168.64.3 "cd /Volumes/dotfiles && ./target_script.sh --params"

# Results verification (customize based on what you're testing)
ssh $(whoami)@192.168.64.3 "ls -la ~ && git config --list --global"

# Clean state for next test
ssh $(whoami)@192.168.64.3 "cleanup_commands_as_needed"
```

#### Error Testing

```bash
# Test error handling by providing invalid inputs
ssh $(whoami)@192.168.64.3 "cd /Volumes/dotfiles && ./script.sh --invalid-params"

# Test edge cases
ssh $(whoami)@192.168.64.3 "setup_edge_case_conditions && cd /Volumes/dotfiles && ./script.sh"
```

### Multiple VM Configurations

You can create multiple VMs for different testing scenarios:

```bash
# Different macOS versions
./setup-development.sh --version 14.0  # macOS Sonoma IPSW
./setup-development.sh --version 15.0  # macOS Sequoia IPSW
```

## Troubleshooting

### Shared Directory File Synchronization Issues

**Problem**: Changes to files in the shared directory don't reflect in the VM or appear stale.

**Primary Solution - Configure VM Sleep Settings**:

1. **Option 1 - Energy/Battery Settings** (macOS Sequoia+):
   - Go to **System Settings** > **Energy** (or **Battery** > **Options** on laptops)
   - Set **Prevent automatic sleeping when the display is off** to enabled

2. **Option 2 - Lock Screen Settings**:
   - Go to **System Settings** > **Lock Screen**
   - Set **Turn display off on battery when inactive** to "Never"
   - Set **Turn display off on power adapter when inactive** to "Never"

### Other Common Issues

- **Permission errors**: Ensure the shared directory has proper read/write permissions
- **VM won't start**: Check available disk space and UTM logs

---

For issues or questions about the development environment setup, refer to the project's GitHub issues or documentation.
