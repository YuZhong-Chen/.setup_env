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

if [ -n "$ZSH_SCRIPT_SETTING" ]; then
    if [ "$ZSH_SCRIPT_SETTING" = "ros1" ]; then
        export ROS_HOSTNAME="127.0.0.1"
        export ROS_MASTER_URI=http://127.0.0.1:11311
        source /opt/ros/$ROS_DISTRO/setup.zsh
        source $CATKIN_WS/devel/setup.zsh
    elif [ "$ZSH_SCRIPT_SETTING" = "ros2" ]; then
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

# Opening tmux at default
if [[ -z $TMUX ]]; then
    tmux
    # exec tmux
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
