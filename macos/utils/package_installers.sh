#!/usr/bin/env bash

# Package installation utilities for dotfiles
# This file provides package installation functions for various language ecosystems and tools.
# Functions convert standalone scripts to reusable utility functions with consistent error handling.

# Source shared utilities
PACKAGE_SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
if [[ ! -d ${PACKAGE_SCRIPT_DIR} ]] || [[ ${PACKAGE_SCRIPT_DIR} == "${BASH_SOURCE[0]}" ]]; then
    # Fallback: assume we're being sourced from repo root
    PACKAGE_SCRIPT_DIR="macos/utils"
fi
source "${PACKAGE_SCRIPT_DIR}/platform.sh"
source "${PACKAGE_SCRIPT_DIR}/logging.sh"

# Install Go packages and setup goenv
install_go_packages() {
    print_action "Setting up Go environment and packages"

    # Make sure goenv is installed
    install_package_if_missing "goenv"

    # Setup Goenv
    eval "$(goenv init -)"

    # Use the latest Go version
    GO_VERSION=latest

    # Install Go
    print_detail "Installing Go version: ${GO_VERSION}"
    goenv install "${GO_VERSION}" --skip-existing
    print_detail "Setting global Go version as: ${GO_VERSION}"
    goenv global "${GO_VERSION}"
    print_detail "Go installation successful"

    # Install Go packages
    if command -v go &>/dev/null; then
        print_detail "Installing Go packages..."
        # Uncomment the following line, and add package names to install global go packages.
        # go install
        print_detail "Go packages installed successfully"
    else
        print_warning "Go command not found! Skipping Go packages installation..."
        return 1
    fi

    print_success "Go environment setup complete"
    echo ""
}

# Install Node.js packages and setup nodenv
install_node_packages() {
    print_action "Setting up Node.js environment and packages"

    # Make sure nodenv is installed
    install_package_if_missing "nodenv"

    # Setup Nodenv
    eval "$(nodenv init -)"

    # Get the latest stable Node.js version from nodenv
    NODE_VERSION=$(nodenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 | sed 's/^[[:space:]]*//')

    # Fallback to a known stable version if detection fails
    if [[ -z ${NODE_VERSION} ]]; then
        NODE_VERSION="24.6.0"
        print_warning "Could not detect latest Node.js version, using fallback: ${NODE_VERSION}"
    fi

    # Install Node
    print_detail "Installing Node.js version: ${NODE_VERSION}"
    nodenv install "${NODE_VERSION}" --skip-existing
    print_detail "Setting global Node.js version as: ${NODE_VERSION}"
    nodenv global "${NODE_VERSION}"
    print_detail "Node.js installation successful"

    # Install global NPM packages
    if command -v npm &>/dev/null; then
        print_detail "Installing global NPM packages..."
        npm install -g prettier
        print_detail "NPM packages installed successfully"
    else
        print_warning "npm command not found! Skipping NPM packages installation..."
        return 1
    fi

    print_success "Node.js environment setup complete"
    echo ""
}

# Install Python packages and setup pyenv
install_python_packages() {
    print_action "Setting up Python environment and packages"

    # Make sure pyenv is installed
    install_package_if_missing "pyenv"

    # Setup Pyenv
    eval "$(pyenv init -)"

    # Get the latest stable Python version from pyenv
    PYTHON_VERSION=$(pyenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 | sed 's/^[[:space:]]*//')

    # Fallback to a known stable version if detection fails
    if [[ -z ${PYTHON_VERSION} ]]; then
        PYTHON_VERSION="3.13.7"
        print_warning "Could not detect latest Python version, using fallback: ${PYTHON_VERSION}"
    fi

    # Install Python
    print_detail "Installing Python version: ${PYTHON_VERSION}"
    pyenv install "${PYTHON_VERSION}" --skip-existing
    print_detail "Setting global Python version as: ${PYTHON_VERSION}"
    pyenv global "${PYTHON_VERSION}"
    print_detail "Python installation successful"

    # Install Pip packages
    if command -v pip3 &>/dev/null; then
        print_detail "Installing Pip packages..."
        pip3 install black gitlint neovim virtualenv
        print_detail "Pip packages installed successfully"
    else
        print_warning "Pip3 not found! Skipping Pip packages installation..."
        return 1
    fi

    print_success "Python environment setup complete"
    echo ""
}

