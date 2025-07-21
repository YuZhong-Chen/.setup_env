#!/bin/bash
# Reference: https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html

# Example of the prompt:
# ╭─[machine-name] as user in ~/ on branch (main)*
# └──➤ 

# If current directory is a git repo, display the current branch and whether it is dirty.
function prompt_git() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        local dirty=$(git status --porcelain 2>/dev/null | tail -n 1)
        if [ -n "$dirty" ]; then
            echo -n "on branch (${branch})*"
        else
            echo -n "on branch (${branch})"
        fi
    fi
}

# Colors for the prompt
RESET="\[\e[0m\]"            # reset all attributes
BLACK="\[\e[30m\]"           # black
RED="\[\e[31m\]"             # red
GREEN="\[\e[32m\]"           # green
YELLOW="\[\e[33m\]"          # yellow
BLUE="\[\e[34m\]"            # blue
MAGENTA="\[\e[35m\]"         # magenta (purple)
CYAN="\[\e[36m\]"            # cyan
WHITE="\[\e[37m\]"           # white
BRIGHT_BLACK="\[\e[90m\]"    # bright black (gray)
BRIGHT_RED="\[\e[91m\]"      # bright red
BRIGHT_GREEN="\[\e[92m\]"    # bright green
BRIGHT_YELLOW="\[\e[93m\]"   # bright yellow
BRIGHT_BLUE="\[\e[94m\]"     # bright blue
BRIGHT_MAGENTA="\[\e[95m\]"  # bright magenta
BRIGHT_CYAN="\[\e[96m\]"     # bright cyan
BRIGHT_WHITE="\[\e[97m\]"    # bright white

# Setup the prompt
PS1=''                       # Initialize PS1
PS1+='\n'                    # New line
PS1+="${BRIGHT_BLACK}"
PS1+='╭─['
PS1+="${BRIGHT_GREEN}"
PS1+='\H'                    # Hostname
PS1+="${BRIGHT_BLACK}"
PS1+='] as '
PS1+="${WHITE}"
PS1+='\u'                    # Username
PS1+="${BRIGHT_BLACK}"
PS1+=' in '
PS1+="${YELLOW}"
PS1+='\w'                    # Current working directory
PS1+="${BRIGHT_BLACK}"
PS1+=' $(prompt_git) '       # Add git branch info if available
PS1+='\n'                    # New line
PS1+="╰──➤"
PS1+="${RESET}"              # Reset color
PS1+=' '                     # Trailing space
