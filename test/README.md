# Testing Environment

UTM-based testing infrastructure for safe dotfiles installation validation.

## Quick Start

```bash
# Setup UTM VM
./setup-development.sh

# VM management
./test/utils/vm-manager.sh status
./test/utils/vm-manager.sh snapshot clean-state

# Run tests
./test/scripts/test-runner.sh smoke-test
./test/scripts/test-runner.sh test-installation
```

## Workflow

1. **Setup**: `./setup-development.sh` creates UTM VM with shared dotfiles
2. **Test**: Complete macOS setup in VM, test installation at `/Volumes/My Shared Files/dotfiles`
3. **Snapshot**: `./test/utils/vm-manager.sh snapshot` saves clean states
4. **Reset**: `./test/utils/vm-manager.sh restore` resets for new tests

## Structure

- `utils/vm-manager.sh` - VM snapshot/restore/cleanup operations
- `scripts/test-runner.sh` - Basic test execution framework
- `fixtures/` - Test data and configurations (future use)
