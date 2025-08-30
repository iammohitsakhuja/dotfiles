#!/usr/bin/env bash

# Mac App Store installation utilities for dotfiles
# This file provides functions for handling Mac App Store app installations via mas command.
# Functions handle Apple ID authentication and app installation with user interaction.

# Source shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
source "$(dirname "${BASH_SOURCE[0]}")/platform.sh"

# Function to check if current user is signed into Apple ID
# Returns 0 if signed in, 1 if not
is_signed_into_apple_id() {
    local plistPath="${HOME}/Library/Preferences/MobileMeAccounts.plist"

    [[ -f ${plistPath} ]] && defaults read "${plistPath}" Accounts 2>/dev/null | grep -q 'AccountID = "'
}

# Function to prompt user for Apple ID login
prompt_apple_account_login() {
    echo ""
    echo "======================================================================"
    echo "Apple ID Sign-In Required"
    echo "======================================================================"
    echo ""
    echo "The Brewfile contains Mac App Store applications that require"
    echo "you to be signed into your Apple ID in the App Store."
    echo ""
    echo "Note: Apple ID login (System Settings) and App Store login are separate."
    echo "You may be signed into Apple ID but still need to sign into App Store."
    echo "Unfortunately, we cannot detect App Store login status."
    echo "So, this means that you may not see this prompt if you are signed into"
    echo "Apple ID but not App Store."
    echo "However, when mas begins installing apps, it will fail if you are not"
    echo "signed into App Store, so we are still good - just not ideal."
    echo ""
    echo "Options:"
    echo "  1) Sign in to App Store now (opens App Store)"
    echo "  2) Skip Mac App Store apps for now"
    echo ""
    read -r -p "Your choice [1/2]: " choice

    case ${choice} in
    1)
        print_action "Opening App Store for sign-in..."
        # Open App Store application
        # Hack to force Login page/dialog: we open Updates page
        open "macappstore://showUpdatesPage"

        echo ""
        echo "Please sign in to your Apple ID in the App Store."
        echo "Once signed in, press Enter to continue..."
        read -r

        # Check again if signed in
        # shellcheck disable=SC2310
        if is_signed_into_apple_id; then
            print_success "Successfully signed into Apple ID!"
            return 0
        else
            print_warning "Still not signed in. Skipping Mac App Store apps."
            return 2
        fi
        ;;
    2)
        print_warning "Skipping Mac App Store apps installation."
        return 2
        ;;
    *)
        print_warning "Invalid choice. Skipping Mac App Store apps."
        return 2
        ;;
    esac
}

# Function to install MAS apps from Brewfile
install_mas_apps() {
    print_action "Installing Mac App Store apps..."
    if ! brew bundle --file "$(dirname "${BASH_SOURCE[0]}")/../Brewfile.mas"; then
        print_warning "Failed to install Mac App Store apps"
        return 1
    fi
    print_success "Mac App Store apps installation completed!"
}

# Main orchestration function for Mac App Store installation
handle_mas_installation() {
    # Ensure mas is installed
    install_package_if_missing "mas"

    # Check if signed into Apple ID
    print_action "Checking Apple ID sign-in status..."
    # shellcheck disable=SC2310
    if is_signed_into_apple_id; then
        print_success "Already signed into Apple ID"
        install_mas_apps
        return 0
    else
        print_warning "Not signed into Apple ID"

        # Prompt user for action
        if prompt_apple_account_login; then
            install_mas_apps
            return 0
        else
            echo ""
            print_warning "Mac App Store apps skipped."
            echo ""
            return 2
        fi
    fi
}
