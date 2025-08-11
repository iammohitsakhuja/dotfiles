#!/usr/bin/env bash

set -e

# Basic Test Runner for Dotfiles Installation
# Provides framework for automated testing of dotfiles installation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VM_MANAGER="$SCRIPT_DIR/../utils/vm-manager.sh"

# Helper function to exit the script
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Check prerequisites
check_prerequisites() {
    if [ ! -f "$VM_MANAGER" ]; then
        die "ERROR: VM manager not found at $VM_MANAGER"
    fi
    
    if ! command -v utmctl &> /dev/null; then
        die "ERROR: UTM not installed. Run setup-development.sh first."
    fi
}

# Run basic installation test
test_installation() {
    local test_name="${1:-basic-install}"
    
    echo "=== Running test: $test_name ==="
    
    # Ensure VM is in clean state
    echo "Preparing clean test environment..."
    "$VM_MANAGER" restore clean-state 2>/dev/null || {
        echo "No clean-state snapshot found. Creating initial snapshot..."
        "$VM_MANAGER" start
        sleep 10  # Allow VM to boot
        "$VM_MANAGER" snapshot clean-state
    }
    
    echo "Starting VM for testing..."
    "$VM_MANAGER" start
    
    echo "Test environment ready. Manual testing required:"
    echo "1. VM should be accessible via UTM interface"
    echo "2. Dotfiles should be available at: /Volumes/My Shared Files/"
    echo "3. Run installation: cd /Volumes/My\ Shared\ Files && ./macos/install.sh --email test@example.com --name 'Test User'"
    echo ""
    echo "After testing, run: $0 cleanup-test"
}

# Cleanup after test
cleanup_test() {
    echo "=== Cleaning up test environment ==="
    "$VM_MANAGER" stop
    "$VM_MANAGER" restore clean-state
    echo "Test environment reset to clean state."
}

# Run smoke tests
smoke_test() {
    echo "=== Running smoke tests ==="
    
    # Check if setup script exists and is executable
    if [ ! -x "$PROJECT_ROOT/setup-development.sh" ]; then
        die "ERROR: setup-development.sh not found or not executable"
    fi
    
    # Check if VM manager works
    "$VM_MANAGER" status || echo "VM not yet created (expected)"
    
    # Check if required directories exist
    [ -d "$PROJECT_ROOT/test/utils" ] || die "ERROR: test/utils directory missing"
    [ -d "$PROJECT_ROOT/test/scripts" ] || die "ERROR: test/scripts directory missing"
    
    echo "✅ Smoke tests passed"
}

show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Test Commands:
  smoke-test               Run basic smoke tests
  test-installation        Prepare VM for installation testing
  cleanup-test             Reset VM to clean state after testing
  
Examples:
  $0 smoke-test           # Verify test infrastructure
  $0 test-installation    # Start interactive installation test
  $0 cleanup-test         # Reset after testing

Note: This is a basic test framework. Full automated testing requires
additional development and VM automation capabilities.

EOF
}

# Main execution
check_prerequisites

case "${1:-}" in
    "smoke-test")
        smoke_test
        ;;
    "test-installation")
        test_installation
        ;;
    "cleanup-test")
        cleanup_test
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