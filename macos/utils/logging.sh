#!/usr/bin/env bash

# Shared logging and utility functions for dotfiles scripts
# This file provides consistent logging patterns for scripts.

# Print a standardized header with 70-character width and centered title
print_header() {
    local title="$1"
    echo "======================================================================"
    printf "%-70s\n" "$(printf "%*s" $(((70 - ${#title}) / 2)) '')${title}"
    echo "======================================================================"
}

# Print a step indicator with current/total progress and description
print_step() {
    local current="$1"
    local total="$2"
    local description="$3"
    echo ""
    echo "Step ${current}/${total}: ${description}"
    printf "=%.0s" $(seq 1 $((${#description} + 15)))
    echo ""
}

# Print an action message with arrow indicator
print_action() {
    local message="$1"
    echo "  → ${message}"
}

# Print a success message with checkmark
print_success() {
    local message="$1"
    echo "  ✓ ${message}"
}

# Print a warning message with warning symbol
print_warning() {
    local message="$1"
    echo "  ⚠ ${message}"
}

# Print a configuration item in "• label: value" format
print_config_item() {
    local label="$1"
    local value="$2"
    echo "  • ${label}: ${value}"
}

# Print the final celebration message with consistent formatting
print_celebration() {
    local message="$1"
    echo "🎉 ${message}"
}

# Print a preview/info message with magnifying glass
print_preview() {
    local message="$1"
    echo "🔍 ${message}"
}
