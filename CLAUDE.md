# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a macOS dotfiles repository with the following structure:

### Directory Structure
- `macos/` - Main configuration directory containing:
  - `home/` - Dotfiles and configurations managed with GNU Stow (includes `.startup_scripts/` subdirectory)
  - `scripts/` - Installation scripts for packages, languages, and tools
  - `install.sh` - Main installation orchestrator
  - `Brewfile` - Homebrew package definitions
  - `iterm/` - iTerm2 configuration files
  - `themes/` - Color themes for iTerm and Terminal
  - `utils/` - Utility files (terminfo, automator workflows)
  - `extras/` - Additional utilities
- `.github/workflows/` - GitHub Actions for Claude Code integration
- `.claude/` - Claude Code working files and todos (not version controlled)

## Key Installation Commands

### Primary Installation
```bash
# Make executable and run with required parameters
sudo chmod u+x macos/install.sh
./macos/install.sh --email "your@email.com" --name "Your Name"

# Options:
./macos/install.sh --no-backup  # Skip backup of existing files (backup is default)
```

### Package Management Commands
```bash
# Install all packages via Homebrew
bash macos/scripts/packages.sh

# Individual package types
bash macos/scripts/node-packages.sh
bash macos/scripts/python-packages.sh
bash macos/scripts/ruby-gems.sh
bash macos/scripts/go-packages.sh
bash macos/scripts/vim-packages.sh
bash macos/scripts/shell-packages.sh

# Configure macOS system settings
bash macos/scripts/macos.sh
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
- Neovim config goes to `$HOME/.config/nvim/`
- Bat config goes to `$HOME/.config/bat/`
- Startup scripts go to `$HOME/.startup_scripts/` (organized subdirectory)
- Use `stow` command directly for selective package management

## System Configuration Automation

### macOS System Settings (`macos/scripts/macos.sh`)
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

## GitHub Actions Integration

### Claude Code Automation
Two GitHub Actions workflows enable Claude Code integration:
- `claude.yml` - Responds to @claude mentions in issues, PRs, and comments
- `claude-code-review.yml` - Automatic code review on new PRs

### Brewfile Organization
- Each section in `macos/Brewfile` is arranged alphabetically