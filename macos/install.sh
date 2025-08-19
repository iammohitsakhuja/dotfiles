#!/usr/bin/env bash

# Helper function to exit the script.
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialise the option variables.
# This ensures we are not contaminated by variables from the environment.
backup=1 # 0 is for no backup, 1 is for backup (default).
email=
name=

# TODO: Add a verbose option.
show_help() {
    echo "Usage: ./install.sh [-h | --help] [--no-backup] [-e | --email] [-n | --name]"
    echo "       -h, --help     | Show this help."
    echo "       --no-backup    | Skip backing up existing files before stow operations."
    echo "       -e, --email    | The email that you would like to use for setting up things like git, ssh e.g. \"abc@example.com\"."
    echo "       -n, --name     | The name that you would like to use for setting up things like git e.g. \"John Doe\"."
    echo ""
    echo "To remove the files that you don't need, simply open this installation script and delete their names."
}

# Ensure proper usage.
while :; do
    case $1 in
    -h | -\? | --help)
        show_help
        exit
        ;;
    --no-backup)
        backup=0
        shift
        ;;
    -e | --email)
        # TODO: Handle the case where the next argument to email is another option e.g. `-e -c`.
        if [[ "$2" ]]; then
            email=$2
            shift 2
        else
            die "ERROR: \"--email\" requires a non-empty option argument."
        fi
        ;;
    --email=?*)
        email=${1#*=} # Delete everything up to "=" and assign the remainder.
        shift
        ;;
    --email=) # Handle the case of an empty --email=.
        die "ERROR: \"--email\" requires a non-empty option argument."
        ;;
    -n | --name)
        # TODO: Handle the case where the next argument to name is another option e.g. `-n -c`.
        if [[ "$2" ]]; then
            name=$2
            shift 2
        else
            die "ERROR: \"--name\" requires a non-empty option argument."
        fi
        ;;
    --name=?*)
        name=${1#*=} # Delete everything up to "=" and assign the remainder.
        shift
        ;;
    --name=) # Handle the case of an empty --name=.
        die "ERROR: \"--name\" requires a non-empty option argument."
        ;;
    *) # Default case: No more options, so break out of the loop.
        echo "======================================================================"
        echo "                    macOS Dotfiles Installation"
        echo "======================================================================"
        echo ""
        echo "Configuration:"
        echo "  • Backup existing files: $(if [[ $backup == 1 ]]; then echo "Yes"; else echo "No"; fi)"
        echo "  • Email: $email"
        echo "  • Name: $name"
        echo ""
        if ! [[ $email ]]; then
            die "ERROR: \"--email\" is required."
        fi
        if ! [[ $name ]]; then
            die "ERROR: \"--name\" is required."
        fi
        break
        ;;
    esac
done

# Get the current working directory.
PWD=$(pwd)

echo "======================================================================"
echo "                  Authentication & Dependencies"
echo "======================================================================"
echo ""

# Ask for administrator password upfront.
echo "Installation requires administrator authentication..."
sudo -v

# Keep `sudo` alive i.e. update existing time stamp until `./install.sh` has
# finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

echo "✓ Administrator authentication confirmed"
echo ""

# Function to install essential dependencies needed for the installation
bootstrap_dependencies() {
    echo "Step 1/5: Checking and installing essential dependencies..."
    echo ""

    # Check if we're on macOS
    if [[ $OSTYPE != "darwin"* ]]; then
        die "ERROR: This script is designed for macOS only"
    fi
    echo "✓ macOS environment confirmed"

    # Check if Mac is using Apple Silicon and install Rosetta 2 if needed
    if [[ $(uname -m) == 'arm64' ]]; then
        echo "  → Installing Rosetta 2 for Apple Silicon Mac..."
        if sudo softwareupdate --install-rosetta --agree-to-license 2>/dev/null; then
            echo "  ✓ Rosetta 2 installation completed"
        else
            echo "  ✓ Rosetta 2 already installed or installation skipped"
        fi
    else
        echo "  ✓ Intel Mac detected - Rosetta 2 not needed"
    fi

    # Install Command Line Tools if not present (avoids popup)
    if ! xcode-select -p >/dev/null 2>&1; then
        echo "  → Installing Xcode Command Line Tools..."
        # Create a temporary file to trigger automatic installation
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        # Find the latest Command Line Tools package
        PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -1 | sed 's/^[^C]* //')
        if [[ -n "$PROD" ]]; then
            softwareupdate -i "$PROD" --verbose
        else
            # Fallback method if softwareupdate doesn't list CLT
            xcode-select --install
            echo "    Please wait for Command Line Tools installation to complete..."
            until xcode-select -p >/dev/null 2>&1; do
                sleep 5
            done
        fi
        # Clean up the trigger file
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        echo "  ✓ Command Line Tools installation completed"
    else
        echo "  ✓ Command Line Tools already installed"
    fi

    # Install Homebrew if it isn't installed already
    if ! command -v brew >/dev/null 2>&1; then
        echo "  → Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Evaluate homebrew correctly for the current session
        if [[ $(uname -m) == 'arm64' ]]; then
            # Apple Silicon Mac
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Intel Mac
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        echo "  ✓ Homebrew installation completed"
    else
        echo "  ✓ Homebrew already installed"
    fi

    # Install GNU Stow if not available
    if ! command -v stow >/dev/null 2>&1; then
        echo "  → Installing GNU Stow..."
        brew install stow
        echo "  ✓ GNU Stow installation completed"
    else
        echo "  ✓ GNU Stow already installed"
    fi

    echo ""
    echo "✓ Essential dependencies are ready!"
    echo ""
}

