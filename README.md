A very double screeni X window manager.

All the keybinds are quite easy to change, but it will be even easier.

# Installation

Clone the project with git. Then compile it with `v -prod .` (in the project's directory). Go to a tty (by disabling your autostarting window manager) and then run: `startx ~/...path to the project's directory.../tinyvvm`.

## Keybinds 

- Super+Shift+E -> Quit the wm
- Super+D -> Application launcher (rofi)
- Super+L -> Cycle up in the windows of the current desktop
- Super+K -> Cycle down 
- Super+Tab -> Go to the other desktop
- Super+(1,2,3,4,5,6,7,8,9,0) -> Rise the window associated with the number* on the current desktop
- Super+Delete -> Ask the current window to close itself
- Super+N -> toggle wifi (nmcli)
- Super+B -> Toggle bluetooth (bluetoothctl)
- Super+V -> Raise volume (amixer)
- Super+Shift+V -> Lower volume (amixer)
- Super+C -> Raise brightness (brightnessctl)
- Super+Shift+C -> Lower brightness (brightnessctl)
- Super+Enter -> Open a terminal (alacritty)

* the windows are associated with a number depending on the order they were spawned. First window: 0, second: 1 etc... 
