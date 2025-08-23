#!/usr/bin/env bash

# Shared logging and utility functions for dotfiles scripts
# This file provides consistent logging patterns for scripts with color support.

# Color detection and utility functions
has_color_support() {
    # Check if we're in a terminal and colors are supported
    # Use stderr instead of stdout since stdout gets redirected in command substitution
    [[ -t 2 ]] && [[ -z ${NO_COLOR:-} ]] && {
        [[ ${TERM:-} != "dumb" ]] && {
            command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]
        }
    }
}

# Color code functions using tput when available, ANSI codes as fallback
get_color() {
    local color_name="$1"

    if ! has_color_support; then
        echo ""
        return 0
    fi

    case "${color_name}" in
    "reset") if command -v tput >/dev/null 2>&1; then tput sgr0; else echo -e "\033[0m"; fi ;;
    "bold") if command -v tput >/dev/null 2>&1; then tput bold; else echo -e "\033[1m"; fi ;;
    "red") if command -v tput >/dev/null 2>&1; then tput setaf 1; else echo -e "\033[31m"; fi ;;
    "green") if command -v tput >/dev/null 2>&1; then tput setaf 2; else echo -e "\033[32m"; fi ;;
    "yellow") if command -v tput >/dev/null 2>&1; then tput setaf 3; else echo -e "\033[33m"; fi ;;
    "blue") if command -v tput >/dev/null 2>&1; then tput setaf 4; else echo -e "\033[34m"; fi ;;
    "magenta") if command -v tput >/dev/null 2>&1; then tput setaf 5; else echo -e "\033[35m"; fi ;;
    "cyan") if command -v tput >/dev/null 2>&1; then tput setaf 6; else echo -e "\033[36m"; fi ;;
    "white") if command -v tput >/dev/null 2>&1; then tput setaf 7; else echo -e "\033[37m"; fi ;;
    "gray") if command -v tput >/dev/null 2>&1; then tput setaf 8; else echo -e "\033[90m"; fi ;;
    *)
        echo ""
        return 1
        ;;
    esac
}

# Color constants for easier use
COLOR_RESET=$(get_color reset)
COLOR_BOLD=$(get_color bold)
COLOR_BLUE=$(get_color blue)
COLOR_GREEN=$(get_color green)
COLOR_YELLOW=$(get_color yellow)
COLOR_CYAN=$(get_color cyan)
COLOR_WHITE=$(get_color white)
COLOR_GRAY=$(get_color gray)

# Helper function to generate indentation strings based on level
# Each level adds 2 spaces of indentation
get_indent() {
    local level="${1:-0}"
    printf "%*s" "$((level * 2))" ""
}

# Print a standardized header with 70-character width and centered title
print_header() {
    local title="$1"
    local indent_level="${2:-0}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_BLUE}${COLOR_BOLD}======================================================================${COLOR_RESET}"
    printf "${indent}${COLOR_BLUE}${COLOR_BOLD}%-70s${COLOR_RESET}\n" "$(printf "%*s" $(((70 - ${#title}) / 2)) '')${title}"
    echo "${indent}${COLOR_BLUE}${COLOR_BOLD}======================================================================${COLOR_RESET}"
}

# Print a subheader with cyan color and underline separator
print_subheader() {
    local title="$1"
    local indent_level="${2:-0}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_BOLD}${COLOR_CYAN}${title}${COLOR_RESET}"
    printf "${indent}${COLOR_CYAN}=%.0s${COLOR_RESET}" $(seq 1 ${#title})
    echo ""
}

# Print a step indicator with current/total progress and description
print_step() {
    local current="$1"
    local total="$2"
    local description="$3"
    local indent_level="${4:-0}"
    local indent=$(get_indent "${indent_level}")
    echo ""
    echo "${indent}${COLOR_BOLD}${COLOR_CYAN}Step ${current}/${total}: ${description}${COLOR_RESET}"
    printf "${indent}${COLOR_BOLD}${COLOR_CYAN}=%.0s${COLOR_RESET}" $(seq 1 $((${#description} + 15)))
    echo ""
}

# Print an action message with arrow emoji indicator
print_action() {
    local message="$1"
    local indent_level="${2:-1}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_RESET}➡️ ${message}${COLOR_RESET}"
}

# Print a success message with check mark emoji
print_success() {
    local message="$1"
    local indent_level="${2:-1}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_GREEN}✅ ${message}${COLOR_RESET}"
}

# Print a warning message with warning emoji
print_warning() {
    local message="$1"
    local indent_level="${2:-1}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_YELLOW}⚠️ ${message}${COLOR_RESET}"
}

# Print a configuration item with memo emoji
print_config_item() {
    local label="$1"
    local value="$2"
    local indent_level="${3:-1}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_RESET}📝 ${label}: ${value}${COLOR_RESET}"
}

# Print the final celebration message with consistent formatting
print_celebration() {
    local message="$1"
    local indent_level="${2:-0}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_GREEN}${COLOR_BOLD}🎉 ${message}${COLOR_RESET}"
}

# Print a preview/info message with magnifying glass
print_preview() {
    local message="$1"
    local indent_level="${2:-0}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_BLUE}🔍 ${message}${COLOR_RESET}"
}

# Print detailed/secondary information in gray color
print_detail() {
    local message="$1"
    local indent_level="${2:-2}"
    local indent=$(get_indent "${indent_level}")
    echo "${indent}${COLOR_GRAY}${message}${COLOR_RESET}"
}
