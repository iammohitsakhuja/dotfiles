# Things which need to be lazy loaded should be split into two steps.
# One at the top of this file.
# Another at the bottom of this file.

# Hook Direnv into shell.
# Since Direnv can produce some console output, we place it before
# Powerlevel10k's instant prompt preamble.
if type direnv >> /dev/null; then
    emulate zsh -c "$(direnv export zsh)"
fi

############################# Powerline setup #############################
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

############################# Exports #############################
source ~/.exports

############################# Zsh configuration #############################

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set to "random" to load a random theme each time oh-my-zsh is loaded.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins for ZSH. Warning: Too many plugins slow down shell startup.
plugins=(
    brew
    docker
    docker-compose
    git
    helm
    kubectl
    macos
    mvn
    npm
    rust
    tmux
    vi-mode
    yarn
    zsh-autosuggestions
    zsh-completions
    zsh-interactive-cd
    zsh-syntax-highlighting
)

# Load oh-my-zsh.
source $ZSH/oh-my-zsh.sh

# Load completions for zsh.
autoload -Uz compinit && compinit

############################# Useful aliases #############################

source ~/.aliases

############################# Utility functions #############################

# Always show files when switching directories via cd.
cd() { builtin cd "$@" && lc; }

############################# Sourcing scripts #############################

# API keys.
source ~/.api_keys

# Use the correct version of node by checking for `.nvmrc` file.
load_nvmrc() {
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
        local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

        if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
        elif [ "$nvmrc_node_version" != "$node_version" ]; then
            nvm use
        fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
        echo "Reverting to nvm default version"
        nvm use default
    fi
}

load_nvm () {
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

    # Place this after nvm initialization!
    autoload -U add-zsh-hook

    # Autoload nvmrc when changing directories.
    add-zsh-hook chpwd load_nvmrc

    # Load the correct version now.
    load_nvmrc
}

for cmd in "${NODE_GLOBALS[@]}"; do
    eval "${cmd}(){ unset -f ${NODE_GLOBALS}; load_nvm; ${cmd} \$@ }"
done

############################# Sourcing scripts #############################

# API keys.
source ~/.api_keys

############################# Miscellaneous #############################

# For fuzzy-file finding with fzf.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Required by Homebrew.
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

# Integrate Iterm utilities.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Hook Goenv into shell.
if type goenv >> /dev/null; then
    eval "$(goenv init -)"
fi

# Hook Jenv into shell.
if type jenv >> /dev/null; then
    eval "$(jenv init -)"
fi

# Hook Nodenv into shell.
if type nodenv >> /dev/null; then
    eval "$(nodenv init -)"
fi

# Hook Pyenv into shell.
if type pyenv >> /dev/null; then
    eval "$(pyenv init -)"
fi

# Hook Rbenv into shell.
if type rbenv >> /dev/null; then
    eval "$(rbenv init -)"
fi

# Keep this as the last command to be run, so that instant prompt runs correctly.
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
