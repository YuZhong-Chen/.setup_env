#!/bin/bash

# Get the directory of this script.
# Reference: https://stackoverflow.com/q/59895
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# Update package list
sudo apt update

# Install zsh
sudo apt install -y zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
mkdir -p ~/.oh-my-zsh/custom/plugins/jovial
cp "${SCRIPT_DIR}/zsh_config/.zshrc" ~/
cp "${SCRIPT_DIR}/zsh_config/jovial.zsh-theme" ~/.oh-my-zsh/custom/themes/jovial.zsh-theme
cp "${SCRIPT_DIR}/zsh_config/jovial.plugin.zsh" ~/.oh-my-zsh/custom/plugins/jovial/jovial.plugin.zsh
sudo chsh -s /bin/zsh

# Setup bash prompt
cp "${SCRIPT_DIR}/bash_config/.bash_prompt_config.sh" ~/.bash_prompt_config.sh
if [ -f ~/.bashrc ]; then
    # Append the source command to .bashrc if it exists
    echo "source ~/.bash_prompt_config.sh" >> ~/.bashrc
fi

# Install tmux
sudo apt install -y tmux
cp "${SCRIPT_DIR}/tmux_config/.tmux.conf" ~/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# Install vim
sudo apt install -y vim
cp "${SCRIPT_DIR}/vim_config/.vimrc" ~/