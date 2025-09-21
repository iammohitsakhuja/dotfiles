#!/usr/bin/env bash

# System configuration utilities for dotfiles
# This file provides system setup functions with consistent error handling.

# Source shared utilities
SYSTEM_SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
if [[ ! -d ${SYSTEM_SCRIPT_DIR} ]] || [[ ${SYSTEM_SCRIPT_DIR} == "${BASH_SOURCE[0]}" ]]; then
    # Fallback: assume we're being sourced from repo root
    SYSTEM_SCRIPT_DIR="macos/utils"
fi
source "${SYSTEM_SCRIPT_DIR}/logging.sh"
source "${SYSTEM_SCRIPT_DIR}/platform.sh"

# Function to register launch agents
register_launch_agents() {
    local plist_name="$1"
    local plist_path="${HOME}/Library/LaunchAgents/${plist_name}"

    # Validate required parameter
    if [[ -z ${plist_name} ]]; then
        die "ERROR: Missing required parameter. Usage: register_launch_agents <plist_name>"
    fi

    # Check if plist file exists
    if [[ ! -f ${plist_path} ]]; then
        print_warning "Launch agent plist not found: ${plist_path}"
        print_detail "Skipping registration for ${plist_name}"
        return 0
    fi

    # Validate plist syntax
    print_action "Validating plist syntax for ${plist_name}..."
    if ! plutil -lint "${plist_path}" >/dev/null 2>&1; then
        print_error "Invalid plist syntax in ${plist_path}"
        print_detail "Run 'plutil -lint ${plist_path}' for details"
        return 1
    fi
    print_detail "Plist syntax validation passed"

    # Extract label from plist for better error handling
    local label
    label=$(plutil -extract Label raw "${plist_path}" 2>/dev/null || echo "${plist_name%.*}")

    # Check if already loaded using modern list command
    if launchctl print "gui/$(id -u)/${label}" >/dev/null 2>&1; then
        print_success "Launch agent already registered: ${label}"
        return 0
    fi

    # Register using modern bootstrap command
    print_action "Registering launch agent: ${label}..."
    if launchctl bootstrap "gui/$(id -u)" "${plist_path}" 2>/dev/null; then
        print_success "Launch agent registered successfully: ${label}"
    else
        local exit_code=$?
        case ${exit_code} in
        5)
            print_warning "Launch agent registration failed (already loaded or permission issue): ${label}"
            print_detail "This is usually harmless if the agent is already active"
            ;;
        *)
            print_error "Launch agent registration failed with exit code ${exit_code}: ${label}"
            print_detail "Check plist permissions and syntax in ${plist_path}"
            return "${exit_code}"
            ;;
        esac
    fi
}

# Function to configure system authentication and user settings
configure_system_settings() {
    local email="$1"
    local name="$2"
    local stow_dir="$3"
    local brew_prefix="$4"

    # Validate required parameters
    if [[ -z ${email} || -z ${name} || -z ${stow_dir} || -z ${brew_prefix} ]]; then
        die "ERROR: Missing required parameters. Usage: configure_system_settings <email> <name> <stow_dir> <brew_prefix>"
    fi

    # Make terminal authentication easier by using Touch ID instead of password, if Mac supports it.
    print_action "Configuring Touch ID for sudo authentication on compatible hardware..."
    # Check if Touch ID line already exists to avoid duplicates
    if ! sudo grep -q "pam_tid.so" /etc/pam.d/sudo; then
        # Backup the original file before modifying
        sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
        # Force usage of macOS' in-built `sed` over any other `sed` as syntax is different.
        # This syntax is required to work properly with macOS's inbuilt version of `sed`
        sudo /usr/bin/sed -i '' '3i\
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
        print_detail "Skipping key generation to avoid overwriting existing key"
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
    print_newline

    # Configure modern shells.
    print_action "Configuring modern shells..."

    # Add modern Bash 4 to /etc/shells (installed via Brewfile).
    if ! grep -F -q "${brew_prefix}/bin/bash" /etc/shells; then
        print_detail "Adding Bash to /etc/shells..."
        echo "${brew_prefix}/bin/bash" | sudo tee -a /etc/shells >/dev/null
        print_detail "Bash added to /etc/shells"
    else
        print_detail "Bash already in /etc/shells"
    fi

    # Add modern Zsh to /etc/shells and set as default shell (installed via Brewfile).
    if ! grep -F -q "${brew_prefix}/bin/zsh" /etc/shells; then
        print_detail "Adding Zsh to /etc/shells..."
        echo "${brew_prefix}/bin/zsh" | sudo tee -a /etc/shells >/dev/null
        print_detail "Changing default shell to Zsh..."
        chsh -s "${brew_prefix}/bin/zsh"
        print_detail "Zsh configured as default shell"
    else
        print_detail "Zsh already configured"
    fi

    print_success "Shell configuration completed"
    print_newline

    # Set up Perl correctly.
    print_action "Configuring Perl module installation path..."
    PERL_MM_OPT="INSTALL_BASE=${HOME}/perl5" PERL_MM_USE_DEFAULT=1 cpan local::lib
    print_success "Perl configuration completed"
    print_newline

    # Set up FZF autocompletion and keybindings.
    print_action "Installing FZF autocompletion and keybindings..."
    "${brew_prefix}/opt/fzf/install" --key-bindings --completion --no-update-rc
    print_success "FZF configuration completed"
    print_newline

    # Configure Tmux colors.
    print_action "Configuring Tmux terminal colors..."
    tic -x "${stow_dir}/utils/terminfo/xterm-256color-italic.terminfo"
    tic -x "${stow_dir}/utils/terminfo/tmux-256color.terminfo"
    print_success "Tmux terminal colors configured"
    print_newline

    # Register launch agents.
    print_action "Registering launch agents..."
    register_launch_agents "local.removecapslockdelay.plist"
    print_success "Launch agent registration completed"
    print_newline

    # Configure MacOS settings.
    print_action "Applying macOS system preferences and settings..."
    configure_macos_preferences
    print_success "macOS system settings configured"
    print_newline
}

