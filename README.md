# setup_env

Setup zsh & tmux & vim.

> Note: In `.zshrc`, ROS-related dependencies are sourced if the `ROS_DISTRO` environment variable is set.

## Install

Please run `./install.sh` in the repo.

### Command line

```bash
git clone https://github.com/YuZhong-Chen/.setup_env.git ~/.setup_env
~/.setup_env/install.sh
```

### Dockerfile

```Dockerfile
# Install custom environment
RUN git clone https://github.com/YuZhong-Chen/.setup_env.git ~/.setup_env \
    && ~/.setup_env/install.sh
```