# Install essential dependencies before proceeding
bootstrap_dependencies

# Function to backup existing files before stow operations
backup_existing_files() {
    if [[ $backup == 0 ]]; then
        echo "Skipping backup as requested..."
        return 0
    fi

    echo "Checking for existing files that would be overwritten..."

    # Create timestamped backup directory
    local backup_timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir="$HOME/.dotfiles-backup-$backup_timestamp"
    local manifest_file="$backup_dir/backup-manifest.txt"

    # Use stow simulation with verbose output to detect actual conflicts
    local stow_output
    stow_output=$(stow -n -d "$PWD" -t "$HOME" home --verbose=3 2>&1)

    # Filter files that are causing conflicts.
    local actual_conflicts
    actual_conflicts=$(echo "$stow_output" | grep "CONFLICT when stowing" | sed -n 's/.*over existing target \([^[:space:]]*\).*/\1/p')

    if [[ -z "$actual_conflicts" ]]; then
        echo "No existing files would be overwritten. Proceeding without backup."
        return 0
    fi

    # Check available disk space (require at least 100MB free)
    local available_space
    available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    # $available_space is in `KB`
    if [[ $available_space -lt 102400 ]]; then
        die "ERROR: Insufficient disk space for backup. At least 100MB required."
    fi

    echo "Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir"
    echo "Manifest file path: $manifest_file"

    # Initialize manifest file
    echo "Backup created on: $(date)" > "$manifest_file"
    echo "Original dotfiles repository: $PWD" >> "$manifest_file"
    echo "" >> "$manifest_file"
    echo "Files that would be overwritten:" >> "$manifest_file"
    echo "$actual_conflicts" >> "$manifest_file"
    echo "" >> "$manifest_file"
    echo "Files backed up:" >> "$manifest_file"

    local files_backed_up=0

    # Backup all conflicting files.
    for relative_path in $actual_conflicts; do
        # Validate paths are relative and safe
        if [[ "$relative_path" =~ ^/ ]] || [[ "$relative_path" =~ \.\. ]]; then
            echo "WARNING: Unsafe path detected: $relative_path"
            echo "  ✗ $relative_path (unsafe path)" >> "$manifest_file"
            continue
        fi

        local target_file="$HOME/$relative_path"

        # Check if target file exists
        if [[ -e "$target_file" ]]; then
            # File exists and would conflict, backup it
            local backup_file="$backup_dir/$relative_path"
            local backup_parent_dir
            backup_parent_dir=$(dirname "$backup_file")

            mkdir -p "$backup_parent_dir"

            # Copy file preserving permissions and metadata.
            if cp -p "$target_file" "$backup_file" 2>/dev/null; then
                # Verify backup file exists before removing original
                if [[ -f "$backup_file" ]]; then
                    # Remove the original file to prevent stow conflicts
                    if rm "$target_file" 2>/dev/null; then
                        echo "  ✓ $relative_path (backed up and removed)" >> "$manifest_file"
                        echo "Backed up and removed: $relative_path"
                        ((files_backed_up++))
                    else
                        echo "  ⚠ $relative_path (backed up but removal failed)" >> "$manifest_file"
                        die "ERROR: Failed to remove $relative_path after backup - check permissions"
                    fi
                else
                    echo "  ✗ $relative_path (backup verification failed)" >> "$manifest_file"
                    die "ERROR: Backup verification failed for $relative_path"
                fi
            else
                echo "  ✗ $relative_path (copy failed)" >> "$manifest_file"
                die "ERROR: Failed to backup $relative_path - check permissions for $(dirname "$backup_file")"
            fi
        else
            die "ERROR: Conflict file $relative_path doesn't exist at target"
        fi
    done

    if [[ $files_backed_up -gt 0 ]]; then
        echo ""
        echo "Backup completed successfully!"
        echo "  Location: $backup_dir"
        echo "  Files backed up: $files_backed_up"
        echo "  Manifest: $manifest_file"
        echo ""
    else
        # Remove empty backup directory if no files were actually backed up
        rmdir "$backup_dir" 2>/dev/null || true
        echo "No files needed backup. Proceeding with installation."
        echo ""
    fi

    return 0
}

