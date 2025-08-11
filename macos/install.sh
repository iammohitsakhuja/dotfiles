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
        echo "Backup = $backup"
        echo "Email = $email"
        echo "Name = $name"
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

# Validate stow is available
if ! command -v stow >/dev/null 2>&1; then
    die "ERROR: GNU Stow is required but not installed"
fi

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
                echo "  ✓ $relative_path" >> "$manifest_file"
                echo "Backed up: $relative_path"
                ((files_backed_up++))
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

# Backup existing files before stow operations
backup_existing_files

# Stow will handle all dotfile symlinking.
# The home/ directory structure mirrors the $HOME directory structure
echo "Linking dotfiles into $HOME/ using stow ..."
stow -d $PWD -t $HOME home --verbose=1


# Ask for administrator password.
echo -e "\nInstallation requires administrator authentication..."
sudo -v

# Keep `sudo` alive i.e. update existing time stamp until `./install.sh` has
# finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Make terminal authentication easier by using Touch ID instead of password, if Mac supports it.
# TODO: Add support for Intel Macs with Touch ID.
if [[ $(uname -m) == 'arm64' ]]; then
    # Backup the original file.
    sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
    sudo sed -i "3i auth       sufficient     pam_tid.so" /etc/pam.d/sudo
fi

# File to store any API keys in.
touch ~/.api_keys

# Configure git.
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

# Create SSH key pair.
ssh-keygen -t ed25519 -C "$email"

# Run installation scripts.
echo -e "\nRunning installation scripts..."

echo "Installing packages..."
bash $PWD/scripts/packages.sh
echo -e "Packages installed successfully!\n"

# Configure Tmux colors.
echo "Configuring Tmux colors..."
tic -x $PWD/utils/terminfo/xterm-256color-italic.terminfo
tic -x $PWD/utils/terminfo/tmux-256color.terminfo
echo -e "Tmux colors configured successfully!\n"

# Configure MacOS settings.
echo "Configuring MacOS settings..."
bash $PWD/scripts/macos.sh
echo -e "MacOS settings configured successfully!\n"
