# setup_env

## ◻️ Introduction ◻️

This repository helps you quickly set up a clean and user-friendly terminal environment. You can install either the `bash` or `zsh` configuration, along with custom styling for `tmux` and `vim`, and the [yazi](https://yazi-rs.github.io) terminal file manager.

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
- `--no-yazi`:
    - If set, the script will skip installing `yazi`.
    - `yazi` is installed by default. Use this flag to keep the image or machine smaller.
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

## 🧩 Structure 🧩

Each package is installed by its own module under `modules/`, and `install.sh` just calls them in order. Shared helpers, argument parsing and the `--no-sudo` handling live in `modules/common.sh`, so they exist in exactly one place.

```
.setup_env/
├── install.sh          # entry point, calls the modules in order
├── modules/
│   ├── common.sh       # shared helpers, argument parsing
│   ├── zsh.sh          # install_zsh
│   ├── bash.sh         # install_bash
│   ├── tmux.sh         # install_tmux
│   ├── vim.sh          # install_vim
│   └── yazi.sh         # install_yazi
├── zsh_config/
├── bash_config/
├── tmux_config/
└── vim_config/
```

### Running a single module

Every module also runs on its own, with the same flags. This is the easy way to add or reinstall one package on a machine that was set up with an older version of this repository, without re-running the whole script:

```bash
cd ~/.setup_env && git pull
./modules/yazi.sh --shell zsh
```

Modules are safe to re-run: existing clones are skipped rather than failing, and `~/.bashrc` is only appended to once.

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

## 📂 Configuration of `yazi` 📂

[yazi](https://yazi-rs.github.io) is a terminal file manager. It is installed by default; pass `--no-yazi` to skip it.

### How it is installed

The official prebuilt binary is used in both modes, so there is only one install path to maintain:

- With `sudo`: `yazi` and `ya` are installed into `/usr/local/bin`.
- With `--no-sudo`: they go into `~/.local/bin`, and that directory is added to your `PATH` if it is not there already.

The `musl` builds are statically linked, so they run on any Linux without extra runtime dependencies. Both `x86_64` and `aarch64` are supported. To upgrade later, just re-run the script.

`yazi` requires `file` to detect MIME types. It is installed automatically when `sudo` is available, and is normally already present on any real system. Without it `yazi` reports ``Cannot find 'file'`` and renders no previews at all.

Optional preview dependencies (`ffmpeg`, `jq`, `poppler-utils`, `7zip`, `chafa`) are installed only when `sudo` is available. Without them `yazi` still works, but video, PDF, JSON and archive previews are unavailable. Note that Debian and Ubuntu name the 7-Zip binary `7z`, not `7zz` as the upstream `yazi` documentation assumes.

### Icons and image preview

> Note:
>
> - `yazi` uses [Nerd Font](https://www.nerdfonts.com) icons. Fonts are rendered by the terminal on the machine **you are sitting at**, never by the server. If icons look wrong over SSH, install a Nerd Font on your **local** machine, not on the server. Installing fonts inside a container or on a remote host has no effect.
> - For sharp image preview, the terminal must support a graphics protocol, such as `kitty`, `WezTerm` or `Ghostty`. `GNOME Terminal` does not support one. On terminals without a graphics protocol, `yazi` falls back to `chafa`, which draws the image as coloured text; it looks blocky, but it works everywhere, including over SSH. If `chafa` is missing, `yazi` reports ``failed to spawn chafa`` and shows nothing.
> - The `.tmux.conf` here already sets `allow-passthrough on`, which `tmux` needs in order to forward image escape sequences.

## 🔍 Troubleshooting 🔍

### Terminal character display issue

Please make sure your terminal supports and correctly displays UTF-8 characters. If the output does not match the example, it is likely due to missing font support for certain symbols. You can resolve this by installing a font that includes these characters or by replacing unsupported symbols with alternatives.