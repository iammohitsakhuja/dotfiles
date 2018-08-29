#!/usr/bin/env bash

# Check if environment is macOS/Linux.
if [[ $OSTYPE != "darwin"* && $OSTYPE != "linux-gnu" ]]; then
    echo -e "Environment not recognized as macOS/Linux.\nQuitting..."
    exit 1
fi

# Install Homebrew/Linuxbrew if it isn't installed already.
if ! [ `which brew` ]; then
    if [[ $OSTYPE == "darwin"* ]]; then
        echo "Installing Homebrew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "Installing Linuxbrew"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
        test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
        test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
        test -r ~/.bash_profile && echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.bash_profile
        echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.profile
    fi
    echo "Installation successful!"
fi

# Install taps.
echo -e "\nInstalling taps..."
brew tap caskroom/cask
brew tap caskroom/versions
brew tap homebrew/cask-drivers
brew tap zegervdv/zathura # Required for installing Zathura (PDF viewer)
echo -e "Taps installed successfully\n"

# Install GUI Applications.
echo -e "\nInstalling GUI applications..."
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
brew cask install spectacle
brew cask install spotify
brew cask install the-unarchiver
brew cask install vlc
brew cask install webtorrent
brew cask install whatsapp
echo -e "GUI applications installed successfully\n"

# Install Quick-look plugins.
echo -e "\nInstalling Quick-look plugins..."
brew cask install qlcolorcode
brew cask install qlmarkdown
brew cask install qlstephen
brew cask install quicklook-json
brew cask install quicklook-csv
echo -e "Quick-look plugins installed successfully\n"

# Utilites required for PDF viewing/conversion through CLI.
echo -e "\nInstalling PDF utilities..."
brew cask install mactex
brew cask install xquartz

# Zathura can only be installed after installing `xquartz`.
# To install Zathura, you need to install `girara`, `zathura` and
# `zathura-pdf-poppler`. For that, download these packages from the `Releases`
# section on `pwmt` GitHub site and calculate their sha sums that are mentioned
# in `/usr/local/Homebrew/Library/Taps/zegervdv/homebrew-zathura/package-name`.
# And make appropriate changes to those files. Then run the following:
# brew install girara
# brew install zathura
# brew install zathura-pdf-poppler
echo "Please install Zathura as mentioned in the script"
echo -e "PDF utilities installed successfully\n"

# Development utilties.
echo -e "\nInstalling Development utilities..."
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
echo -e "Development utilities installed succesfully\n"
echo "Cask packages installed successfully"

