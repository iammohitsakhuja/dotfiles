# Development Environment Setup

This guide explains how to set up a safe UTM-based virtual machine environment for testing dotfiles installation without risking your host system.

## Overview

The development environment uses UTM (Universal Turing Machine) to create macOS virtual machines where you can safely test dotfiles installation, configuration changes, and system modifications.

## Prerequisites

- macOS host system
- At least 8GB available RAM
- 50GB+ available disk space
- UTM installed (handled automatically by setup script)

## Quick Setup

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

3. **Configure VM Settings**:
   - **IPSW**: Browse and select the IPSW file path shown by the setup script
   - **Memory**: 8192 MB (8GB)
   - **Storage**: 50GB
   - **Shared Directory**: Add the dotfiles repository root directory (path shown by setup script)

4. **Finish Setup**: Complete the VM creation wizard

### 3. Install macOS

1. **Start the VM** and follow the macOS installation process
2. **Complete initial setup** - create user account and **remember the username and password** (required for SSH access)
3. **Access shared files** at `/Volumes/My Shared Files/` within the VM

### 4. SSH Setup (One-time)

Get the VM's IP address from within the VM:

```bash
# Inside the VM, run one of these commands:
ifconfig en0 | grep "inet " | awk '{print $2}'
# or
hostname -I
```

Note down the IP address (e.g., `192.168.64.3`) for SSH access from your host machine.

### 5. Test Dotfiles Installation

From your host machine, use SSH to run commands in the VM:

```bash
# Replace 'username' with your VM username and 'VM_IP' with the noted IP
ssh username@VM_IP "cd /Volumes/My\ Shared\ Files && ./macos/install.sh --email test@example.com --name 'Test User'"

# Or connect interactively:
ssh username@VM_IP
cd "/Volumes/My Shared Files"
./macos/install.sh --email test@example.com --name "Test User"
```

## VM Management

### Using VM Manager Utility

```bash
# Check VM status
./test/utils/vm-manager.sh status

# Create snapshot before testing
./test/utils/vm-manager.sh snapshot clean-state

# Restore to clean state after testing
./test/utils/vm-manager.sh restore clean-state

# Start/stop VM
./test/utils/vm-manager.sh start
./test/utils/vm-manager.sh stop

# Clean up VM completely
./test/utils/vm-manager.sh cleanup
```

### Using Test Runner

```bash
# Run smoke tests
./test/scripts/test-runner.sh smoke-test

# Prepare for installation testing
./test/scripts/test-runner.sh test-installation

# Reset after testing
./test/scripts/test-runner.sh cleanup-test
```

## Testing Workflow

### Recommended Process

1. **Initial Setup**:
   ```bash
   ./setup-development.sh
   # Create VM manually in UTM as described above
   ```

2. **Create Clean Snapshot**:
   ```bash
   ./test/utils/vm-manager.sh snapshot clean-state
   ```

3. **Test Installation**:
   - Boot VM
   - SSH from host: `ssh username@VM_IP "cd /Volumes/My\ Shared\ Files && ./macos/install.sh --email test@example.com --name 'Test User'"`
   - Verify configuration via SSH: `ssh username@VM_IP "ls -la ~"`

4. **Reset for Next Test**:
   ```bash
   ./test/utils/vm-manager.sh restore clean-state
   ```

5. **Iterate**: Repeat testing with different configurations or changes

### Snapshot Management

- **clean-state**: Fresh macOS installation, ready for dotfiles testing
- **post-install**: After successful dotfiles installation (create manually)
- **pre-test**: Before trying experimental changes (create as needed)

### Multiple VM Configurations

You can create multiple VMs for different testing scenarios:

```bash
# Different macOS versions
./setup-development.sh --version 14.0  # macOS Sonoma IPSW
./setup-development.sh --version 15.0  # macOS Sequoia IPSW
```

---

For issues or questions about the development environment setup, refer to the project's GitHub issues or documentation.