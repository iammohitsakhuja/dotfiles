# Add the directory '/usr/local/opt/coreutils/libexec/gnubin' to the PATH
# variable so that macOS recognises utilities like sha256sum and sha512sum.
PATH="$PATH:/System/Library/Frameworks:/Library/Developer"
PATH="$PATH:/usr/local/opt/coreutils/libexec/gnubin"
PATH="/usr/local/Cellar/sdl2:/usr/local/bin:/usr/local/include/SDL2:$PATH"

# Settings for React-Native.
export ANDROID_HOME=$HOME/Library/Android/sdk
PATH="$PATH:$ANDROID_HOME/emulator"
PATH="$PATH:$ANDROID_HOME/tools"
PATH="$PATH:$ANDROID_HOME/tools/bin"
PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH

# Default editor.
export EDITOR="vim"
# alias emulator="cd /Users/mohitsakhuja/Library/Android/sdk/emulator && emulator"

# Path to your oh-my-zsh installation.
export ZSH=/Users/mohitsakhuja/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

############################# User configuration #############################
# Syntax Highlighting for zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completions for zsh
fpath=(/usr/local/share/zsh-completions $fpath)

# Show files/folders vertically and produce a colored output.
alias ls="ls -Gp"

# Always show files when switching directories.
cd() { builtin cd "$@" && ls; }

# Alias for Vim tabs.
alias vim="vim -p"

# start python3 and pip3 by default
alias python=python3
alias pip=pip3

# alias for AWS cli
alias aws="/Users/mohitsakhuja/Library/Python/3.6/bin/aws"

# Run greeting script on startup
source ~/good_morning.sh | lolcat

# Configure the 'remove' command
alias rm="rm -i"

# Open vagrant.
alias vu="vagrant up && vagrant ssh"
alias vh="vagrant halt"

# Create aliases for showing and hiding files
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

# alias to love
alias love="/Applications/love.app/Contents/MacOS/love"

# alias for sqlite
alias sqlite=sqlite3

# flags for C++ compilation
export CXXFLAGS="-std=c++17"

# update MANPATH so that there is no need to prefix 'g' for utilities like sha256sum and sha512sum
MANPATH="/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

##############################################################################

############ COLORS FOR MANPAGES ############
# Colors
default=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
purple=$(tput setaf 5)
orange=$(tput setaf 9)

# Less colors for man pages
export PAGER=less
# Begin blinking
export LESS_TERMCAP_mb=$red
# Begin bold
export LESS_TERMCAP_md=$orange
# End mode
export LESS_TERMCAP_me=$default
# End standout-mode
export LESS_TERMCAP_se=$default
# Begin standout-mode - info box
export LESS_TERMCAP_so=$purple
# End underline
export LESS_TERMCAP_ue=$default
# Begin underline
export LESS_TERMCAP_us=$green
#############################################

# NVM
# Defer initialization of nvm until nvm, node or a node-dependent command is
# run. Ensure this block is only run once if .bashrc gets sourced multiple times
# by checking whether __init_nvm is a function.
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

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# API keys
source ~/.api_keys

# Required by Homebrew.
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

