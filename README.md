# setup_env

## ◻️ Introduction ◻️

This repository is designed to help you quickly set up your environment, providing a clean and convenient terminal experience. You can choose to install either the `bash` or `zsh` configuration based on your preference. It also includes styling for `tmux` and `vim`.

For the `bash` setup, you can refer to the following example:

```
╭─[machine-name] as user in ~/ on branch (main)* (docker)
└──➤ some-command ...
```

If the current directory is inside a Git repository, the prompt will automatically display the branch name. If there are uncommitted changes, an asterisk (`*`) will appear as a warning. Additionally, if you are inside a container, the prompt will show `(docker)` at the end as a reminder.

> Note: 
> 
> - This repository does not overwrite anything in your `.bashrc`. Any existing commands or configurations in your `.bashrc` will still be executed as usual. This setup simply appends a script at the end to configure the prompt output.
> - In `.zshrc`, ROS-related dependencies are automatically sourced if the environment variable `ROS_DISTRO` is set.

## 🚩 Install 🚩

Script parameters: 

- `--shell <shell_type>`: 
    - Specify the shell type to install. Options are `bash` or `zsh`.
    - Default is `bash`.
- `--no-sudo`:
    - If set, the script will not use `sudo` for package installations. Make sure you have already installed the required packages manually.
    - It is useful if you are running the script in some environments where `sudo` is not available, such as laboratory servers.
- `--help` | `-h`:
    - Display help information for the script.

> Append the parameters you want to use at the end of the command.

### Command line

```bash
git clone https://github.com/YuZhong-Chen/.setup_env.git ~/.setup_env
~/.setup_env/install.sh
```

### Dockerfile

> Please add the following lines at the end of your Dockerfile, and make sure you have changed the user to the one you want to install the environment for.

```Dockerfile
# Install custom environment
RUN git clone https://github.com/YuZhong-Chen/.setup_env.git ~/.setup_env \
    && ~/.setup_env/install.sh
```

## 🔍 Troubleshooting 🔍

### Terminal character display issue

Please make sure your terminal supports and correctly displays UTF-8 characters. If the output does not match the example, it is likely due to missing font support for certain symbols. You can resolve this by installing a font that includes these characters or by replacing unsupported symbols with alternatives.