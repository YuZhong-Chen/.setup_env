#!/bin/bash
# Installs zsh with oh-my-zsh, the jovial theme, and makes it the login shell.

install_zsh() {
    local MODULE="zsh"

    apt_install zsh

    git_clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    git_clone_if_missing https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git_clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    mkdir -p ~/.oh-my-zsh/custom/plugins/jovial
    cp "${REPO_DIR}/zsh_config/.zshrc" ~/
    cp "${REPO_DIR}/zsh_config/jovial.zsh-theme" ~/.oh-my-zsh/custom/themes/jovial.zsh-theme
    cp "${REPO_DIR}/zsh_config/jovial.plugin.zsh" ~/.oh-my-zsh/custom/plugins/jovial/jovial.plugin.zsh

    # Set zsh as the default shell.
    # chsh acts on the invoking user, which under sudo is root, so the target
    # user has to be named explicitly. $USER is unset in a Docker RUN, so
    # "id -un" is used instead.
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo chsh -s /bin/zsh "$(id -un)"
    fi

    log "Installed."
}

# Run this module on its own:  ./modules/zsh.sh [--no-sudo]
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/common.sh"
    parse_common_args "$@"
    install_zsh
fi
