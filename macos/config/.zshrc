############################# Exports #############################

source ~/.exports

############################# Powerline setup #############################

POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)

############################# Zsh configuration #############################

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set to "random" to load a random theme each time oh-my-zsh is loaded.
ZSH_THEME="powerlevel9k/powerlevel9k"
if [[ $TERM_PROGRAM == 'Hyper' ]]; then
    ZSH_THEME="agnoster"
    DEFAULT_USER=$USER
fi

# Plugins for ZSH. Warning: Too many plugins slow down shell startup.
plugins=(
    git
    vi-mode
)

# Load oh-my-zsh.
source $ZSH/oh-my-zsh.sh

# Syntax Highlighting for zsh.
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completions for zsh.
fpath=(/usr/local/share/zsh-completions $fpath)

# Auto-suggestions for zsh.
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

############################# Useful aliases #############################

source ~/.aliases

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
    declare -a __node_commands=(
        'nvm'
        'node'
        'npm'
        'npx'
        'yarn'
        'gulp'
        'grunt'
        'webpack'
        'eslint'
        'express-generator'
        'fixjson'
        'prettier'
        'stylelint'
        'tsc'
        'tslint'
    )
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

# For fuzzy-file finding with fzf.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Required by Homebrew.
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