# Function to configure macOS system preferences and settings
configure_macos_preferences() {
    # This file contains hand-picked settings from Mathias Bynens' MacOS' dotfiles.
    # Full list of settings is available here: https://github.com/mathiasbynens/dotfiles/blob/master/.macos

    # Close any open System Preferences panes, to prevent them from overriding any settings we're about to change.
    osascript -e 'tell application "System Preferences" to quit'

    ###############################################################################
    # General UI/UX                                                               #
    ###############################################################################

    # Disable the sound effects on boot.
    sudo nvram SystemAudioVolume=" "

    # Show scrollbars automatically.
    defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
    # Possible values: `WhenScrolling`, `Automatic` and `Always`.

    # Jump to the spot that's clicked on the click of the scrollbar.
    defaults write NSGlobalDomain AppleScrollerPagingBehavior -bool true
    # `true` for jumping to the spot that's clicked. `false` for jumping to the next page.

    # Use 24-hour clock by default.
    defaults write com.apple.menuextra.clock DateFormat -string 'EEE d MMM  HH:mm:ss'

    # Increase window resize speed for Cocoa applications.
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    # Expand save panel by default.
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default.
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Automatically quit printer app once the print jobs complete.
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    # Disable the "Are you sure you want to open this application?" dialog.
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Disable automatic capitalization as it's annoying when typing code.
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart dashes as they're annoying when typing code.
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable automatic period substitution as it's annoying when typing code.
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # Disable smart quotes as they're annoying when typing code.
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable auto-correct.
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    ###############################################################################
    # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
    ###############################################################################

    # Increase sound quality for Bluetooth headphones/headsets.
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # Disable press-and-hold for keys in favor of key repeat.
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Set a blazingly fast keyboard repeat rate.
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

    # Set language and text formats.
    defaults write NSGlobalDomain AppleLanguages -array "en-US"
    defaults write NSGlobalDomain AppleLocale -string "en_US"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
    defaults write NSGlobalDomain AppleMetricUnits -bool true
    defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

    ###############################################################################
    # Screen                                                                      #
    ###############################################################################

    # Fix for blurry fonts on non-Retina displays on MacOS Sequoia and above.
    # Uncomment to apply it during installation.
    # Or run it as a one-off command.
    # Possible values are: 0 (off), 1 (low), 2 (medium/default), 3 (high)
    # defaults -currentHost write -globalDomain AppleFontSmoothing -int 0

    ###############################################################################
    # Finder                                                                      #
    ###############################################################################

    # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons.
    defaults write com.apple.finder QuitMenuItem -bool true

    # Set Desktop as the default location for new Finder windows.
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

    # Set ~/Documents/screenshots as the default location for screenshots.
    # By default, it is ~/Desktop.
    # This helps keep the Desktop clean.
    mkdir -p "${HOME}/Documents/screenshots"
    defaults write com.apple.screencapture location "${HOME}/Documents/screenshots"

    # Show icons for hard drives and removable media on the desktop.
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Show hidden files by default.
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show all filename extensions.
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Show status bar.
    defaults write com.apple.finder ShowStatusBar -bool true

    # Show path bar.
    defaults write com.apple.finder ShowPathbar -bool true

    # Display full POSIX path as Finder window title.
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name.
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default.
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Enable spring loading for directories.
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    # Remove the spring loading delay for directories.
    defaults write NSGlobalDomain com.apple.springing.delay -float 0

    # Avoid creating .DS_Store files on network or USB volumes.
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Use Column view in all Finder windows by default.
    # Four-letter codes for the view modes: \`icnv\`, \`Nlsv\`, \`clmv\`, \`Flwv\`.
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

    # Expand the following File Info panes:
    # "General", "Open with", and "Sharing & Permissions".
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true

    ###############################################################################
    # Dock and Dashboard                                                          #
    ###############################################################################

    # Set the icon size of Dock items to 39 pixels.
    defaults write com.apple.dock tilesize -int 39

    # Minimize windows into their application's icon.
    defaults write com.apple.dock minimize-to-application -bool true

    # Enable spring loading for all Dock items.
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    # Show indicator lights for open applications in the Dock.
    defaults write com.apple.dock show-process-indicators -bool true

    # Speed up Mission Control animations.
    defaults write com.apple.dock expose-animation-duration -float 0.1

    # Disable Dashboard.
    defaults write com.apple.dashboard mcx-disabled -bool true

    # Don't show Dashboard as a Space.
    defaults write com.apple.dock dashboard-in-overlay -bool true

    # Don't automatically rearrange Spaces based on most recent use.
    defaults write com.apple.dock mru-spaces -bool false

    # Automatically hide and show the Dock.
    defaults write com.apple.dock autohide -bool true

    # Remove the auto-hiding Dock delay.
    defaults write com.apple.dock autohide-delay -float 0

    # Shorten the animation when hiding/showing the Dock.
    defaults write com.apple.dock autohide-time-modifier -float 0.5

    # Make Dock icons of hidden applications translucent.
    defaults write com.apple.dock showhidden -bool true

    # Don't show recent applications in Dock.
    defaults write com.apple.dock show-recents -bool false

    # Add iOS & Watch Simulator to Launchpad
    sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
    sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

    # Hot corners
    # Possible values:
    #  0: no-op
    #  2: Mission Control
    #  3: Show application windows
    #  4: Desktop
    #  5: Start screen saver
    #  6: Disable screen saver
    #  7: Dashboard
    # 10: Put display to sleep
    # 11: Launchpad
    # 12: Notification Center
    # 13: Lock Screen
    # Top left screen corner → Mission Control
    # defaults write com.apple.dock wvous-tl-corner -int 2
    # defaults write com.apple.dock wvous-tl-modifier -int 0
    # Top right screen corner → Desktop
    # defaults write com.apple.dock wvous-tr-corner -int 4
    # defaults write com.apple.dock wvous-tr-modifier -int 0
    # Bottom left screen corner → Start screen saver
    defaults write com.apple.dock wvous-bl-corner -int 5
    defaults write com.apple.dock wvous-bl-modifier -int 0

    # Stop the bottom right screen corner from opening Quick Note.
    defaults write com.apple.dock wvous-br-corner -int 1
    defaults write com.apple.dock wvous-br-modifier -int 0

    ###############################################################################
    # Control Center and Menu Bar                                                 #
    ###############################################################################

    # Show battery percentage in Menu Bar.
    defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true

    # Change spacing and padding in the Menu Bar.
    defaults write -globalDomain NSStatusItemSpacing -int 12
    defaults write -globalDomain NSStatusItemSelectionPadding 8

    # Automatically hide and show the Menu Bar.
    defaults write NSGlobalDomain _HIHideMenuBar -bool true

    ###############################################################################
    # QuickLook                                                                   #
    ###############################################################################

    # Get rid of QuickLook plugin warning that MacOS Catalina (and above) throw.
    xattr -d -r com.apple.quarantine ~/Library/QuickLook

    ###############################################################################
    # Safari                                                                      #
    ###############################################################################

    # Privacy: don't send search queries to Apple.
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true

    # Show the full URL in the address bar (note: this still hides the scheme).
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Prevent Safari from opening 'safe' files automatically after downloading.
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

    # Hide Safari's bookmarks bar by default.
    defaults write com.apple.Safari ShowFavoritesBar -bool false

    # Make Safari's search banners default to Contains instead of Starts With.
    defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

    # Remove useless icons from Safari's bookmarks bar.
    defaults write com.apple.Safari ProxiesInBookmarksBar "()"

    # Enable the Develop menu and the Web Inspector in Safari.
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Add a context menu item for showing the Web Inspector in web views.
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Enable continuous spellchecking.
    defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

    # Disable auto-correct.
    defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

    # Disable AutoFill.
    defaults write com.apple.Safari AutoFillFromAddressBook -bool false
    defaults write com.apple.Safari AutoFillPasswords -bool false
    defaults write com.apple.Safari AutoFillCreditCardData -bool false
    defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

    # Warn about fraudulent websites.
    defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

    # Disable plug-ins.
    defaults write com.apple.Safari WebKitPluginsEnabled -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

    # Disable Java.
    defaults write com.apple.Safari WebKitJavaEnabled -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

    # Block pop-up windows.
    defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

    # Enable "Do Not Track".
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

    # Update extensions automatically.
    defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

    ###############################################################################
    # Mail                                                                        #
    ###############################################################################

    # Copy email addresses as \`foo@example.com\` instead of \`Foo Bar <foo@example.com>\` in Mail.app.
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app.
    defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

    # Disable inline attachments (just show the icons).
    defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

    ###############################################################################
    # Terminal & iTerm 2                                                          #
    ###############################################################################

    # Only use UTF-8 in Terminal.app.
    defaults write com.apple.terminal StringEncodings -array 4

    # Enable Secure Keyboard Entry in Terminal.app.
    # See: https://security.stackexchange.com/a/47786/8918
    defaults write com.apple.terminal SecureKeyboardEntry -bool true

    # Disable the annoying line marks.
    defaults write com.apple.Terminal ShowLineMarks -int 0

    # Install iTerm themes (Ayu, Material Design and Argonaut).
    # open "../themes/iterm-colors/ayu.itermcolors"
    # open "../themes/iterm-colors/Argonaut.itermcolors"
    # open "../themes/iterm-colors/Material-Design-Colors.itermcolors"

    # Don't display the annoying prompt when quitting iTerm.
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false

    ###############################################################################
    # Time Machine                                                                #
    ###############################################################################

    # Prevent Time Machine from prompting to use new hard drives as backup volume.
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    ###############################################################################
    # Activity Monitor                                                            #
    ###############################################################################

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    ###############################################################################
    # TextEdit, and QuickTime Player                                              #
    ###############################################################################

    # Use plain text mode for new TextEdit documents.
    defaults write com.apple.TextEdit RichText -int 0

    # Open and save files as UTF-8 in TextEdit.
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    # Auto-play videos when opened with QuickTime Player.
    defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

    ###############################################################################
    # Mac App Store                                                               #
    ###############################################################################

    # Enable the automatic update check.
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

    # Download newly available updates in background.
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

    # Install System data files & security updates.
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

    # Automatically download apps purchased on other Macs.
    defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

    # Turn on app auto-update.
    defaults write com.apple.commerce AutoUpdate -bool true

    # Allow the App Store to reboot machine on macOS updates.
    defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

    ###############################################################################
    # Photos                                                                      #
    ###############################################################################

    # Prevent Photos from opening automatically when devices are plugged in.
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

    ###############################################################################
    # Messages                                                                    #
    ###############################################################################

    # Disable automatic emoji substitution (i.e. use plain text smileys).
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

    # Disable smart quotes as it's annoying for messages that contain code.
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

    # Disable continuous spell checking.
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

    ###############################################################################
    # Google Chrome                                                               #
    ###############################################################################

    # Use the system-native print preview dialog.
    defaults write com.google.Chrome DisablePrintPreview -bool true
    defaults write com.google.Chrome.canary DisablePrintPreview -bool true

    # Expand the print dialog by default.
    defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
    defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

    ###############################################################################
    # Kill affected applications                                                  #
    ###############################################################################

    for app in "Activity Monitor" \
        "cfprefsd" \
        "Dock" \
        "Finder" \
        "Google Chrome" \
        "Mail" \
        "Messages" \
        "Photos" \
        "Safari" \
        "SystemUIServer"; do
        killall "${app}" &>/dev/null || true
    done

    print_preview "Done. Note that some of these changes require a logout/restart to take effect." 1
}
