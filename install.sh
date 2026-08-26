#!/bin/bash

# Get the directory of this script.
# Reference: https://stackoverflow.com/q/59895
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

# Read the variable
CURRENT_SHELL="bash"
NO_SUDO=0
INSTALL_YAZI=1
while [[ $# -gt 0 ]]; do
    case "$1" in
        --shell)
            shift
            if [[ $# -gt 0 ]]; then
                if [[ "$1" != "bash" && "$1" != "zsh" ]]; then
                    echo "Invalid shell type. Supported types are 'bash' and 'zsh'."
                    exit 1
                fi
                CURRENT_SHELL="$1"
            else
                echo "No shell type specified."
                echo "Usage: $0 --shell <shell_type>"
                exit 1
            fi
            ;;
        --no-sudo)
            NO_SUDO=1
            ;;
        --no-yazi)
            INSTALL_YAZI=0
            ;;
        --help|-h)
            echo "Usage: $0 [--shell <shell_type>] [--no-sudo] [--no-yazi] [--help|-h]"
            echo "Options:"
            echo "  --shell <shell_type>   Specify the shell type (default: bash)"
            echo "  --no-sudo              Do not use sudo for package installations"
            echo "  --no-yazi              Skip installing the yazi file manager"
            echo "  --help, -h             Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Update package list, and install necessary packages
if [[ "$NO_SUDO" -eq 0 ]]; then
    sudo apt update
    sudo apt install -y git
fi

# Install zsh
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    # Install zsh
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo apt install -y zsh
    fi
    # Clone the oh-my-zsh repository and set up plugins
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    mkdir -p ~/.oh-my-zsh/custom/plugins/jovial
    cp "${SCRIPT_DIR}/zsh_config/.zshrc" ~/
    cp "${SCRIPT_DIR}/zsh_config/jovial.zsh-theme" ~/.oh-my-zsh/custom/themes/jovial.zsh-theme
    cp "${SCRIPT_DIR}/zsh_config/jovial.plugin.zsh" ~/.oh-my-zsh/custom/plugins/jovial/jovial.plugin.zsh
    # Set zsh as the default shell.
    # chsh acts on the invoking user, which under sudo is root, so the target
    # user has to be named explicitly. $USER is unset in a Docker RUN, so
    # "id -un" is used instead.
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo chsh -s /bin/zsh "$(id -un)"
    fi
fi

# Configure bash
if [[ "$CURRENT_SHELL" == "bash" ]]; then
    # Install bash-completion
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo apt install -y bash-completion
    fi
    # Copy bash configuration files and set up prompt
    cp "${SCRIPT_DIR}/bash_config/.bash_prompt_config.sh" ~/.bash_prompt_config.sh
    echo "source ~/.bash_prompt_config.sh" >> ~/.bashrc
fi

# Install tmux
if [[ "$NO_SUDO" -eq 0 ]]; then
    sudo apt install -y tmux
fi
cp "${SCRIPT_DIR}/tmux_config/.tmux.conf" ~/
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    # Replace the default shell in .tmux.conf if zsh is used
    sed -i "s/\bbash\b/${CURRENT_SHELL}/g" ~/.tmux.conf
fi
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# Install vim
if [[ "$NO_SUDO" -eq 0 ]]; then
    sudo apt install -y vim
fi
cp "${SCRIPT_DIR}/vim_config/.vimrc" ~/

# Install yazi
# Always installed from the official prebuilt binary, so that the sudo and
# --no-sudo paths stay identical and there is only one thing to maintain.
install_yazi() {
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
            echo "[yazi] Unsupported architecture '${arch}'. Skipping yazi."
            return 0
            ;;
    esac

    # curl and unzip fetch and unpack the release. 'file' is what yazi uses to
    # detect MIME types, so it is required rather than optional; without it
    # yazi cannot work out how to preview anything.
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo apt install -y curl unzip ca-certificates file
    fi
    local cmd
    for cmd in curl unzip; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "[yazi] '${cmd}' is required but not installed. Skipping yazi."
            echo "[yazi] Install it manually, then re-run this script."
            return 0
        fi
    done
    if ! command -v file &> /dev/null; then
        echo "[yazi] Warning: 'file' is not installed."
        echo "[yazi] yazi needs it to detect file types. Without it you will see"
        echo "[yazi] \"Cannot find 'file'\" and no previews will render."
        echo "[yazi] Install the 'file' package to fix this."
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
    echo "[yazi] Downloading the latest prebuilt binary for ${target} ..."
    if ! curl -fL --retry 3 --retry-delay 2 \
        "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${target}.zip" \
        -o "${tmpdir}/yazi.zip"; then
        echo "[yazi] Download failed. Skipping yazi."
        rm -rf "$tmpdir"
        return 0
    fi

    if ! unzip -qo "${tmpdir}/yazi.zip" -d "$tmpdir"; then
        echo "[yazi] Failed to unpack the archive. Skipping yazi."
        rm -rf "$tmpdir"
        return 0
    fi

    local srcdir="${tmpdir}/yazi-${target}"
    if [[ "$NO_SUDO" -eq 0 ]]; then
        sudo install -m 755 "${srcdir}/yazi" "${srcdir}/ya" "${bindir}/"
    else
        install -m 755 "${srcdir}/yazi" "${srcdir}/ya" "${bindir}/"
    fi
    echo "[yazi] Installed yazi and ya into ${bindir}"

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
        sudo apt install -y ffmpeg jq poppler-utils chafa
        sudo apt install -y 7zip || sudo apt install -y p7zip-full
    else
        echo "[yazi] Skipping optional preview dependencies, since sudo is not used."
        echo "[yazi] For video, PDF and archive previews, these are needed:"
        echo "[yazi]     ffmpeg jq poppler-utils 7zip chafa"
        echo "[yazi] Without 'chafa', yazi reports \"failed to spawn chafa\" on"
        echo "[yazi] terminals that have no graphics protocol."
        echo "[yazi] Note that 'file' is required, not optional."
    fi
}

if [[ "$INSTALL_YAZI" -eq 1 ]]; then
    install_yazi
fi
