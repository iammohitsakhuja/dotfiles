# Mohit's Dotfiles

Modern macOS development environment with unified theming and professional tooling.

## Features

- **Neovim**: Lazy.nvim with LSP, formatters, linters, and AI integration
- **Tmux**: Custom status bar with session persistence and network monitoring
- **WezTerm**: WebGpu-powered terminal with ligature support
- **AeroSpace**: Tiling window manager with workspace assignments
- **Unified Theming**: Catppuccin across all CLI tools
- **Modern CLI Tools**: eza, yazi, btop, fastfetch, starship, and more
- **Development Tooling**: Pre-commit hooks, ShellCheck, formatters, LSP servers
- **XDG Compliant**: Organized configuration structure

## Requirements

- Apple Silicon Mac (enforced by install script)
- macOS 15+
- Homebrew (installed automatically if missing)

## Installation

**Warning:** Review the code before running. These are personal configurations tailored to my workflow.

```bash
sudo chmod u+x macos/install.sh
./macos/install.sh --email "your@email.com" --name "Your Name"
```

**Options:**

- `--no-backup` - Skip backing up existing files (backup is default)
- `--help` - Show usage information

The script will:

- Validate Apple Silicon and Full Disk Access
- Create timestamped backup of existing configs
- Install Homebrew packages and applications
- Set up language version managers (goenv, nodenv, pyenv, rbenv, jenv)
- Configure macOS system defaults
- Install dotfiles via GNU Stow

## Restoring from Backup

If installation fails or you want to revert to previous configs:

```bash
./macos/restore.sh --help  # Show restore options
./macos/restore.sh --list  # List available backups
./macos/restore.sh         # Interactive restore from latest backup
```

**Note:** Restores configuration files only, not entire system state.

## Managing Dotfile Links

After adding new dotfiles or manually updating configs in `macos/home/`:

```bash
# Re-link configurations
stow -d "/path/to/dotfiles/macos" -t "$HOME" --no-folding home --verbose 1

# Unlink configurations
stow -D -d "/path/to/dotfiles/macos" -t "$HOME" --no-folding home --verbose 1
```

Replace `/path/to/dotfiles` with your repository path.

## Key Tools

| Category | Tool | Purpose |
|----------|------|---------|
| Terminal | WezTerm | Primary terminal emulator |
| Shell | Zsh + Starship | Enhanced shell with custom prompt |
| Editor | Neovim | Modern vim with LSP |
| Window Manager | AeroSpace | Tiling window management |
| File Manager | Yazi | Terminal-based file explorer |
| Git UI | Lazygit | Interactive git client |
| Multiplexer | Tmux | Session management |
| System Monitor | btop | Resource monitoring |

## Configuration

All configurations use XDG directories (`~/.config/`) and are managed via GNU Stow from `macos/home/`.

## Development

For safe testing without affecting your system, see [Development Environment Guide](docs/development-environment.md) for UTM-based VM setup.

## Credits

Inspired by dotfiles from the community. Themed with [Catppuccin](https://github.com/catppuccin/catppuccin).
