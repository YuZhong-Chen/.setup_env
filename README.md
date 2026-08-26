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

### Plugins

Plugins are declared in `yazi_config/package.toml` and installed with `ya pkg install`, so every machine ends up on the same pinned revision. Everything in `yazi_config/` is copied into `~/.config/yazi/`: `keymap.toml` for keybindings, `yazi.toml` for fetchers, and `init.lua` for plugins that need setting up in Lua.

Currently installed:

| Plugin | Keybinding | What it does |
| --- | --- | --- |
| [chmod](https://github.com/yazi-rs/plugins/tree/main/chmod.yazi) | `c` `m` | Change the mode of the selected files |
| [git](https://github.com/yazi-rs/plugins/tree/main/git.yazi) | — | Shows git status signs next to each file |
| [vcs-files](https://github.com/yazi-rs/plugins/tree/main/vcs-files.yazi) | `g` `c` | Lists the files changed in git |

To add another plugin, add it with `ya pkg add <owner>/<repo>:<plugin>` on one machine, copy the resulting entry from `~/.config/yazi/package.toml` into `yazi_config/package.toml`, then add whatever its README asks for to `yazi_config/keymap.toml`, `yazi_config/yazi.toml` or `yazi_config/init.lua`. Pinning the revision this way keeps every machine on the same version; `ya pkg upgrade` is how you move it forward deliberately. Each plugin pins independently, so the revisions above do not all have to match.

> Note: `g` `c` replaces yazi's default *Go to ~/.config*, because keybindings here are prepended. Check `yazi`'s own keymap before choosing a binding, or you will shadow something silently.

### Installing a Nerd Font

`yazi` labels files with [Nerd Font](https://www.nerdfonts.com) icons, and the prompt uses a few too. The terminal on the machine you are sitting at is what renders them, so the font has to be installed there.

> These commands are for the machine you are **sitting at**, not for a server or a container. `install.sh` deliberately does not install fonts, because a headless machine has nothing to render them.

Pick one of the two routes.

**Symbols only, about 2.3 MB.** Adds the icon glyphs to whatever monospace font you already use, and installs the fontconfig rule that upstream ships with it:

```bash
mkdir -p ~/.local/share/fonts ~/.config/fontconfig/conf.d
curl -fsSLo /tmp/symbols.tar.xz \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz
tar -xf /tmp/symbols.tar.xz -C ~/.local/share/fonts \
    SymbolsNerdFont-Regular.ttf SymbolsNerdFontMono-Regular.ttf
tar -xf /tmp/symbols.tar.xz -C ~/.config/fontconfig/conf.d 10-nerd-font-symbols.conf
fc-cache -f
```

**A full patched font.** Replaces your terminal font with one that already contains the icons. `JetBrainsMono` is used here; any font from [nerdfonts.com](https://www.nerdfonts.com) works the same way:

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMono
curl -fsSLo /tmp/font.zip \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -joq /tmp/font.zip "JetBrainsMonoNerdFontMono-*.ttf" -d ~/.local/share/fonts/JetBrainsMono
fc-cache -f
```

Then **set the terminal font explicitly**, to `JetBrainsMono Nerd Font Mono` or whichever font you installed. Leaving it as `monospace` or "system default" sends the icons through font fallback, which is where they go wrong. In `GNOME Terminal` this also means unticking *Use the system fixed width font*, otherwise the font setting is silently ignored.

To check that it worked, each of these should name a Nerd Font:

```bash
for cp in e5ff e702 f15b f07b; do
    printf "U+%s -> %s\n" "$cp" "$(fc-match ":charset=${cp}" family)"
done
```

> Note:
>
> - If the icons show up as **Chinese characters**, a CJK font is claiming the Private Use Area where Nerd Font icons live, and the check above will name it. On Debian and Ubuntu the usual culprits are `fonts-arphic-uming` and `fonts-arphic-ukai`. Either remove them, or add a rule in `~/.config/fontconfig/conf.d/` that subtracts `U+E000-U+F8FF` from those two families only, which leaves their normal CJK coverage intact.

## 🔍 Troubleshooting 🔍

Each entry starts with what you actually see on screen.

### The icons are Chinese characters

Nerd Font icons live in the Unicode Private Use Area, `U+E000`–`U+F8FF`. Some CJK fonts map Chinese glyphs into that same range, so when one of them wins font fallback you get Chinese characters where the icons should be. On Debian and Ubuntu the usual culprits are `fonts-arphic-uming` and `fonts-arphic-ukai`.

Ask fontconfig which font is answering:

```bash
fc-match ":charset=e702" family
```

If that names a CJK font instead of a Nerd Font, add a rule under `~/.config/fontconfig/conf.d/` that subtracts `U+E000-U+F8FF` from those two families only, then run `fc-cache -f`. Their normal CJK coverage is untouched, so Chinese text still renders correctly.

### The icons are boxes, question marks or blank gaps

No Nerd Font is installed on the machine you are sitting at, or the terminal is not actually using it.

Fonts are rendered by **your** terminal, never by the server, so installing a font on a remote host or inside a container changes nothing. Install it locally: [Installing a Nerd Font](#installing-a-nerd-font).

If the font is installed and the icons are still wrong, the terminal is most likely still set to `monospace` or "system default", which sends the icons through font fallback. Set the font explicitly. In `GNOME Terminal` you must also untick *Use the system fixed width font*, otherwise the font you chose is silently ignored.

### `yazi` reports "Cannot find 'file'"

The `file` command is missing. `yazi` uses it to work out the type of every file, so without it nothing can be previewed at all.

It is installed automatically when `sudo` is available. Otherwise install the `file` package by hand.

### `yazi` reports "failed to spawn chafa"

`chafa` is missing.

When the terminal has no graphics protocol, `yazi` draws images as coloured text using `chafa`. That covers `GNOME Terminal` and most terminals reached over SSH. It is installed automatically when `sudo` is available; otherwise install the `chafa` package by hand.

### Images never appear, but everything else previews fine

Expected in a terminal without a graphics protocol, unless `chafa` is installed. With `chafa` the image appears as coloured blocks. For sharp images, use a terminal that supports a graphics protocol, such as `kitty`, `WezTerm` or `Ghostty`.

### Images come out as streams of symbols such as `++++`

The terminal supports a graphics protocol, so `yazi` sends the image as an escape sequence, but something between `yazi` and the terminal is failing to consume it, and the raw payload is printed as text instead.

Almost always a multiplexer layer. `tmux` needs `allow-passthrough on`, which the `.tmux.conf` here already sets. Nested multiplexers are the common cause: `yazi` wraps its escape sequences for **one** level of `tmux`, so a `tmux` on the host plus another inside a container is one wrap too few. Run `yazi` under a single `tmux`, or none.

To see what `yazi` decided to do, run:

```bash
ya env
```

`Emulator.probe` shows what it detected, and `Adapter` shows which renderer it chose.

### The prompt symbols look wrong

Make sure the terminal supports and correctly displays UTF-8. If the prompt still does not match the example in the introduction, the font is missing those glyphs; install a Nerd Font as above, or replace the symbols in the prompt config with ones your font has.
