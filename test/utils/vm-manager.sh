#!/usr/bin/env bash

set -e

# VM Management Utilities for UTM-based Testing Environment
# Provides snapshot, restore, and cleanup functionality for dotfiles testing

VM_NAME="dotfiles-test"

# Helper function to exit the script
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Check if VM exists
vm_exists() {
    utmctl list | grep -q "^$VM_NAME\s" 2>/dev/null
}

# Create VM snapshot
create_snapshot() {
    local snapshot_name="${1:-clean-state}"
    
    if ! vm_exists; then
        die "ERROR: VM '$VM_NAME' does not exist. Run setup-development.sh first."
    fi
    
    echo "Creating snapshot '$snapshot_name' for VM '$VM_NAME'..."
    utmctl snapshot create "$VM_NAME" --name "$snapshot_name"
    echo "Snapshot '$snapshot_name' created successfully."
}

# Restore from snapshot
restore_snapshot() {
    local snapshot_name="${1:-clean-state}"
    
    if ! vm_exists; then
        die "ERROR: VM '$VM_NAME' does not exist. Run setup-development.sh first."
    fi
    
    echo "Restoring VM '$VM_NAME' to snapshot '$snapshot_name'..."
    utmctl stop "$VM_NAME" 2>/dev/null || true
    utmctl snapshot restore "$VM_NAME" --name "$snapshot_name"
    echo "VM restored to snapshot '$snapshot_name' successfully."
}

# List available snapshots
list_snapshots() {
    if ! vm_exists; then
        die "ERROR: VM '$VM_NAME' does not exist. Run setup-development.sh first."
    fi
    
    echo "Available snapshots for VM '$VM_NAME':"
    utmctl snapshot list "$VM_NAME"
}

# Clean up VM and all snapshots
cleanup_vm() {
    if ! vm_exists; then
        echo "VM '$VM_NAME' does not exist. Nothing to clean up."
        return 0
    fi
    
    echo "Stopping and removing VM '$VM_NAME'..."
    utmctl stop "$VM_NAME" 2>/dev/null || true
    utmctl delete "$VM_NAME"
    echo "VM '$VM_NAME' removed successfully."
}

# Get VM status
vm_status() {
    if ! vm_exists; then
        echo "VM '$VM_NAME' does not exist."
        return 1
    fi
    
    echo "VM Status for '$VM_NAME':"
    utmctl list | grep "^$VM_NAME\s"
}

# Start VM
start_vm() {
    if ! vm_exists; then
        die "ERROR: VM '$VM_NAME' does not exist. Run setup-development.sh first."
    fi
    
    echo "Starting VM '$VM_NAME'..."
    utmctl start "$VM_NAME"
    echo "VM '$VM_NAME' started successfully."
}

# Stop VM
stop_vm() {
    if ! vm_exists; then
        die "ERROR: VM '$VM_NAME' does not exist."
    fi
    
    echo "Stopping VM '$VM_NAME'..."
    utmctl stop "$VM_NAME"
    echo "VM '$VM_NAME' stopped successfully."
}

show_help() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

VM Management Commands:
  status                    Show VM status
  start                     Start the VM
  stop                      Stop the VM
  snapshot [NAME]           Create snapshot (default: clean-state)
  restore [NAME]            Restore from snapshot (default: clean-state)
  list-snapshots           List available snapshots
  cleanup                   Remove VM and all snapshots

Examples:
  $0 status                 # Check VM status
  $0 snapshot initial       # Create 'initial' snapshot
  $0 restore initial        # Restore to 'initial' snapshot
  $0 cleanup               # Remove everything

EOF
}

# Parse command line arguments
case "${1:-}" in
    "status")
        vm_status
        ;;
    "start")
        start_vm
        ;;
    "stop")
        stop_vm
        ;;
    "snapshot")
        create_snapshot "$2"
        ;;
    "restore")
        restore_snapshot "$2"
        ;;
    "list-snapshots")
        list_snapshots
        ;;
    "cleanup")
        cleanup_vm
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo "ERROR: Unknown command '$1'"
        show_help
        exit 1
        ;;
esac