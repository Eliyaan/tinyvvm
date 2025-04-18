const terminal_name = 'alacritty'
const terminal_key = KeyMod{C.XK_Return, mod_super}
const close_key = KeyMod{C.XK_BackSpace, mod_super}
const wm_quit_key = KeyMod{C.XK_E, mod_super | mod_shift}
const desktop_key = KeyMod{C.XK_Tab, mod_super}
const launch_app_key = KeyMod{C.XK_D, mod_super}
const launch_app_name = 'rofi -show drun'
const wifi_key = KeyMod{C.XK_N, mod_super}
const wifi_name = 'nmcli r wifi'
const screenshot_key = KeyMod{C.XK_G, mod_super}
const screenshot_name = 'ksnip -r'
const sound_up_key = KeyMod{C.XK_V, mod_super}
const sound_up_name = 'pamixer -i 5'
const sound_down_key = KeyMod{C.XK_V, mod_super | mod_shift}
const sound_down_name = 'pamixer -d 5'
const bluetooth_key = KeyMod{C.XK_B, mod_super}
const bluetooth_name = 'bluetoothctl power'
const bright_up_key = KeyMod{C.XK_C, mod_super}
const bright_up_name = 'brightnessctl set 1000+'
const bright_down_key = KeyMod{C.XK_C, mod_super | mod_shift}
const bright_down_name = 'brightnessctl set 1000-'

// Dimentions of the first screen (in pixels)
const width = 1366
const height = 768
