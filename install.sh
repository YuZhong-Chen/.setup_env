#!/bin/bash

# Get the directory of this script.
# Reference: https://stackoverflow.com/q/59895
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# Read the variable
CURRENT_SHELL="bash"
NO_SUDO=0
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
            fi
            ;;
        --no-sudo)
            NO_SUDO=1
            ;;
        --help|-h)
            echo "Usage: $0 [--shell <shell_type>]"
            echo "Options:"
            echo "  --shell <shell_type>   Specify the shell type (default: bash)"
            echo "  --no-sudo              Do not use sudo for package installations"
            echo "  --help, -h             Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Update package list, and install necessary packages
if [[ "$NO_SUDO" -eq 0 ]]; then
    sudo apt update
    sudo apt install -y git
fi

# Install zsh
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    # Install zsh
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo apt install -y zsh
    fi
    # Clone the oh-my-zsh repository and set up plugins
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    mkdir -p ~/.oh-my-zsh/custom/plugins/jovial
    cp "${SCRIPT_DIR}/zsh_config/.zshrc" ~/
    cp "${SCRIPT_DIR}/zsh_config/jovial.zsh-theme" ~/.oh-my-zsh/custom/themes/jovial.zsh-theme
    cp "${SCRIPT_DIR}/zsh_config/jovial.plugin.zsh" ~/.oh-my-zsh/custom/plugins/jovial/jovial.plugin.zsh
    # Set zsh as the default shell
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo chsh -s /bin/zsh
    fi
fi

# Configure bash
if [[ "$CURRENT_SHELL" == "bash" ]]; then
    # Install bash-completion
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo apt install -y bash-completion
    fi
    # Copy bash configuration files and set up prompt
    cp "${SCRIPT_DIR}/bash_config/.bash_prompt_config.sh" ~/.bash_prompt_config.sh
    echo "source ~/.bash_prompt_config.sh" >> ~/.bashrc
fi

# Install tmux
if [[ "$NO_SUDO" -eq 0 ]]; then
    sudo apt install -y tmux
fi
cp "${SCRIPT_DIR}/tmux_config/.tmux.conf" ~/
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    # Replace the default shell in .tmux.conf if zsh is used
    sed -i "s/\bbash\b/${CURRENT_SHELL}/g" ~/.tmux.conf
fi
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# Install vim
if [[ "$NO_SUDO" -eq 0 ]]; then
    sudo apt install -y vim
fi
cp "${SCRIPT_DIR}/vim_config/.vimrc" ~/