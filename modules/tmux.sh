#!/bin/bash
# Installs tmux, the shared .tmux.conf, and the tpm plugin manager.

install_tmux() {
    local MODULE="tmux"

    apt_install tmux

    cp "${REPO_DIR}/tmux_config/.tmux.conf" ~/
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
        # Point tmux at zsh instead of the default bash.
        sed -i "s/\bbash\b/${CURRENT_SHELL}/g" ~/.tmux.conf
    fi

    git_clone_if_missing https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    if have tmux; then
        ~/.tmux/plugins/tpm/bin/install_plugins
    else
        warn "tmux is not installed, so tpm plugins were not fetched."
    fi

    log "Installed."
}

# Run this module on its own:  ./modules/tmux.sh [--shell zsh] [--no-sudo]
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/common.sh"
    parse_common_args "$@"
    install_tmux
fi
