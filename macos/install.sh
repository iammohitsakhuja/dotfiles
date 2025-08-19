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

    # Install jq for JSON processing if not available
    if ! command -v jq >/dev/null 2>&1; then
        echo "  → Installing jq for JSON processing..."
        brew install jq
        echo "  ✓ jq installation completed"
    else
        echo "  ✓ jq already installed"
    fi

    echo ""
    echo "✓ Essential dependencies are ready!"
    echo ""
}

# Install essential dependencies before proceeding
bootstrap_dependencies

echo "======================================================================"
echo "                     Backup & File Management"
echo "======================================================================"
echo ""

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
    local manifest_file="$backup_dir/backup-manifest.json"

    # Use stow simulation with verbose output to detect actual conflicts
    local stow_output
    stow_output=$(stow -n -d "$PWD" -t "$HOME" home --verbose=3 2>&1)

    # Filter files that are causing conflicts - catch both types of conflicts
    local stowing_conflicts
    stowing_conflicts=$(echo "$stow_output" | grep "CONFLICT when stowing" | sed -n 's/.*over existing target \([^[:space:]]*\).*/\1/p')

    local ownership_conflicts
    ownership_conflicts=$(echo "$stow_output" | grep "CONFLICT when stowing" | sed -n 's/.*existing target is not owned by stow: \([^[:space:]]*\).*/\1/p')

    # Combine both types of conflicts
    local actual_conflicts
    actual_conflicts=$(printf "%s\n%s" "$stowing_conflicts" "$ownership_conflicts" | grep -v '^$' | sort -u)

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

    # Show conflict summary to user
    local stowing_count=$(echo "$stowing_conflicts" | grep -c . 2>/dev/null || echo 0)
    local ownership_count=$(echo "$ownership_conflicts" | grep -c . 2>/dev/null || echo 0)
    echo "Found conflicts: $stowing_count stowing conflicts, $ownership_count ownership conflicts"

    # Initialize JSON manifest file
    local backup_date=$(date -Iseconds)
    local stowing_conflicts_json
    local ownership_conflicts_json

    # Convert conflicts to JSON arrays
    if [[ -n "$stowing_conflicts" ]]; then
        stowing_conflicts_json=$(echo "$stowing_conflicts" | jq -R -s 'split("\n") | map(select(length > 0))')
    else
        stowing_conflicts_json="[]"
    fi

    if [[ -n "$ownership_conflicts" ]]; then
        ownership_conflicts_json=$(echo "$ownership_conflicts" | jq -R -s 'split("\n") | map(select(length > 0))')
    else
        ownership_conflicts_json="[]"
    fi

    local total_conflicts
    total_conflicts=$(echo "$actual_conflicts" | grep -c . 2>/dev/null || echo 0)

    # Create initial JSON structure
    cat > "$manifest_file" << EOF
{
  "metadata": {
    "backup_date": "$backup_date",
    "repository_path": "$PWD",
    "backup_version": "1.0"
  },
  "conflicts": {
    "stowing_conflicts": $stowing_conflicts_json,
    "ownership_conflicts": $ownership_conflicts_json,
    "total_count": $total_conflicts
  },
  "files": [],
  "summary": {
    "files_backed_up": 0,
    "files_failed": 0,
    "backup_size_total": 0
  }
}
EOF

    local files_backed_up=0
    local files_failed=0
    local total_backup_size=0

    # Helper function to add file entry to JSON manifest
    add_file_to_manifest() {
        local file_path="$1"
        local status="$2"
        local conflict_type="$3"
        local file_size="$4"

        # Create temporary file with new entry
        local temp_manifest=$(mktemp)
        jq --arg path "$file_path" --arg status "$status" --arg type "$conflict_type" --argjson size "$file_size" \
           '.files += [{"path": $path, "status": $status, "conflict_type": $type, "backup_size": $size}]' \
           "$manifest_file" > "$temp_manifest"
        mv "$temp_manifest" "$manifest_file"
    }

    # Helper function to update manifest summary
    update_manifest_summary() {
        local temp_manifest=$(mktemp)
        jq --argjson backed_up "$files_backed_up" --argjson failed "$files_failed" --argjson total_size "$total_backup_size" \
           '.summary.files_backed_up = $backed_up | .summary.files_failed = $failed | .summary.backup_size_total = $total_size' \
           "$manifest_file" > "$temp_manifest"
        mv "$temp_manifest" "$manifest_file"
    }

    # Backup all conflicting files.
    for relative_path in $actual_conflicts; do
        # Validate paths are relative and safe
        if [[ "$relative_path" =~ ^/ ]] || [[ "$relative_path" =~ \.\. ]]; then
            echo "WARNING: Unsafe path detected: $relative_path"
            add_file_to_manifest "$relative_path" "unsafe_path" "unknown" 0
            ((files_failed++))
            continue
        fi

        local target_file="$HOME/$relative_path"

        # Determine conflict type
        local conflict_type="unknown"
        if echo "$stowing_conflicts" | grep -q "^$relative_path$"; then
            conflict_type="stowing"
        elif echo "$ownership_conflicts" | grep -q "^$relative_path$"; then
            conflict_type="ownership"
        fi

        # Check if target file exists
        if [[ -e "$target_file" ]]; then
            # Get file size
            local file_size
            if [[ -f "$target_file" ]]; then
                file_size=$(stat -f%z "$target_file" 2>/dev/null || echo 0)
            else
                file_size=0
            fi

            # File exists and would conflict, backup it
            local backup_file="$backup_dir/$relative_path"
            local backup_parent_dir
            backup_parent_dir=$(dirname "$backup_file")

            mkdir -p "$backup_parent_dir"

            # Move file to backup location (atomic operation)
            if mv "$target_file" "$backup_file" 2>/dev/null; then
                add_file_to_manifest "$relative_path" "moved_successfully" "$conflict_type" "$file_size"
                echo "Moved to backup: $relative_path"
                ((files_backed_up++))
                ((total_backup_size += file_size))
            else
                add_file_to_manifest "$relative_path" "move_failed" "$conflict_type" 0
                ((files_failed++))
                die "ERROR: Failed to move $relative_path to backup - check permissions"
            fi
        else
            add_file_to_manifest "$relative_path" "target_missing" "$conflict_type" 0
            ((files_failed++))
            die "ERROR: Conflict file $relative_path doesn't exist at target"
        fi
    done

    # Update final summary in manifest
    update_manifest_summary

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
        # This syntax is required to work properly with macOS's inbuilt version of `sed`
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
