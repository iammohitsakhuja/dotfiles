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

# Install Go packages and configure goenv.
install_go_packages() {
    print_action "Installing Go environment and packages"

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
    print_detail "Go installation completed"

    # Install Go packages
    if command -v go &>/dev/null; then
        print_detail "Installing Go packages..."
        go install github.com/docker/docker-language-server/cmd/docker-language-server@latest
        print_detail "Go packages installed successfully"
    else
        print_warning "Go command not found! Skipping Go packages installation..."
        return 1
    fi

    print_success "Go environment installation complete"
    print_newline
}

# Install Node.js packages and configure nodenv.
install_node_packages() {
    print_action "Installing Node.js environment and packages"

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
    print_detail "Node.js installation completed"

    # Install global NPM packages
    if command -v npm &>/dev/null; then
        print_detail "Installing global NPM packages..."
        npm install -g intelephense
        print_detail "NPM packages installed successfully"
    else
        print_warning "npm command not found! Skipping NPM packages installation..."
        return 1
    fi

    print_success "Node.js environment installation complete"
    print_newline
}

# Install Python packages and configure pyenv.
install_python_packages() {
    print_action "Installing Python environment and packages"

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
    print_detail "Python installation completed"

    # Install Pip packages
    if command -v pip3 &>/dev/null; then
        print_detail "Installing Pip packages..."
        pip3 install black gitlint neovim virtualenv
        print_detail "Pip packages installed successfully"
    else
        print_warning "Pip3 not found! Skipping Pip packages installation..."
        return 1
    fi

    print_success "Python environment installation complete"
    print_newline
}

# Install Ruby gems and configure rbenv.
install_ruby_gems() {
    print_action "Installing Ruby environment and gems"

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
    print_detail "Ruby installation completed"

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

    print_success "Ruby environment installation complete"
    print_newline
}

# Install Rust packages and configure rustup.
install_rust_packages() {
    print_action "Installing Rust environment and packages"

    # Check if rustup is already installed
    if command -v rustup &>/dev/null; then
        print_detail "Rustup already installed, updating rustup and toolchains..."
        rustup update
        print_detail "Rustup and toolchains updated successfully"
    else
        print_detail "Installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        print_detail "Rustup installation completed"

        # Source cargo environment to make it available in current session
        if [[ -f ~/.cargo/env ]]; then
            source "${HOME}/.cargo/env"
            print_detail "Cargo environment sourced successfully"
        else
            print_warning "Cargo environment file not found at ~/.cargo/env"
        fi
    fi

    # Install rustup components
    if command -v rustup &>/dev/null; then
        print_detail "Installing rustup components..."
        rustup component add rust-src rust-analyzer
        print_detail "Rustup components installed successfully"
    else
        print_warning "Rustup command not found! Skipping rustup components installation..."
        return 1
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

    print_success "Rust environment installation complete"
    print_newline
}

# Install Java tools and dependencies.
install_java_tools() {
    print_action "Installing Java tools and dependencies"

    # Create directory for Java tools
    local java_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/java"
    mkdir -p "${java_dir}"

    # Download Lombok
    print_detail "Downloading Lombok JAR..."
    if curl -L https://projectlombok.org/downloads/lombok.jar -o "${java_dir}/lombok.jar"; then
        print_detail "Lombok JAR installed successfully"
    else
        print_warning "Failed to download Lombok JAR"
        return 1
    fi

    print_success "Java tools installation complete"
    print_newline
}
