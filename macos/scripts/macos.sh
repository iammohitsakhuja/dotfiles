#!/usr/bin/env bash

# This file contains hand-picked settings from Mathias Bynens' MacOS' dotfiles.
# Full list of settings is available here: https://github.com/mathiasbynens/dotfiles/blob/master/.macos

# Close any open System Preferences panes, to prevent them from overriding any settings we’re about to change.
osascript -e 'tell application "System Preferences" to quit'

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Show scrollbars automatically.
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
# Possible values: `WhenScrolling`, `Automatic` and `Always`.

# Jump to the spot that's clicked on the click of the scrollbar.
defaults write NSGlobalDomain AppleScrollerPagingBehavior -bool true
# `true` for jumping to the spot that's clicked. `false` for jumping to the next page.

# Expand save panel by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default.
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable automatic capitalization as it’s annoying when typing code.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code.
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code.
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Disable press-and-hold for keys in favor of key repeat.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 20

# Set language and text formats.
defaults write NSGlobalDomain AppleLanguages -array "en-IN"
defaults write NSGlobalDomain AppleLocale -string "en_IN"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

###############################################################################
# Screen                                                                      #
###############################################################################

# Fix for blurry fonts on non-Retina displays on MacOS Mojave.
defaults write NSGlobalDomain CGFontRenderingFontSmoothingDisabled -bool NO

# Enable subpixel font rendering on non-Apple LCDs.
defaults write NSGlobalDomain AppleFontSmoothing -int 2

###############################################################################
# Finder                                                                      #
###############################################################################

# Set Desktop as the default location for new Finder windows.
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

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
# Four-letter codes for the view modes: `icnv`, `Nlsv`, `clmv`, `Flwv`.
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

###############################################################################
# Dock and Dashboard                                                          #
###############################################################################

# Set the icon size of Dock items to 39 pixels.
defaults write com.apple.dock tilesize -int 39

# Minimize windows into their application’s icon.
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items.
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock.
defaults write com.apple.dock show-process-indicators -bool true

# Disable Dashboard.
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space.
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use.
defaults write com.apple.dock mru-spaces -bool false

# Automatically hide and show the Dock.
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay.
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock.
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Don’t show recent applications in Dock.
defaults write com.apple.dock show-recents -bool false

###############################################################################
# QuickLook
###############################################################################

# Get rid of QuickLook plugin warning that MacOS Catalina (and above) throw.
xattr -d -r com.apple.quarantine ~/Library/QuickLook

###############################################################################
# Safari                                                                      #
###############################################################################

# Privacy: don’t send search queries to Apple.
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Hide Safari’s bookmarks bar by default.
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Remove useless icons from Safari’s bookmarks bar.
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Enable continuous spellchecking.
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

# Disable auto-correct.
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Warn about fraudulent websites.
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Disable plug-ins.
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

# Disable Java.
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

# Block pop-up windows.
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Enable “Do Not Track”.
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically.
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

###############################################################################
# Mail                                                                        #
###############################################################################

# Disable inline attachments (just show the icons).
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

###############################################################################
# Terminal & iTerm 2                                                          #
###############################################################################

# Only use UTF-8 in Terminal.app.
defaults write com.apple.terminal StringEncodings -array 4

# Install iTerm themes (Ayu, Material Design and Argonaut).
# open "../config/itermcolors/ayu.itermcolors"
# open "../config/itermcolors/Argonaut.itermcolors"
# open "../config/itermcolors/material-design-colors.itermcolors"

# Don’t display the annoying prompt when quitting iTerm.
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# TextEdit                                                                    #
###############################################################################

# Use plain text mode for new TextEdit documents.
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit.
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in.
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Google Chrome                                                               #
###############################################################################

# Use the system-native print preview dialog.
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# Expand the print dialog by default.
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

echo "Done. Note that some of these changes require a logout/restart to take effect."
