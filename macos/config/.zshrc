############################# Exports #############################
source ~/.exports

############################# Powerline setup #############################

POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs virtualenv)
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
    brew
    docker
    git
    git-flow
    helm
    kubectl
    mvn
    npm
    tmux
    vi-mode
    yarn
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
)

# Load oh-my-zsh.
source $ZSH/oh-my-zsh.sh

# Load completions for zsh.
autoload -U compinit && compinit

############################# Useful aliases #############################

source ~/.aliases

############################# Utility functions #############################

# Always show files when switching directories via cd.
cd() { builtin cd "$@" && lc; }

# NVM
# Defer initialization of NVM until NVM, node or a node-dependent command is run.
declare -a NODE_GLOBALS=(`find ~/.nvm/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)

NODE_GLOBALS+=("node")
NODE_GLOBALS+=("nvm")

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

# Run greeting script on startup.
source ~/greeting.sh | lolcat

# API keys.
source ~/.api_keys

############################# Miscellaneous #############################

# For fuzzy-file finding with fzf.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Required by Homebrew.
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

# Integrate Iterm utilities.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Hook Direnv into shell.
if type direnv >> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Hook Jenv into shell.
if type jenv >> /dev/null; then
    eval "$(jenv init -)"
fi
