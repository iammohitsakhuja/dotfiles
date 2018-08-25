#!/usr/bin/env bash

# Check if environment is macOS.
if [[ $OSTYPE != "darwin"* ]]; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Install Homebrew if it isn't installed already.
if ! [ `which brew` ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install taps.
brew tap caskroom/cask
brew tap caskroom/versions
brew tap homebrew/cask-drivers

# Install GUI Applications.
brew cask install android-file-transfer
brew cask install appcleaner
brew cask install dashlane
brew cask install dropbox
brew cask install firefox
brew cask install firefox-developer-edition
brew cask install google-chrome
brew cask install logitech-options
brew cask install microsoft-office
brew cask install opera
brew cask install slack
brew cask install spotify
brew cask install the-unarchiver
brew cask install vlc
brew cask install webtorrent
brew cask install whatsapp

# Install Quick-look plugins.
brew cask install qlcolorcode
brew cask install qlmarkdown
brew cask install qlstephen
brew cask install quicklook-json
brew cask install quicklook-csv

# Development utilties.
brew cask install docker
brew cask install hyper
brew cask install insomnia
brew cask install iterm2
brew cask install java8
brew cask install love
brew cask install vagrant
brew cask install virtualbox
brew cask install virtualbox-extension-pack
brew cask install visual-studio-code

