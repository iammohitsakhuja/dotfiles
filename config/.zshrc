############################# Exports #############################

# Add 'coreutils' to PATH variable so macOS recognises utilities like
# sha256sum and sha512sum.
PATH="$PATH:/System/Library/Frameworks:/Library/Developer"
PATH="$PATH:/usr/local/opt/coreutils/libexec/gnubin"

# Android development settings for React-Native.
export ANDROID_HOME=$HOME/Library/Android/sdk
PATH="$PATH:$ANDROID_HOME/emulator"
PATH="$PATH:$ANDROID_HOME/tools"
PATH="$PATH:$ANDROID_HOME/tools/bin"
PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH

# Default editor.
export EDITOR="vim"

# Flags for C++ compilation.
export CXXFLAGS="-std=c++17"

# Add, path to custom manpages to the MANPATH variable.
# Also, update MANPATH so that there is no need to prefix 'g' for utilities
# like sha256sum and sha512sum.
MANPATH="/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

############################# Zsh configuration #############################

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set to "random" to load a random theme each time oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Plugins for ZSH. Warning: Too many plugins slow down shell startup.
plugins=(
    git
)

# Load oh-my-zsh.
source $ZSH/oh-my-zsh.sh

# Syntax Highlighting for zsh.
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completions for zsh.
fpath=(/usr/local/share/zsh-completions $fpath)

############################# Useful aliases #############################

# Show files/folders vertically and produce a colored output.
alias ls="ls -Gp"

# Alias for Vim tabs.
alias vim="vim -p"

# Start python3 and pip3 by default.
alias python=python3
alias pip=pip3

# Configure the 'remove' command.
alias rm="rm -i"

# Open vagrant.
alias vu="vagrant up && vagrant ssh"
alias vh="vagrant halt"

# Create aliases for showing and hiding hidden files on macOS.
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; \
    killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; \
    killall Finder /System/Library/CoreServices/Finder.app"

# Alias to LOVE2D.
alias love="/Applications/love.app/Contents/MacOS/love"

# Alias for sqlite.
alias sqlite=sqlite3

############################# Colors for Manpages #############################

# Colors.
default=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
purple=$(tput setaf 5)
orange=$(tput setaf 9)

# Less colors for man pages.
export PAGER=less
# Begin blinking.
export LESS_TERMCAP_mb=$red
# Begin bold.
export LESS_TERMCAP_md=$orange
# End mode.
export LESS_TERMCAP_me=$default
# End standout-mode.
export LESS_TERMCAP_se=$default
# Begin standout-mode - info box.
export LESS_TERMCAP_so=$purple
# End underline.
export LESS_TERMCAP_ue=$default
# Begin underline.
export LESS_TERMCAP_us=$green

############################# Utility functions #############################

# Always show files when switching directories via cd.
cd() { builtin cd "$@" && ls; }

# NVM
# Defer initialization of NVM until NVM, node or a node-dependent command is
# run. Ensure this block is only run once if .bashrc gets sourced multiple
# times by checking whether __init_nvm is a function.
if [ -s "$HOME/.nvm/nvm.sh" ] && [ ! "$(whence -w __init_nvm)" = function ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    declare -a __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack')
    function __init_nvm() {
        for i in "${__node_commands[@]}"; do unalias $i; done
        . "$NVM_DIR"/nvm.sh
        unset __node_commands
        unset -f __init_nvm
    }
    for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done
fi

############################# Sourcing scripts #############################

# Run greeting script on startup.
source ~/greeting.sh | lolcat

# API keys.
source ~/.api_keys

############################# Miscellaneous #############################

# Required by Homebrew.
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

