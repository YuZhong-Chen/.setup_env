#!/bin/bash
# Installs bash-completion and hooks the custom prompt into ~/.bashrc.

install_bash() {
    local MODULE="bash"

    apt_install bash-completion

    cp "${REPO_DIR}/bash_config/.bash_prompt_config.sh" ~/.bash_prompt_config.sh

    # Only add the line once, so the module can be re-run safely.
    if ! grep -qF 'bash_prompt_config' ~/.bashrc &> /dev/null; then
        echo "source ~/.bash_prompt_config.sh" >> ~/.bashrc
    else
        log "~/.bashrc already sources the prompt config."
    fi

    log "Installed."
}

# Run this module on its own:  ./modules/bash.sh [--no-sudo]
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/common.sh"
    parse_common_args "$@"
    install_bash
fi
