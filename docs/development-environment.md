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
- Install UTM if not present
- Download the specified macOS installer (or latest available)
- Reuse existing installers when possible to save time and bandwidth

### 2. Create UTM Virtual Machine

After the setup script completes:

1. **Open UTM** from Applications or Launchpad

2. **Create New VM**:
   - Click "Create a New Virtual Machine"
   - Select "Virtualize" 
   - Choose "macOS 12+" (or appropriate version)

3. **Configure VM Settings**:
   - **Boot ISO Image**: Browse and select the installer path shown by the setup script
   - **Memory**: 8192 MB (8GB)
   - **Storage**: 50GB
   - **Shared Directory**: Add the dotfiles repository root directory (path shown by setup script)

4. **Finish Setup**: Complete the VM creation wizard

### 3. Install macOS

1. **Start the VM** and follow the macOS installation process
2. **Complete initial setup** (create user account, etc.)
3. **Access shared files** at `/Volumes/My Shared Files/` within the VM

### 4. Test Dotfiles Installation

Inside the VM:

```bash
# Navigate to shared dotfiles
cd "/Volumes/My Shared Files"

# Test installation
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
   - Navigate to shared files: `cd "/Volumes/My Shared Files"`
   - Run installation: `./macos/install.sh --email test@example.com --name "Test User"`
   - Verify configuration and functionality

4. **Reset for Next Test**:
   ```bash
   ./test/utils/vm-manager.sh restore clean-state
   ```

5. **Iterate**: Repeat testing with different configurations or changes

### Snapshot Management

- **clean-state**: Fresh macOS installation, ready for dotfiles testing
- **post-install**: After successful dotfiles installation (create manually)
- **pre-test**: Before trying experimental changes (create as needed)

## Troubleshooting

### Common Issues

**VM Creation Fails**:
- Ensure you have sufficient disk space and RAM
- Verify the installer path is correct
- Check UTM documentation for system requirements

**Shared Directory Not Accessible**:
- Verify shared directory is configured in UTM VM settings
- Restart the VM after changing shared directory settings
- Check that the host directory exists and has proper permissions

**Performance Issues**:
- Ensure sufficient RAM is allocated to the VM
- Enable hardware acceleration in UTM if supported

**VM Manager Commands Fail**:
- Ensure VM is named "dotfiles-test" (default)
- Check that UTM is running and accessible
- Verify `utmctl` command-line tools are available

### Multiple VM Configurations

You can create multiple VMs for different testing scenarios:

```bash
# Different macOS versions
./setup-development.sh --version 14.0  # macOS Sonoma
./setup-development.sh --version 15.0  # macOS Sequoia
```

## Security Considerations

- The VM environment is isolated from your host system
- Shared directories provide controlled access to dotfiles
- Snapshots allow safe experimentation with system changes
- Regular cleanup prevents accumulation of test data

---

For issues or questions about the development environment setup, refer to the project's GitHub issues or documentation.