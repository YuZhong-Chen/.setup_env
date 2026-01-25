# setup_env

## ◻️ Introduction ◻️

This repository helps you quickly set up a clean and user-friendly terminal environment. You can install either the `bash` or `zsh` configuration, along with custom styling for `tmux` and `vim`.

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

Append the parameters you want to use at the end of the command: 

- `--shell <shell_type>`: 
    - Specify the shell type to install. Options are `bash` or `zsh`.
    - Default is `bash`.
- `--no-sudo`:
    - If set, the script will not use `sudo` for package installations. Make sure you have already installed the required packages manually.
    - It is useful if you are running the script in some environments where `sudo` is not available, such as laboratory servers.
- `--help` | `-h`:
    - Display help information for the script.

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

## 📘 Configuration of `tmux` 📘

### Key Bindings

To make tmux more convenient to use, I’ve customized several key bindings.  
The most commonly used ones are listed below.

> If the key binding you’re looking for isn’t listed here, it means I didn’t modify that particular key.

- `prefix`: ctrl + A
- `prefix` + `arrow keys`: Move between panes. (You can also click with the mouse to switch)
- hold `prefix` + `arrow keys`: Resize the current pane.
- `prefix` + `Space`: Automatically adjust pane sizes.
- `prefix` + `-`: Split the pane horizontally. (Since `-` resembles a horizontal line)
- `prefix` + `|`: Split the pane vertically. (Since `|` resembles a vertical line)
- `prefix` + `c`: Create a new window. (c for create)
- `ctrl` + `d`: Exit the current pane.
- `prefix` + `number`: Switch to a specific window. (You can also click with the mouse to switch)
- `prefix` + `a`: Switch to the previous window.
- `prefix` + `d`: Detach the session.
- `prefix` + `w`: List all sessions and navigate with arrow keys.
- `mouse selection`: Select and copy text.

### Commands

- `tmux`: Start a new tmux session.
- `tmux ls`: List all tmux sessions.
- `tmux attach`: Attach to the last tmux session.
- `tmux attach -t <session_number>`: Attach to a specific tmux session.
- `tmux kill-session -t <session_number>`: Kill a specific tmux session.
- `tmux kill-server`: Kill all tmux sessions.

## 🔍 Troubleshooting 🔍

### Terminal character display issue

Please make sure your terminal supports and correctly displays UTF-8 characters. If the output does not match the example, it is likely due to missing font support for certain symbols. You can resolve this by installing a font that includes these characters or by replacing unsupported symbols with alternatives.

### Cursor/VS Code terminal integration issues

If Cursor/VS Code cannot detect when commands finish (for example, the agent
cannot run commands in the terminal), it is usually because a custom prompt
overwrites shell integration markers. This repo's bash prompt preserves the
integration markers when they are present. If you modify the prompt after
sourcing `.bash_prompt_config.sh`, keep the prompt prefix/suffix markers
(`VSCODE_PROMPT_PREFIX`/`VSCODE_PROMPT_SUFFIX` or Cursor equivalents) so the
terminal can track command boundaries.