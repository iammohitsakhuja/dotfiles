# Disable shellcheck since it doesn't support Zsh
# shellcheck disable=all

############################# Exports #############################
source ~/.exports

############################# Zsh configuration #############################

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set to "random" to load a random theme each time oh-my-zsh is loaded.
# Set to "" to let starship take over the prompt.
ZSH_THEME=""

# Plugins for ZSH. Warning: Too many plugins slow down shell startup.
plugins=(
    aliases
    brew
    docker
    docker-compose
    git
    git-extras
    kubectl
    minikube
    mvn
    npm
    rust
    vi-mode
    yazi-zoxide
    zsh-autosuggestions
    zsh-completions
    zsh-interactive-cd
    zsh-syntax-highlighting
)

# Hack to fix startup echo which is printed by these plugins.
if (( $+commands[tmux] )); then
    plugins+=(
        tmux
    )
fi

# Load oh-my-zsh.
source $ZSH/oh-my-zsh.sh

# Load completions for zsh.
autoload -Uz compinit && compinit

############################# Useful aliases #############################

source ~/.aliases

############################# Utility functions #############################

# Always show files when switching directories via cd.
cd() { builtin cd "$@" && ls; }

# Delta-enhanced text processing functions.
rg-delta() {
    rg --color=always "$@" | delta
}

grep-delta() {
    grep --color=always "$@" | delta
}

diff-delta() {
    diff --color=always "$@" | delta
}

blame-delta() {
    git blame "$@" | delta
}

show-delta() {
    git show --color=always "$@" | delta
}

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

# Hook Direnv into shell.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

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

# Hook GitHub Copilot into shell.
if type gh >> /dev/null; then
    eval "$(gh copilot alias -- zsh)"
fi

# Generate completions for `uv`
if type uv >> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# Hook Zoxide into shell.
if type zoxide >> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Enable Starship Prompt.
# This should be placed as the last command in the initialization.
eval "$(starship init zsh)"
