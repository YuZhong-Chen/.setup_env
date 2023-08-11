#!/bin/bash

# Install tmux
sudo apt install -y tmux
cp ./tmux_config/.tmux.conf ~/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
export TMUX_PLUGIN_MANAGER_PATH=~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# Install zsh
sudo apt install -y zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
mkdir -p ~/.oh-my-zsh/custom/plugins/jovial
cp ./zshrc/.zshrc ~/
cp ./zsh_theme/jovial.zsh-theme ~/.oh-my-zsh/custom/themes/jovial.zsh-theme
cp ./zsh_theme/jovial.plugin.zsh ~/.oh-my-zsh/custom/plugins/jovial/jovial.plugin.zsh
sudo chsh -s /bin/zsh