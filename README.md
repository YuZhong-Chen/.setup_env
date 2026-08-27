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
├── vim_config/
├── yazi_config/        # plugins, keymap, theme, init.lua
└── docs/               # the details, see below
```

### Running a single module

Every module also runs on its own, with the same flags. This is the easy way to add or reinstall one package on a machine that was set up with an older version of this repository, without re-running the whole script:

```bash
cd ~/.setup_env && git pull
./modules/yazi.sh --shell zsh
```

Modules are safe to re-run: existing clones are skipped rather than failing, and `~/.bashrc` is only appended to once.

## 📚 Documentation 📚

The details live in `docs/`, so this page stays about installing:

| Document | What is in it |
| --- | --- |
| [tmux](docs/tmux.md) | Key bindings and the commands worth knowing |
| [yazi](docs/yazi.md) | How it is installed, the plugins, the git status signs, and setting up a Nerd Font |
| [Troubleshooting](docs/troubleshooting.md) | Symptoms and their fixes, listed by what you see on screen |
