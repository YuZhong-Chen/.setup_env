#!/bin/bash
# Installs vim and the shared .vimrc.

install_vim() {
    local MODULE="vim"

    apt_install vim
    cp "${REPO_DIR}/vim_config/.vimrc" ~/

    log "Installed."
}

# Run this module on its own:  ./modules/vim.sh [--no-sudo]
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/common.sh"
    parse_common_args "$@"
    install_vim
fi
