# Disable shellcheck since it doesn't support Zsh
# shellcheck disable=all

# Rust/Cargo environment setup
# Source cargo environment if it exists (created by rustup installer)
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi
