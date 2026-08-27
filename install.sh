#!/bin/bash
# Sets up a clean terminal environment: shell, tmux, vim and yazi.
#
# Each package is installed by its own module under modules/. Every module
# can also be run on its own, which is the easy way to add or reinstall one
# package on a machine that is already set up:
#
#     ./modules/yazi.sh --shell zsh
#
# Reference for the directory lookup: https://stackoverflow.com/q/59895
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

source "${SCRIPT_DIR}/modules/common.sh"
source "${SCRIPT_DIR}/modules/zsh.sh"
source "${SCRIPT_DIR}/modules/bash.sh"
source "${SCRIPT_DIR}/modules/tmux.sh"
source "${SCRIPT_DIR}/modules/vim.sh"
source "${SCRIPT_DIR}/modules/yazi.sh"

# yazi is installed by default. --no-yazi is the only flag this script adds
# on top of the ones every module understands.
INSTALL_YAZI=1
EXTRA_USAGE_FLAGS="[--no-yazi] "
EXTRA_USAGE_OPTS="  --no-yazi              Skip installing the yazi file manager"

# Take out the flags that belong to this script, and hand the rest to the
# shared parser in common.sh.
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--no-yazi" ]]; then
        INSTALL_YAZI=0
    else
        ARGS+=("$arg")
    fi
done
parse_common_args "${ARGS[@]}"

# Update the package list, and install what the modules rely on.
apt_update
apt_install git

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    install_zsh
else
    install_bash
fi

install_tmux
install_vim

if [[ "$INSTALL_YAZI" -eq 1 ]]; then
    install_yazi
fi
