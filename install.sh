#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $* == "--help" ]] || [[ $* == "-h" ]]; then
    echo -n "Usage: ./install.sh "
    echo -n "[ -h | --help ] [ -c | --copy] [ -cr | --copy-rc ] [ -lr | --link-rc ] "
    echo "[ -cs | --copy-scripts ] [ -ls | --link-scripts ] [ -a | --all ]"
    echo "-h, --help          | Show this help"
    echo "-c, --copy          | Copy rc files and startup scripts rather than linking"
    echo "-cr, --copy-rc      | Copy just the rc files"
    echo "-lr, --link-rc      | Link just the rc files"
    echo "-cs, --copy-scripts | Copy just the startup scripts"
    echo "-ls, --link-scripts | Link just the startup scripts"
    echo "-a, --all           | Link rc files and startup scripts (default)"
    exit 0
fi

case $* in
    --copy|-c)
        echo "Copying config files into $HOME/ ..."
        cp -r $(pwd)/config/ $HOME/
        echo -e "\nCopying startup scripts into $HOME/ ..."
        cp -r $(pwd)/startup_scripts/ $HOME/
        ;;
    --copy-rc|-cr)
        echo "Copying config files into $HOME/ ..."
        cp -r $(pwd)/config/ $HOME/
        ;;
    --link-rc|-lr)
        echo "Linking config files into $HOME/ ..."
        for file in $DIR/config/.??*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
    --copy-scripts|-cs)
        echo "Copying startup scripts into $HOME/ ..."
        cp -r $(pwd)/startup_scripts/ $HOME/
        ;;
    --link-scripts|-ls)
        echo "Linking startup scripts into $HOME/ ..."
        for file in $DIR/startup_scripts/*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
    *)
        echo "Linking config files into $HOME/ ..."
        for file in $DIR/config/.??*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        echo -e "\nLinking startup scripts into $HOME/ ..."
        for file in $DIR/startup_scripts/*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
esac

# Ask for administrator password.
echo -e "\nInstallation requires administrator authentication..."
sudo -v

# Keep `sudo` alive i.e. update existing time stamp until `./install.sh` has
# finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Run installation scripts.
echo -e "\nRunning installation scripts..."

PWD=$(pwd)
echo "Installing Homebrew, if necessary."
bash $PWD/scripts/brew.sh
echo -e "Homebrew installation successful!\n"

echo "Installing Casks, if necessary."
bash $PWD/scripts/cask.sh
echo -e "Homebrew casks installation successful!\n"

echo "Installing Manpages."
bash $PWD/scripts/man.sh
echo -e "Manpages installation successful!\n"

echo "Installing Zsh and Oh-my-zsh."
bash $PWD/scripts/zsh.sh
echo -e "Zsh and Oh-my-zsh installation successful!\n"

# Configure Tmux colors.
echo "Configuring Tmux colors."
tic -x xterm-256color-italic.terminfo
tic -x tmux-256color.terminfo
echo -e "Tmux colors configured successfully!\n"

