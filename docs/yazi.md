# 📂 Configuration of `yazi` 📂

[yazi](https://yazi-rs.github.io) is a terminal file manager. It is installed by default; pass `--no-yazi` to skip it.

## Key Bindings

The ones worth knowing, listed by what you are trying to do. Plugin and default keys are mixed together, since in practice you do not care which is which.

Press `~` or `F1` inside yazi for the complete list, including anything not mentioned here.

### Moving around

- `j` / `k`, or `↓` / `↑`: Next / previous file.
- `l` / `h`, or `→` / `←`: Enter the directory / go back to the parent.
- `L` / `H`: Forward / back through directories you have already visited.
- `g` + `g` / `G`: Jump to the top / bottom of the list.
- `ctrl` + `d` / `ctrl` + `u`: Half a page down / up.
- `g` + `h`: Go to your home directory.
- `g` + `r`: Go to the root of the current git repository.
- `g` + `<Space>`: Type a path and jump straight to it.
- `z` / `Z`: Jump to a file with `fzf` / a directory with `zoxide`. (Both need that tool installed.)

### Selecting files

Most operations act on the selection, or on the hovered file if nothing is selected.

- `<Space>`: Select the current file and move down one.
- `v` / `V`: Visual mode, selecting / unselecting as you move.
- `ctrl` + `a`: Select everything in the directory.
- `ctrl` + `r`: Invert the selection.
- `<Esc>`: Clear the selection, or leave visual mode.

### Working with files

- `<Enter>` or `o`: Open. `O` lets you pick the program.
- `a`: Create a file. End the name with `/` to make a directory instead.
- `r`: Rename. The cursor lands before the extension.
- `d` / `D`: Move to trash / delete permanently.
- `y` / `x`: Copy / cut.
- `p` / `P`: Paste / paste, overwriting anything already there.
- `-` / `_`: Symlink what you yanked, by absolute / relative path.
- `c` + `m`: Change the permissions of the selected files.
- `;` / `:`: Run a shell command. `:` waits for it to finish before returning.

### Finding things

- `/` / `?`: Find by name in this directory, forwards / backwards. `n` and `N` step through matches.
- `f`: Filter the listing down as you type.
- `s` / `S`: Search by filename with `fd` / by file contents with `ripgrep`.
- `g` + `c`: List the files changed in git.
- `.`: Show or hide dotfiles.

### Looking at things

- `<Tab>`: Spot the hovered file, showing its metadata.
- `J` / `K`: Scroll the preview pane without leaving the list.
- `m` + `s` / `p` / `m` / `b` / `o` / `n`: Show size / permissions / modified time / created time / owner / nothing beside each file.

### Sorting

- `,` + `a` / `n` / `e` / `s` / `m`: Sort alphabetically / naturally / by extension / by size / by modified time.
- Use the capital letter to reverse it, so `,` + `A` is reverse alphabetical.

Natural sort is the one that puts `file2` before `file10`; alphabetical does not.

### Tabs and tasks

- `t` + `t`: New tab in the current directory. `t` + `r` renames it.
- `1` … `9`: Switch to that tab. `[` and `]` move to the previous / next one.
- `w`: Show the task manager, for copies and other work still running.

### Leaving

- `q`: Quit.
- `ctrl` + `c`: Close the current tab, or quit if it is the last one.
- `ctrl` + `z`: Suspend yazi. `fg` brings it back.

## How it is installed

The official prebuilt binary is used in both modes, so there is only one install path to maintain:

- With `sudo`: `yazi` and `ya` are installed into `/usr/local/bin`.
- With `--no-sudo`: they go into `~/.local/bin`, and that directory is added to your `PATH` if it is not there already.

The `musl` builds are statically linked, so they run on any Linux without extra runtime dependencies. Both `x86_64` and `aarch64` are supported. To upgrade later, just re-run the script.

`yazi` requires `file` to detect MIME types. It is installed automatically when `sudo` is available, and is normally already present on any real system. Without it `yazi` reports ``Cannot find 'file'`` and renders no previews at all.

Optional preview dependencies (`ffmpeg`, `jq`, `poppler-utils`, `7zip`, `chafa`) are installed only when `sudo` is available. Without them `yazi` still works, but video, PDF, JSON and archive previews are unavailable. Note that Debian and Ubuntu name the 7-Zip binary `7z`, not `7zz` as the upstream `yazi` documentation assumes.

## Plugins

Plugins are declared in `yazi_config/package.toml` and installed with `ya pkg install`, so every machine ends up on the same pinned revision. Everything in `yazi_config/` is copied into `~/.config/yazi/`: `keymap.toml` for keybindings, `yazi.toml` for fetchers, `init.lua` for plugins that need setting up in Lua, and `theme.toml` for how they look.

The git status signs are set to match `git status --short`, so they read the same way as the git CLI: `A` added, `D` deleted, `M` modified, `U` unmerged, `?` untracked, `!` ignored. git separates staged from unstaged by which column the `M` is in; there is only one column here, so both use `M` and the colour separates them, green for staged and yellow for unstaged, as git does.

Currently installed:

| Plugin | What it does |
| --- | --- |
| [chmod](https://github.com/yazi-rs/plugins/tree/main/chmod.yazi) | Change the mode of the selected files |
| [git](https://github.com/yazi-rs/plugins/tree/main/git.yazi) | Shows git status signs next to each file |
| [vcs-files](https://github.com/yazi-rs/plugins/tree/main/vcs-files.yazi) | Lists the files changed in git |

Their keys are in [Key Bindings](#key-bindings), together with everything else.

To add another plugin, add it with `ya pkg add <owner>/<repo>:<plugin>` on one machine, copy the resulting entry from `~/.config/yazi/package.toml` into `yazi_config/package.toml`, then add whatever its README asks for to `yazi_config/keymap.toml`, `yazi_config/yazi.toml` or `yazi_config/init.lua`. Pinning the revision this way keeps every machine on the same version; `ya pkg upgrade` is how you move it forward deliberately. Each plugin pins independently, so the revisions above do not all have to match.

> Note: `g` `c` replaces yazi's default *Go to ~/.config*, because keybindings here are prepended. Check `yazi`'s own keymap before choosing a binding, or you will shadow something silently.

## Installing a Nerd Font

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
