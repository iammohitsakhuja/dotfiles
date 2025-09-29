#!/usr/bin/env bash

# Plugin installation utilities for dotfiles
# This file provides plugin installation functions for various tools and applications.
# All plugins are installed post-stow to ensure configuration files are available.

# Source shared utilities
PLUGIN_SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
if [[ ! -d ${PLUGIN_SCRIPT_DIR} ]] || [[ ${PLUGIN_SCRIPT_DIR} == "${BASH_SOURCE[0]}" ]]; then
    # Fallback: assume we're being sourced from repo root
    PLUGIN_SCRIPT_DIR="macos/utils"
fi
source "${PLUGIN_SCRIPT_DIR}/platform.sh"
source "${PLUGIN_SCRIPT_DIR}/logging.sh"

# Install shell plugins and configure oh-my-zsh.
install_shell_plugins() {
    print_action "Installing shell plugins"

    # Install oh-my-zsh
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        print_detail "Oh-my-zsh already installed, skipping installation"
    else
        print_detail "Installing Oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
        print_detail "Oh-my-zsh installation completed"
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

    print_success "Shell plugins installation complete"
    print_newline
}

# Install Vim plugins using Lazy.nvim.
install_vim_plugins() {
    print_action "Installing Vim plugins"

    # Make sure neovim is installed
    install_package_if_missing "neovim"

    # Install plugins using Lazy.nvim (post-stow, so config is available)
    print_detail "Installing Neovim plugins via Lazy.nvim..."
    nvim --headless "+Lazy! sync" +qa
    print_detail "Neovim plugins installation completed"

    print_success "Vim plugins installation complete"
    print_newline
}

# Install tmux plugins via TPM (Tmux Plugin Manager).
install_tmux_plugins() {
    print_action "Installing tmux plugins"

    # Make sure tmux is installed
    install_package_if_missing "tmux"

    local tpm_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/tmux/plugins/tpm"

    # Install TPM if not already installed
    if [[ -d ${tpm_dir} ]]; then
        print_detail "TPM already installed, updating..."
        (cd "${tpm_dir}" && git pull --quiet) || print_warning "Failed to update TPM"
    else
        print_detail "Installing TPM (Tmux Plugin Manager)..."
        git clone --depth=1 --quiet https://github.com/tmux-plugins/tpm "${tpm_dir}" || {
            print_warning "Failed to clone TPM repository"
            return 1
        }
        print_detail "TPM installation completed"
    fi

    # Install tmux plugins if TPM is available
    if [[ -f ${tpm_dir}/bin/install_plugins ]]; then
        print_detail "Installing tmux plugins..."
        # Run plugin installation in a way that works even if tmux server isn't running
        "${tpm_dir}/bin/install_plugins" 2>/dev/null || {
            print_detail "Plugin installation via script failed, trying alternative method..."
            # Alternative: start a detached tmux session, install plugins, then kill it
            tmux new-session -d -s "tpm_install" 2>/dev/null || true
            sleep 1
            "${tpm_dir}/bin/install_plugins" 2>/dev/null || print_warning "Plugin installation failed - you may need to run 'prefix + I' in tmux manually"
            tmux kill-session -t "tpm_install" 2>/dev/null || true
        }
        print_detail "Tmux plugins installation completed"
    else
        print_warning "TPM installation script not found! Plugin installation skipped"
        return 1
    fi

    print_success "Tmux plugins installation complete"
    print_newline
}

# Install Yazi plugins and themes.
install_yazi_plugins() {
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
        "yazi-rs/flavors:catppuccin-latte"
        "yazi-rs/flavors:catppuccin-frappe"
        "yazi-rs/flavors:catppuccin-macchiato"
        "yazi-rs/flavors:catppuccin-mocha"
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
            ya pkg add "${plugin}" || print_warning "Failed to (re)install plugin: ${plugin}"
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

# Setup bat themes by rebuilding cache.
install_bat_themes() {
    print_action "Setting up bat themes"

    # Make sure bat is installed
    install_package_if_missing "bat"

    # Rebuild cache to register custom themes
    print_detail "Rebuilding bat cache to register custom themes..."
    bat cache --build || print_warning "Failed to rebuild bat cache"
    print_detail "Bat themes setup completed"

    print_success "Bat themes installation complete"
    print_newline
}
