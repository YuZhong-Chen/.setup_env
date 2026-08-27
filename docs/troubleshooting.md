# 🔍 Troubleshooting 🔍

Each entry starts with what you actually see on screen.

## The icons are Chinese characters

Nerd Font icons live in the Unicode Private Use Area, `U+E000`–`U+F8FF`. Some CJK fonts map Chinese glyphs into that same range, so when one of them wins font fallback you get Chinese characters where the icons should be. On Debian and Ubuntu the usual culprits are `fonts-arphic-uming` and `fonts-arphic-ukai`.

Ask fontconfig which font is answering:

```bash
fc-match ":charset=e702" family
```

If that names a CJK font instead of a Nerd Font, add a rule under `~/.config/fontconfig/conf.d/` that subtracts `U+E000-U+F8FF` from those two families only, then run `fc-cache -f`. Their normal CJK coverage is untouched, so Chinese text still renders correctly.

## The icons are boxes, question marks or blank gaps

No Nerd Font is installed on the machine you are sitting at, or the terminal is not actually using it.

Fonts are rendered by **your** terminal, never by the server, so installing a font on a remote host or inside a container changes nothing. Install it locally: [Installing a Nerd Font](yazi.md#installing-a-nerd-font).

If the font is installed and the icons are still wrong, the terminal is most likely still set to `monospace` or "system default", which sends the icons through font fallback. Set the font explicitly. In `GNOME Terminal` you must also untick *Use the system fixed width font*, otherwise the font you chose is silently ignored.

## `yazi` reports "Cannot find 'file'"

The `file` command is missing. `yazi` uses it to work out the type of every file, so without it nothing can be previewed at all.

It is installed automatically when `sudo` is available. Otherwise install the `file` package by hand.

## `yazi` reports "failed to spawn chafa"

`chafa` is missing.

When the terminal has no graphics protocol, `yazi` draws images as coloured text using `chafa`. That covers `GNOME Terminal` and most terminals reached over SSH. It is installed automatically when `sudo` is available; otherwise install the `chafa` package by hand.

## Images never appear, but everything else previews fine

Expected in a terminal without a graphics protocol, unless `chafa` is installed. With `chafa` the image appears as coloured blocks. For sharp images, use a terminal that supports a graphics protocol, such as `kitty`, `WezTerm` or `Ghostty`.

## Images come out as streams of symbols such as `++++`

The terminal supports a graphics protocol, so `yazi` sends the image as an escape sequence, but something between `yazi` and the terminal is failing to consume it, and the raw payload is printed as text instead.

Almost always a multiplexer layer. `tmux` needs `allow-passthrough on`, which the `.tmux.conf` here already sets. Nested multiplexers are the common cause: `yazi` wraps its escape sequences for **one** level of `tmux`, so a `tmux` on the host plus another inside a container is one wrap too few. Run `yazi` under a single `tmux`, or none.

To see what `yazi` decided to do, run:

```bash
ya env
```

`Emulator.probe` shows what it detected, and `Adapter` shows which renderer it chose.

## The prompt symbols look wrong

Make sure the terminal supports and correctly displays UTF-8. If the prompt still does not match the example in the [README](../README.md), the font is missing those glyphs; install a [Nerd Font](yazi.md#installing-a-nerd-font), or replace the symbols in the prompt config with ones your font has.