# Install Ruby gems and setup rbenv
install_ruby_gems() {
    print_action "Setting up Ruby environment and gems"

    # Make sure rbenv is installed
    install_package_if_missing "rbenv"

    # Setup Rbenv
    eval "$(rbenv init -)"

    # Get the latest stable Ruby version from rbenv
    RUBY_VERSION=$(rbenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 | sed 's/^[[:space:]]*//')

    # Fallback to a known stable version if detection fails
    if [[ -z ${RUBY_VERSION} ]]; then
        RUBY_VERSION="3.4.5"
        print_warning "Could not detect latest Ruby version, using fallback: ${RUBY_VERSION}"
    fi

    # Install Ruby
    print_detail "Installing Ruby version: ${RUBY_VERSION}"
    rbenv install "${RUBY_VERSION}" --skip-existing
    print_detail "Setting global Ruby version as: ${RUBY_VERSION}"
    rbenv global "${RUBY_VERSION}"
    print_detail "Ruby installation successful"

    # Install Ruby gems
    if command -v gem &>/dev/null; then
        print_detail "Installing Gems..."
        # Uncomment the following line, and add gem names to install global gems.
        # gem install
        # Uncomment the following to add man pages support to installed gems.
        # gem manpages --update-all

        print_detail "Gems installed successfully"
    else
        print_warning "Gem command not found! Skipping gems installation..."
        return 1
    fi

    print_success "Ruby environment setup complete"
    echo ""
}

# Install shell packages and plugins
install_shell_packages() {
    print_action "Installing shell packages and plugins"

    # Install oh-my-zsh
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        print_detail "Oh-my-zsh already installed, skipping installation"
    else
        print_detail "Installing Oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
        print_detail "Oh-my-zsh installation successful"
    fi

    # Install oh-my-zsh plugins
    print_detail "Installing/updating Oh-my-zsh plugins..."

    # Helper function to clone or update plugin
    install_or_update_plugin() {
        local repo_url="$1"
        local plugin_path="$2"
        local plugin_name=$(basename "${plugin_path}")

        if [[ -d ${plugin_path} ]]; then
            print_detail "Updating existing plugin: ${plugin_name}"
            (cd "${plugin_path}" && git pull --quiet)
        else
            print_detail "Installing plugin: ${plugin_name}"
            git clone --depth=1 --quiet "${repo_url}" "${plugin_path}"
        fi
    }

    # Install/update each plugin
    install_or_update_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    install_or_update_plugin "https://github.com/zsh-users/zsh-autosuggestions" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    install_or_update_plugin "https://github.com/zsh-users/zsh-completions" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions"
    install_or_update_plugin "https://github.com/fdw/yazi-zoxide-zsh.git" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/yazi-zoxide"

    print_detail "Oh-my-zsh plugins installation/update completed successfully"

    print_success "Shell packages setup complete"
    echo ""
}

# Install Vim packages and setup VimPlug
install_vim_packages() {
    local stow_dir="$1"
    local vimrc_location="${stow_dir}/home/.vimrc"
    print_action "Installing Vim packages and VimPlug"

    # Install Vim Plug for managing plugins in Vim, both for Neovim and Vim
    # Vim
    print_detail "Installing VimPlug for Vim..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    print_detail "VimPlug for Vim installed successfully"

    # Neovim
    print_detail "Installing VimPlug for Neovim..."
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    print_detail "VimPlug for Neovim installed successfully"

    # Install Vim plugins
    # Vim
    print_detail "Installing Vim plugins for Vim..."
    vim -es -u "${vimrc_location}" -i NONE -c "PlugInstall" -c "qa"
    print_detail "Vim plugins for Vim installed successfully"

    # Neovim
    print_detail "Installing Vim plugins for Neovim..."
    nvim -es -u "${vimrc_location}" -i NONE -c "PlugInstall" -c "qa"
    print_detail "Vim plugins for Neovim installed successfully"

    # Install coc.nvim extensions (reads from g:coc_global_extensions in vimrc)
    if command -v nvim &>/dev/null && [[ -d ~/.vim/plugged/coc.nvim ]]; then
        print_detail "Installing coc.nvim extensions from vimrc configuration..."
        nvim -es -u "${vimrc_location}" -i NONE -c "CocUpdateSync" -c "qa"
        print_detail "Coc.nvim extensions installed successfully"
    else
        print_warning "Coc.nvim not found or Neovim not available, skipping coc extensions installation"
    fi

    print_success "Vim packages setup complete"
    echo ""
}
