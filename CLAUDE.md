# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a macOS dotfiles repository with the following structure:

### Directory Structure

- `macos/` - Main configuration directory containing:
  - `home/` - Dotfiles and configurations managed with GNU Stow (includes `.startup_scripts/` subdirectory)
  - `install.sh` - Main installation orchestrator
  - `restore.sh` - Backup restoration utility
  - `Brewfile` - Homebrew package definitions
  - `iterm/` - iTerm2 configuration files
  - `themes/` - Color themes for iTerm and Terminal
  - `utils/` - Utility modules (logging, platform detection, package installers, system config)
  - `extras/` - Additional utilities

**Note**: Repository has transitioned from individual script architecture to utility-based modules located in `macos/utils/`.

- `.github/workflows/` - GitHub Actions for Claude Code integration
- `.claude/` - Claude Code working files and todos (not version controlled)

## Key Installation Commands

**⚠️ CRITICAL: NEVER test installation scripts on host machine - always use VM via SSH**

### Primary Installation

**Requirements:**

- Apple Silicon Mac (script enforces this requirement)
- Can run from any directory, but recommended from repository root
- Requires `--email` and `--name` parameters (mandatory for git/SSH config)

```bash
# Make executable and run with required parameters
sudo chmod u+x macos/install.sh
./macos/install.sh --email "your@email.com" --name "Your Name"

# Options:
./macos/install.sh --no-backup  # Skip backup of existing files (backup is default)
./macos/install.sh --help       # Show usage help
```

### Package Management Commands

Package installation and system configuration are now handled through utility-based architecture:

```bash
# Primary installation (includes all packages and system config)
./macos/install.sh --email "your@email.com" --name "Your Name"

# Restore from backup if needed
./macos/restore.sh --list           # List available backups
./macos/restore.sh --backup <timestamp>  # Restore specific backup
```

## Shell Environment Architecture

### Core Shell Files

- `.zshrc` - Main shell configuration with oh-my-zsh integration
- `.exports` - Environment variables, PATH configuration, and development settings
- `.aliases` - Command aliases and shortcuts
- `.api_keys` - API keys storage (created during installation)

### Key Environment Features

1. **GNU Tools Override**: Prioritizes GNU versions over BSD tools for Linux compatibility
2. **Language Version Managers**: Integrated hooks for goenv, nodenv, pyenv, rbenv, jenv
3. **Development Tools**: GitHub Copilot, Starship prompt, fzf, direnv integration
4. **Terminal Enhancement**: Custom colors, tmux integration, vi-mode support

### Configuration Management

Files are installed via symlinks using GNU Stow:

- Dotfiles in `macos/home/` are stowed to `$HOME/`
- `.config/` subdirectories: nvim/, bat/, lazygit/, yazi/
- Starship prompt config via `starship.toml`
- Startup scripts go to `$HOME/.startup_scripts/` (includes greeting.sh)
- Use `stow` command directly for selective package management

## System Configuration Automation

### macOS System Settings (via utils/system_config.sh)

Comprehensive macOS defaults configuration covering:

- UI/UX preferences, keyboard/trackpad settings
- Finder customizations, Dock configuration
- Safari, Mail, Terminal, and iTerm2 settings
- Security and privacy configurations
- Developer-friendly settings (disable autocorrect, smart quotes, etc.)

### Package Ecosystem (Brewfile)

Includes:

- CLI tools: GNU coreutils, modern alternatives (bat, fd, eza)
- Development: Docker, Kubernetes tools, language version managers
- GUI applications: browsers, development tools, utilities
- Fonts: Nerd fonts for terminal use
- Mac App Store applications via `mas`

## Development Workflow Notes

### Working with Installation Scripts

- Installation scripts require sudo permissions and email/name parameters
- Scripts validate parameters before proceeding
- Creates SSH keys and configures git with provided credentials
- Handles missing directories and creates them as needed
- Configures Touch ID for sudo authentication on Apple Silicon Macs
- Includes backup functionality with restore.sh for recovery from failed installations

### Shell Configuration Modifications

When modifying shell configurations:

1. Primary logic is in `.zshrc` with oh-my-zsh integration
2. Environment variables centralized in `.exports`
3. Aliases separated in `.aliases` for maintainability
4. oh-my-zsh plugins carefully selected to avoid startup slowdown

### Key Integration Points

- Starship prompt for enhanced shell experience
- Multiple language version managers with proper initialization order
- Terminal color configuration for tmux compatibility
- Extensive Homebrew package management with GUI applications

## Code Quality and Linting

### Available Tools

- **Pre-commit hooks**: Automatic code quality checks on commit (requires Docker)
- **ShellCheck**: Shell script analysis and best practices (runs in Docker)
- **shfmt**: Shell script formatting (runs in Docker)
- **markdownlint**: Markdown file linting and formatting (runs in Docker)
- **Additional formatters**: YAML and JSON formatting tools

### Running Quality Checks

**Prefer IDE-integrated tools when available**, fallback to command-line when needed:

```bash
# Install pre-commit hooks (one-time setup)
pre-commit install

# Run hooks manually on all files
pre-commit run --all-files

# Run hooks on specific files
pre-commit run --files path/to/file.sh

# Run shellcheck on scripts (if installed locally)
shellcheck macos/*.sh macos/utils/*.sh

# Run shfmt formatting (matches pre-commit config)
shfmt -d -s -i 4 .          # Check formatting differences
shfmt -w -s -i 4 .          # Format files in place
```

**Note**: Ensure Docker is running before committing or running pre-commit commands.

## GitHub Actions Integration

### Claude Code Automation

Two GitHub Actions workflows enable Claude Code integration:

- `claude.yml` - Responds to @claude mentions in issues, PRs, and comments
- `claude-code-review.yml` - Automatic code review on new PRs

### Brewfile Organization

- Each section in `macos/Brewfile` is arranged alphabetically

## Development Environment and Testing

### UTM-based Testing Setup

For safe testing of dotfiles without affecting the host system:

```bash
# Setup development environment with latest macOS
./setup-development.sh

# Or specify a version
./setup-development.sh --version 15.0
```

This script:

- Installs UTM and mist-cli if needed
- Downloads specified macOS IPSW firmware
- Provides instructions for VM creation

### VM Management Commands

```bash
# CLI VM control (requires VM named 'dotfiles-test')
utmctl start dotfiles-test
utmctl stop dotfiles-test
utmctl status dotfiles-test
utmctl list
```

### SSH Testing Workflow

**⚠️ CRITICAL: NEVER test installation scripts on host machine - always use VM via SSH**

1. **Get VM IP**: Use UTM GUI initially to get IP address from VM Terminal (typically `192.168.64.3`)
2. **SSH Testing**: `ssh $(whoami)@192.168.64.3 "cd /Volumes/dotfiles && ./script.sh [params]"`
3. **Verify Results**: `ssh $(whoami)@192.168.64.3 "verification_commands"`

**Quick Reference**: VM username usually same as host user, UTM IPs typically `192.168.64.x`

See `docs/development-environment.md` for comprehensive testing instructions.

### Testing Environment Architecture

- **VM Shared Directory**: `/Volumes/dotfiles` (within VM)
- **Host Repository**: Shared with VM for live testing
- **IPSW Cache**: `$HOME/.cache/dotfiles/` for reusing firmware downloads

## Git Commit Guidelines

### Pre-Commit Hook Workflow

**CRITICAL: When commits fail due to pre-commit hooks, NEVER use `--no-verify`**

Proper workflow when pre-commit hooks fail:

1. **Read hook error messages** to understand what failed
2. **Fix underlying issues** (linting errors, formatting, etc.)
3. **Stage hook-modified files** - Pre-commit often auto-fixes files (JSON formatting, whitespace)
4. **Retry commit** with hooks enabled
5. **Only commit when all hooks pass**

This maintains code quality and respects automated tooling.

### Commit Message Style

- For commit messages, avoid mentioning actual methods/files that have changed. Prefer describing what has changed, why it has changed - and try to provide context around it, rather than implementation details. Avoid making commit descriptions too long, be concise but thorough. Don't mention the no. of lines changed!
- In comments, don't mention where a particular method is defined. Instead, try to describe where certain functionality resides.
- End comments with a '.'
