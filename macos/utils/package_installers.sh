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
    print_newline
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
    print_newline
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
    print_newline
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
    print_newline
}

# Install Rust packages and setup rustup
install_rust_packages() {
    print_action "Setting up Rust environment and packages"

    # Check if rustup is already installed
    if command -v rustup &>/dev/null; then
        print_detail "Rustup already installed, updating rustup and toolchains..."
        rustup update
        print_detail "Rustup and toolchains updated successfully"
    else
        print_detail "Installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        print_detail "Rustup installation successful"

        # Source cargo environment to make it available in current session
        if [[ -f ~/.cargo/env ]]; then
            source "${HOME}/.cargo/env"
            print_detail "Cargo environment sourced successfully"
        else
            print_warning "Cargo environment file not found at ~/.cargo/env"
        fi
    fi

    # Install Rust packages via Cargo
    if command -v cargo &>/dev/null; then
        print_detail "Installing Rust packages..."
        cargo install protols
        print_detail "Rust packages installed successfully"
    else
        print_warning "Cargo command not found! Skipping Rust packages installation..."
        return 1
    fi

    print_success "Rust environment setup complete"
    print_newline
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

    local plugins_base_dir="${HOME}/.oh-my-zsh/custom/plugins"

    # Array of plugins: "repo_url plugin_name [branch]"
    local plugins=(
        "https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting"
        "https://github.com/zsh-users/zsh-autosuggestions.git zsh-autosuggestions"
        "https://github.com/zsh-users/zsh-completions.git zsh-completions"
        "https://github.com/fdw/yazi-zoxide-zsh.git yazi-zoxide-zsh"
    )

    for plugin_info in "${plugins[@]}"; do
        read -r repo_url plugin_name branch <<<"${plugin_info}"
        local plugin_path="${plugins_base_dir}/${plugin_name}"

        if [[ -d ${plugin_path} ]]; then
            print_detail "Updating existing plugin: ${plugin_name}"
            if [[ -n ${branch} ]]; then
                (cd "${plugin_path}" && git checkout "${branch}" --quiet && git pull --quiet)
            else
                (cd "${plugin_path}" && git pull --quiet)
            fi
        else
            print_detail "Installing plugin: ${plugin_name}"
            if [[ -n ${branch} ]]; then
                git clone --depth=1 --branch "${branch}" --quiet "${repo_url}" "${plugin_path}"
            else
                git clone --depth=1 --quiet "${repo_url}" "${plugin_path}"
            fi
        fi
    done

    print_detail "Oh-my-zsh plugins installation/update completed successfully"

    print_success "Shell packages setup complete"
    print_newline
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
    print_newline
}

# Install Yazi plugins and themes
install_yazi_packages() {
    print_action "Installing Yazi plugins and themes"

    # Make sure yazi is installed
    install_package_if_missing "yazi"

    # Define plugins to install
    local plugins=(
        "yazi-rs/plugins:full-border"
        "yazi-rs/plugins:chmod"
        "yazi-rs/plugins:smart-enter"
        "yazi-rs/plugins:zoom"
        "Lil-Dank/lazygit"
    )

    # Define flavors/themes to install
    local flavors=(
        "yazi-rs/flavors:dracula"
    )

    # Get currently installed packages to avoid re-adding
    local installed_packages=$(ya pkg list 2>/dev/null | grep -E "^\s+" | sed 's/^\s*//' | cut -d' ' -f1)

    # Install plugins
    print_detail "Installing Yazi plugins..."
    for plugin in "${plugins[@]}"; do
        if echo "${installed_packages}" | grep -q "^${plugin}$"; then
            print_detail "Plugin already installed: ${plugin}"
        else
            print_detail "Installing plugin: ${plugin}"
            ya pkg add "${plugin}" || print_warning "Failed to install plugin: ${plugin}"
        fi
    done

    # Install flavors/themes
    print_detail "Installing Yazi flavors/themes..."
    for flavor in "${flavors[@]}"; do
        if echo "${installed_packages}" | grep -q "^${flavor}$"; then
            print_detail "Flavor already installed: ${flavor}"
        else
            print_detail "Installing flavor: ${flavor}"
            ya pkg add "${flavor}" || print_warning "Failed to install flavor: ${flavor}"
        fi
    done

    # Install all packages (syncs package.toml)
    print_detail "Installing all packages..."
    ya pkg install

    print_success "Yazi plugins and themes installation complete"
    print_newline
}
