#!/bin/bash
# Installs the yazi terminal file manager from the official prebuilt binary.
#
# The same binary is used whether or not sudo is available, so there is only
# one install path to maintain. Only the destination differs.

install_yazi() {
    local MODULE="yazi"

    # Map the machine architecture onto yazi's release naming.
    # The musl builds are statically linked, so they need no runtime deps.
    local arch target
    arch="$(uname -m)"
    case "$arch" in
        x86_64)
            target="x86_64-unknown-linux-musl"
            ;;
        aarch64|arm64)
            target="aarch64-unknown-linux-musl"
            ;;
        *)
            warn "Unsupported architecture '${arch}'. Skipping yazi."
            return 0
            ;;
    esac

    # curl and unzip fetch and unpack the release. 'file' is what yazi uses to
    # detect MIME types, so it is required rather than optional; without it
    # yazi cannot work out how to preview anything.
    apt_install curl unzip ca-certificates file

    local cmd
    for cmd in curl unzip; do
        if ! have "$cmd"; then
            warn "'${cmd}' is required but not installed. Skipping yazi."
            log "Install it manually, then re-run this module."
            return 0
        fi
    done
    if ! have file; then
        warn "'file' is not installed."
        log "yazi needs it to detect file types. Without it you will see"
        log "\"Cannot find 'file'\" and no previews will render."
    fi

    # With sudo the binaries go system-wide, otherwise into the user's own bin.
    local bindir
    if [[ "$NO_SUDO" -eq 0 ]]; then
        bindir="/usr/local/bin"
    else
        bindir="${HOME}/.local/bin"
        mkdir -p "$bindir"
    fi

    local tmpdir
    tmpdir="$(mktemp -d)"

    # "latest/download" resolves server-side, so this needs no GitHub API call
    # and therefore cannot be rate limited during a container build.
    log "Downloading the latest prebuilt binary for ${target} ..."
    if ! curl -fL --retry 3 --retry-delay 2 \
        "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${target}.zip" \
        -o "${tmpdir}/yazi.zip"; then
        warn "Download failed. Skipping yazi."
        rm -rf "$tmpdir"
        return 0
    fi

    if ! unzip -qo "${tmpdir}/yazi.zip" -d "$tmpdir"; then
        warn "Failed to unpack the archive. Skipping yazi."
        rm -rf "$tmpdir"
        return 0
    fi

    local srcdir="${tmpdir}/yazi-${target}"
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo install -m 755 "${srcdir}/yazi" "${srcdir}/ya" "${bindir}/"
    else
        install -m 755 "${srcdir}/yazi" "${srcdir}/ya" "${bindir}/"
    fi
    log "Installed yazi and ya into ${bindir}"

    # Make the binaries reachable in this shell too, so the plugin step
    # below can call "ya" even when it went to ~/.local/bin.
    export PATH="${bindir}:${PATH}"

    # Shell completions. Both destinations are searched by default and need
    # no root, so this works the same in either mode.
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
        mkdir -p ~/.oh-my-zsh/completions
        cp "${srcdir}/completions/_yazi" "${srcdir}/completions/_ya" ~/.oh-my-zsh/completions/
    else
        mkdir -p ~/.local/share/bash-completion/completions
        cp "${srcdir}/completions/yazi.bash" ~/.local/share/bash-completion/completions/yazi
        cp "${srcdir}/completions/ya.bash" ~/.local/share/bash-completion/completions/ya
    fi

    rm -rf "$tmpdir"

    # ~/.local/bin is not on PATH in every shell, so make sure it is.
    if [[ "$NO_SUDO" -eq 1 ]]; then
        local rcfile
        if [[ "$CURRENT_SHELL" == "zsh" ]]; then
            rcfile=~/.zshrc
        else
            rcfile=~/.bashrc
        fi
        if ! grep -qF '.local/bin' "$rcfile" &> /dev/null; then
            echo "" >> "$rcfile"
            echo "# Added by .setup_env, so that user-local binaries are found." >> "$rcfile"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rcfile"
        fi
    fi

    # Optional dependencies that unlock yazi's richer previews.
    if [[ "$NO_SUDO" -eq 0 ]]; then
        # chafa renders images as coloured text. yazi falls back to it on any
        # terminal without a graphics protocol, which includes most terminals
        # reached over SSH, so it is what makes image preview work at all here.
        apt_install ffmpeg jq poppler-utils chafa
        apt_install 7zip || apt_install p7zip-full
    else
        log "Skipping optional preview dependencies, since sudo is not used."
        log "For video, PDF and archive previews, these are needed:"
        log "    ffmpeg jq poppler-utils 7zip chafa"
        log "Without 'chafa', yazi reports \"failed to spawn chafa\" on"
        log "terminals that have no graphics protocol."
        log "Note that 'file' is required, not optional."
    fi

    install_yazi_plugins
}

# Installs the plugins declared in yazi_config/package.toml.
#
# The config is shipped in this repository rather than generated, so every
# machine ends up on the same pinned plugin revisions.
install_yazi_plugins() {
    local MODULE="yazi"

    if ! have ya; then
        warn "'ya' was not found, so plugins were not installed."
        return 0
    fi

    mkdir -p ~/.config/yazi
    cp "${REPO_DIR}/yazi_config/package.toml" ~/.config/yazi/
    cp "${REPO_DIR}/yazi_config/keymap.toml" ~/.config/yazi/

    # "ya pkg install" installs everything package.toml declares, at the
    # pinned revision, and does nothing for plugins that are already present.
    log "Installing plugins ..."
    if ya pkg install; then
        log "Plugins installed."
    else
        warn "Plugin installation failed. yazi itself still works."
    fi
}

# Run this module on its own:  ./modules/yazi.sh [--shell zsh] [--no-sudo]
#
# This is the usual way to add yazi to a machine that was set up with an
# earlier version of this repository: git pull, then run just this module.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/common.sh"
    parse_common_args "$@"
    install_yazi
fi
