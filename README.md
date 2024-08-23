A very simple, efficient and lightweight double screen X window manager.

## Why?

The goal of this project is to show that it's easy to make your custom window manager, that we dont need to waste GBs of ram when showing windows and to provide a window manager that you can understand by looking at the code (so that you can shape it according to your needs or create your own entirely). 

A very big motivation for this project is to show that it is simple to do your own things and that we can make simple and lightweight software. Simple and lightweight often go hand in hand. Dont hesitate to try to do your own things, it may be scary because the existing well known projects have enormous code bases but we dont need this much to make a simple wm (`tinyvvm.v` ~400LoC). 

So this project is here to help anyone who :
- wants to make their own window manager
- to see how one works 
- to have somewhere to start
- wants a lightweight usable window manager (I use it as my everyday wm and it's the first one I dont complain about (very happy about that), so it's usable)

The essential code that you will modify if you want to is in `tinyvvm.v` (only ~400LoC).

## Installation

- Clone the project with git. 
- Then compile it by running `v .` in the project's directory (or `v -prod -autofree .` to create an optimized executable).
- Disabling your autostarting window manager if needed (on gnome fedora I think I used :`systemctl disable gdm.service` ), and quit it (by rebooting if you dont know another way)
- Run in the terminal after booting is finished : `startx ~/...path to the project's directory.../tinyvvm`.

## Keybinds 

The keybinds / commands associated to them are changeable in `config.v` (you need to recompile and relaunch the wm for the changes to take place).

- Super+Shift+E -> Quit the wm
- Super+D -> Application launcher (rofi)
- Super+L -> Cycle up in the windows of the current desktop
- Super+K -> Cycle down 
- Super+(1,2,3,4,5,6,7,8,9) -> Rise the window associated with the number¹ on the current desktop
- Super+R -> refocus window (in case its not automatic²)
- Super+Tab -> Go to the other desktop
- Super+Delete -> Ask the current window to close itself
- Super+N -> toggle wifi (nmcli)
- Super+B -> Toggle bluetooth (bluetoothctl)
- Super+V -> Raise volume (amixer)
- Super+Shift+V -> Lower volume (amixer)
- Super+C -> Raise brightness (brightnessctl)
- Super+Shift+C -> Lower brightness (brightnessctl)
- Super+Enter -> Open a terminal (alacritty)


¹the windows are associated with a number depending on the order they were spawned. First window: 0, second: 1 etc... 

²if you can reproduce a situation where it does not focus, please open an issue so we can keep track of it

A big thanks to tinywm for showing how to do it: https://github.com/mackstann/tinywm
