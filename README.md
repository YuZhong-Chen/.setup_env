# setup_env

Setup zsh & tmux & vim.

> Note: 
> 
> - In `.zshrc`, ROS-related dependencies are sourced if the `ROS_DISTRO` environment variable is set.
> - We use `bash` as the default shell, if you want to use `zsh`, please add the configuration when executing the install script:
>     - `~/.setup_env/install.sh --shell zsh`

## Install

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