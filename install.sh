#!/bin/bash

# Update package list
sudo apt update

# Install zsh
sudo apt install -y zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
mkdir -p ~/.oh-my-zsh/custom/plugins/jovial
cp ./zsh_config/.zshrc ~/
cp ./zsh_config/jovial.zsh-theme ~/.oh-my-zsh/custom/themes/jovial.zsh-theme
cp ./zsh_config/jovial.plugin.zsh ~/.oh-my-zsh/custom/plugins/jovial/jovial.plugin.zsh
sudo chsh -s /bin/zsh

# Install tmux
sudo apt install -y tmux
cp ./tmux_config/.tmux.conf ~/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# Install vim
sudo apt install -y vim
cp ./vim_config/.vimrc ~/