#!/usr/bin/env bash

# Enable strict error handling
set -e          # Exit on any command failure
set -o pipefail # Fail on any command in a pipeline

# Get script directory for reliable script invocations
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Source required utilities
source "${SCRIPT_DIR}/../utils/logging.sh"
source "${SCRIPT_DIR}/../utils/platform.sh"

# Function to configure system authentication and user settings
configure_system() {
    local email="$1"
    local name="$2"
    local stow_dir="$3"
    local brew_prefix="$4"

    # Validate required parameters
    if [[ -z ${email} || -z ${name} || -z ${stow_dir} || -z ${brew_prefix} ]]; then
        die "ERROR: Missing required parameters. Usage: configure_system <email> <name> <stow_dir> <brew_prefix>"
    fi

    # Make terminal authentication easier by using Touch ID instead of password, if Mac supports it.
    print_action "Configuring Touch ID for sudo authentication on compatible hardware..."
    # Check if Touch ID line already exists to avoid duplicates
    if ! sudo grep -q "pam_tid.so" /etc/pam.d/sudo; then
        # Backup the original file before modifying
        sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
        # This syntax is required to work properly with macOS's inbuilt version of `sed`
        sudo sed -i '' '3i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
        print_success "Touch ID authentication enabled for sudo commands"
    else
        print_success "Touch ID authentication already configured"
    fi

    # File to store any API keys in.
    print_action "Creating API keys storage file..."
    touch ~/.api_keys
    print_success "API keys file created at ~/.api_keys (if not already present)"

    # Configure git.
    print_action "Configuring Git with provided credentials..."
    git config --global user.email "${email}"
    git config --global user.name "${name}"
    git config --global core.editor "nvim"
    git config --global core.filemode false
    git config --global status.showuntrackedfiles all
    git config --global status.submodulesummary 1
    git config --global pull.rebase false
    git config --global init.defaultBranch main
    git config --global push.autoSetupRemote true
    git config --global merge.conflictstyle "zdiff3"
    git config --global color.ui true

    # Include delta configuration from separate file.
    git config --global include.path "${HOME}/.gitconfig-delta"
    print_success "Git configuration completed"

    # Create SSH key pair.
    print_action "Generating SSH key pair..."

    # Check if SSH keys already exist
    if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
        print_success "SSH key already exists at ${HOME}/.ssh/id_ed25519"
        print_detail "Skipping key generation to avoid overwriting existing key" 3
    else
        # Generate SSH key non-interactively
        ssh-keygen -t ed25519 -C "${email}" -f "${HOME}/.ssh/id_ed25519" -N "" -q

        # Verify SSH key generation was successful
        if [[ -f "${HOME}/.ssh/id_ed25519" && -f "${HOME}/.ssh/id_ed25519.pub" ]]; then
            print_success "SSH key pair generated successfully"

            # Verify SSH directory permissions
            ssh_dir_perms=$(stat -f "%A" "${HOME}/.ssh" 2>/dev/null || echo "unknown")
            if [[ ${ssh_dir_perms} == "700" ]]; then
                print_success "SSH directory permissions are correct (700)"
            else
                print_warning "SSH directory permissions may need adjustment"
                echo "    Expected: 700, Current: ${ssh_dir_perms}"
            fi
        else
            die "ERROR: SSH key generation failed - key files not found"
        fi
    fi
    echo ""

    # Configure modern shells.
    print_action "Configuring modern shells..."

    # Add modern Bash 4 to /etc/shells (installed via Brewfile).
    if ! grep -F -q "${brew_prefix}/bin/bash" /etc/shells; then
        print_detail "Adding Bash to /etc/shells..." 3
        echo "${brew_prefix}/bin/bash" | sudo tee -a /etc/shells >/dev/null
        print_success "Bash added to /etc/shells"
    else
        print_success "Bash already in /etc/shells"
    fi

    # Add modern Zsh to /etc/shells and set as default shell (installed via Brewfile).
    if ! grep -F -q "${brew_prefix}/bin/zsh" /etc/shells; then
        print_detail "Adding Zsh to /etc/shells..." 3
        echo "${brew_prefix}/bin/zsh" | sudo tee -a /etc/shells >/dev/null
        print_detail "Changing default shell to Zsh..." 3
        chsh -s "${brew_prefix}/bin/zsh"
        print_success "Zsh configured as default shell"
    else
        print_success "Zsh already configured"
    fi
    echo ""

    # Set up Perl correctly.
    print_detail "Configuring Perl module installation path..." 3
    PERL_MM_OPT="INSTALL_BASE=${HOME}/perl5" PERL_MM_USE_DEFAULT=1 cpan local::lib
    print_success "Perl configuration completed"

    # Set up FZF autocompletion and keybindings.
    print_detail "Installing FZF autocompletion and keybindings..." 3
    "${brew_prefix}/opt/fzf/install" --key-bindings --completion --no-update-rc
    print_success "FZF configuration completed"
    echo ""

    # Configure Tmux colors.
    print_action "Configuring Tmux terminal colors..."
    tic -x "${stow_dir}/utils/terminfo/xterm-256color-italic.terminfo"
    tic -x "${stow_dir}/utils/terminfo/tmux-256color.terminfo"
    print_success "Tmux terminal colors configured"
    echo ""

    # Configure MacOS settings.
    print_action "Applying macOS system preferences and settings..."
    bash "${stow_dir}/scripts/macos.sh"
    print_success "macOS system settings configured"
    echo ""
}

# Execute configuration if script is run directly
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    configure_system "$@"
fi