echo "======================================================================"
echo "                     Backup & File Management"
echo "======================================================================"
echo ""

# Backup existing files before stow operations
echo "Step 2/5: Backing up existing files and linking dotfiles..."
backup_existing_files

# Stow will handle all dotfile symlinking.
# The home/ directory structure mirrors the $HOME directory structure
echo "Linking dotfiles into $HOME/ using stow..."
stow -d "$PWD" -t "$HOME" home --verbose=1
echo "✓ Dotfiles linked successfully!"
echo ""

echo "======================================================================"
echo "                      System Configuration"
echo "======================================================================"
echo ""

# Make terminal authentication easier by using Touch ID instead of password, if Mac supports it.
echo "Step 3/5: Configuring system authentication and user settings..."
echo ""
if [[ $(uname -m) == 'arm64' ]]; then
    echo "  → Configuring Touch ID for sudo authentication on Apple Silicon Mac..."
    # Check if Touch ID line already exists to avoid duplicates
    if ! sudo grep -q "pam_tid.so" /etc/pam.d/sudo; then
        # Backup the original file before modifying
        sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
        sudo sed -i '' "3i\\
auth       sufficient     pam_tid.so
" /etc/pam.d/sudo
        echo "  ✓ Touch ID authentication enabled for sudo commands"
    else
        echo "  ✓ Touch ID authentication already configured"
    fi
else
    echo "  ✓ Skipping Touch ID configuration (Intel Mac detected)"
fi

# File to store any API keys in.
echo "  → Creating API keys storage file..."
touch ~/.api_keys
echo "  ✓ API keys file created at ~/.api_keys"

# Configure git.
echo "  → Configuring Git with provided credentials..."
git config --global user.email "$email"
git config --global user.name "$name"
git config --global core.editor "nvim"
git config --global core.filemode false
git config --global status.showuntrackedfiles all
git config --global status.submodulessummary 1
git config --global pull.rebase false
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global merge.conflictstyle "zdiff3"
git config --global color.ui true

# Include delta configuration from separate file.
git config --global include.path "~/.gitconfig-delta"
echo "  ✓ Git configuration completed"

# Create SSH key pair.
echo "  → Generating SSH key pair..."
ssh-keygen -t ed25519 -C "$email"
echo "  ✓ SSH key pair generated"
echo ""

echo "======================================================================"
echo "                    Package Installation & Setup"
echo "======================================================================"
echo ""

# Run installation scripts.
echo "Step 4/5: Installing packages and configuring system components..."
echo ""

echo "  → Installing Homebrew packages and development tools..."
bash "$PWD/scripts/packages.sh"
echo "  ✓ All packages installed successfully"
echo ""

# Configure Tmux colors.
echo "  → Configuring Tmux terminal colors..."
tic -x "$PWD/utils/terminfo/xterm-256color-italic.terminfo"
tic -x "$PWD/utils/terminfo/tmux-256color.terminfo"
echo "  ✓ Tmux terminal colors configured"
echo ""

# Configure MacOS settings.
echo "  → Applying macOS system preferences and settings..."
bash "$PWD/scripts/macos.sh"
echo "  ✓ macOS system settings configured"
echo ""

echo "======================================================================"
echo "                      Installation Complete!"
echo "======================================================================"
echo ""
echo "Step 5/5: Summary of completed installation..."
echo ""
echo "✓ Essential dependencies installed (Homebrew, Stow, Command Line Tools)"
if [[ $backup == 1 ]]; then
    echo "✓ Existing dotfiles backed up (if any conflicts found)"
else
    echo "✓ Backup skipped as requested"
fi
echo "✓ Dotfiles linked to home directory"
if [[ $(uname -m) == 'arm64' ]]; then
    echo "✓ Touch ID configured for sudo authentication"
else
    echo "✓ Touch ID configuration skipped (Intel Mac)"
fi
echo "✓ Git configured with user credentials ($name <$email>)"
echo "✓ SSH key pair generated"
echo "✓ API keys storage file created"
echo "✓ Development packages and tools installed"
echo "✓ Terminal colors configured for Tmux"
echo "✓ macOS system preferences applied"
echo ""
echo "🎉 Your macOS development environment is now ready!"
echo ""
echo "Next steps:"
echo "  • Add your SSH public key to GitHub/GitLab"
echo "  • Restart your terminal or run 'source ~/.zshrc'"
echo "  • Review installed applications and configure as needed"
echo ""
echo "SSH public key location: $HOME/.ssh/id_ed25519.pub"
echo "Dotfiles backup location: $HOME/.dotfiles-backup-* (if created)"
echo ""
echo "======================================================================"
