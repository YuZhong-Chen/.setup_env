# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="jovial"
# ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git git-extras zsh-syntax-highlighting zsh-autosuggestions sudo web-search dirhistory jovial)

source $ZSH/oh-my-zsh.sh

if [ -n "${ROS_DISTRO:-}" ]; then
    if [ -n "${CATKIN_WS:-}" ]; then
        export ROS_HOSTNAME="127.0.0.1"
        export ROS_MASTER_URI=http://127.0.0.1:11311
        source /opt/ros/$ROS_DISTRO/setup.zsh
        source $CATKIN_WS/devel/setup.zsh
    elif [ -n "${ROS2_WS:-}" ]; then
        source /opt/ros/$ROS_DISTRO/setup.zsh
        source $ROS2_WS/install/setup.zsh
        source /usr/share/colcon_cd/function/colcon_cd.sh
        source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.zsh
        export _colcon_cd_root=/opt/ros/$ROS_DISTRO/
        eval "$(register-python-argcomplete3 ros2)"
    fi
fi

# Set locale
export LC_ALL=C.UTF-8

# Open tmux by default with the lowest available session number (Optimized)
if [ -z "${TMUX:-}" ]; then
    # If no tmux server is running, create session 0 directly
    if ! tmux ls >/dev/null 2>&1; then
        tmux new-session -s 0
    else
        # 1. Get all purely numeric session names and sort them in ascending order (calls tmux only once)
        # -F '#S' ensures only the session names are outputted
        existing=$(tmux ls -F '#S' 2>/dev/null | grep '^[0-9]\+$' | sort -n)
        # 2. Find the lowest available (missing) number
        target=0
        for s in $existing; do
            if [ "$s" -eq "$target" ]; then
                target=$((target + 1))
            elif [ "$s" -gt "$target" ]; then
                break # Found the gap/missing number!
            fi
        done
        # 3. Create and attach to the session with that number
        tmux new-session -s "$target"
    fi
fi

# Open folder GUI in terminal
function open-folder() {
    if [ -d "$1" ]; then
        xdg-open "$1"
    else
        # echo "Folder $1 does not exist"
        xdg-open .
    fi
}
