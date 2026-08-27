#!/bin/bash
# Shared helpers for every module in this directory.
#
# Sourced by install.sh, and also by a module when it is run on its own.

# Guard against being sourced twice.
[[ -n "${SETUP_ENV_COMMON_SOURCED:-}" ]] && return 0
SETUP_ENV_COMMON_SOURCED=1

# Root of the repository, i.e. the parent of this modules/ directory.
# Config folders such as zsh_config/ are looked up relative to this.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"

# Defaults, overridden by the command line.
CURRENT_SHELL="bash"
NO_SUDO=0

# Prefixed output, so it is obvious which module a message came from.
# MODULE is declared local inside each install function, and bash's dynamic
# scoping makes it visible here.
log() { printf '[%s] %s\n' "${MODULE:-setup_env}" "$*"; }
warn() { printf '[%s] Warning: %s\n' "${MODULE:-setup_env}" "$*"; }

# True when the command exists.
have() { command -v "$1" &> /dev/null; }

# apt wrappers that do nothing when sudo is unavailable. Every module goes
# through these, so the --no-sudo rule lives in exactly one place.
apt_update() {
    [[ "$NO_SUDO" -eq 1 ]] && return 0
    sudo apt update
}

apt_install() {
    [[ "$NO_SUDO" -eq 1 ]] && return 0
    sudo apt install -y "$@"
}

# Clones only when the destination is missing, so a module can be re-run on a
# machine that is already set up without git failing on an existing directory.
git_clone_if_missing() {
    local url="$1" dest="$2"
    if [[ -d "$dest" ]]; then
        log "${dest} already exists, skipping clone."
        return 0
    fi
    git clone "$url" "$dest"
}

# Usage text. A caller may add its own flags through these two variables.
usage() {
    echo "Usage: $(basename "$0") [--shell <shell_type>] [--no-sudo] ${EXTRA_USAGE_FLAGS:-}[--help|-h]"
    echo "Options:"
    echo "  --shell <shell_type>   Specify the shell type (default: bash)"
    echo "  --no-sudo              Do not use sudo for package installations"
    [[ -n "${EXTRA_USAGE_OPTS:-}" ]] && echo "${EXTRA_USAGE_OPTS}"
    echo "  --help, -h             Show this help message"
}

# Parses the flags every module understands.
parse_common_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --shell)
                shift
                if [[ $# -gt 0 ]]; then
                    if [[ "$1" != "bash" && "$1" != "zsh" ]]; then
                        echo "Invalid shell type. Supported types are 'bash' and 'zsh'."
                        exit 1
                    fi
                    CURRENT_SHELL="$1"
                else
                    echo "No shell type specified."
                    usage
                    exit 1
                fi
                ;;
            --no-sudo)
                NO_SUDO=1
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done
}
