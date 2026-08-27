# 📘 Configuration of `tmux` 📘

## Key Bindings

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

## Commands

- `tmux`: Start a new tmux session.
- `tmux ls`: List all tmux sessions.
- `tmux attach`: Attach to the last tmux session.
- `tmux attach -t <session_number>`: Attach to a specific tmux session.
- `tmux kill-session -t <session_number>`: Kill a specific tmux session.
- `tmux kill-server`: Kill all tmux sessions.
