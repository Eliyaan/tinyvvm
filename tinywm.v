import os
import time

const mod_super = C.Mod4Mask
const mod_shift = C.ShiftMask

const terminal_name = 'alacritty'
const terminal_key = KeyMod{C.XK_Return, mod_super}
const close_key = KeyMod{C.XK_BackSpace, mod_super}
const wm_quit_key = KeyMod{C.XK_E, mod_super | mod_shift}
// Get them automatically for the current window
const width = 1366
const height = 768
const double_x = 1366
const double_y = 0
const double_w = 1920
const double_h = 1080
const catched_events = i32(C.SubstructureNotifyMask | C.StructureNotifyMask | C.KeyPressMask | C.KeyReleaseMask | C.ButtonPressMask | C.ButtonReleaseMask)

const dpy = C.XOpenDisplay(unsafe { nil })
const root = C.XDefaultRootWindow(dpy)

struct WinMan {
mut:
	ev      C.XEvent
	windows []C.Window
	is_double []bool
	win_nb  int
	double bool
	double_nb int
}

fn grab_keys() {
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_Tab), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_D), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_N), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_G), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_B), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_V), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_C), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_V), mod_super | mod_shift, root, true,
		C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_C), mod_super | mod_shift, root, true,
		C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_1), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_2), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_3), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_4), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_5), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_6), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_7), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_8), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_9), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_0), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_L), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_H), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, wm_quit_key.key), wm_quit_key.mod, root, true,
		C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, close_key.key), close_key.mod, root, true,
		C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, terminal_key.key), terminal_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
}

fn (wm WinMan) close_window() {
	mut ke := C.XEvent{
		@type: C.ClientMessage
	}
	unsafe {
		ke.xclient.window = wm.windows[wm.win_nb]
		ke.xclient.message_type = C.XInternAtom(dpy, c'WM_PROTOCOLS', true)
		ke.xclient.format = 32
		ke.xclient.data.l[0] = C.XInternAtom(dpy, c'WM_DELETE_WINDOW', true)
		ke.xclient.data.l[1] = C.CurrentTime
	}
	C.XSendEvent(dpy, wm.windows[wm.win_nb], false, C.NoEventMask, &ke)
}

fn (mut wm WinMan) show_window() {
	mut nb := if wm.double {
		wm.double_nb
	} else {
		wm.win_nb
	}
	if wm.windows.len > 0 {
		if nb >= wm.windows.len {
			nb = 0
		} else if wm.win_nb < 0 {
			nb = wm.windows.len - 1
		}
		C.XRaiseWindow(dpy, wm.windows[nb])
		C.XSetInputFocus(dpy, wm.windows[nb], C.RevertToPointerRoot, C.CurrentTime)
		wm.is_double[nb] = wm.double
		if wm.double {
			C.XMoveResizeWindow(dpy, wm.windows[nb], double_x, double_y, double_w, double_h)
			wm.double_nb = nb
		} else {
			C.XMoveResizeWindow(dpy, wm.windows[nb], 0, 0, width, height)
			wm.win_nb = nb
		}
	}
}

fn error_handler(display &C.Display, event &C.XErrorEvent) int {
	error_message := []u8{len: 256}
	C.XGetErrorText(display, event.error_code, error_message.data, error_message.len)
	eprintln(unsafe { cstring_to_vstring(error_message.data) })
	return 0
}

fn main() {
	mut wm := WinMan{}

	C.XSetErrorHandler(error_handler)

	attr := C.XSetWindowAttributes{
		event_mask: catched_events
	}
	C.XChangeWindowAttributes(dpy, C.XDefaultRootWindow(dpy), C.CWEventMask, &attr)

	grab_keys()

	for {
		time.sleep(10 * time.millisecond)
		C.XNextEvent(dpy, &wm.ev)
		match unsafe { wm.ev.@type } {
			// C.ButtonPress {
			//	C.XSetInputFocus(dpy, unsafe { wm.ev.xbutton.window }, C.RevertToPointerRoot,
			//		C.CurrentTime)
			//}
			// C.ButtonRelease {
			//	C.XSetInputFocus(dpy, unsafe { wm.ev.xbutton.window }, C.RevertToPointerRoot,
			//		C.CurrentTime)
			//}
			C.KeyPress {
				key := unsafe { wm.ev.xkey }
				if key.keycode == C.XKeysymToKeycode(dpy, terminal_key.key)
					&& key.state ^ terminal_key.mod == 0 {
					spawn os.execute(terminal_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, close_key.key)
					&& key.state ^ close_key.mod == 0 {
					wm.close_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, wm_quit_key.key)
					&& key.state ^ wm_quit_key.mod == 0 {
					break
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_N) && key.state ^ C.Mod4Mask == 0 {
					if os.execute('nmcli r wifi').output.contains('enabled') {
						spawn os.execute('nmcli r wifi off')
					} else {
						spawn os.execute('nmcli r wifi on')
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_Tab) && key.state ^ mod_super == 0 {
					wm.double = !wm.double
					if wm.double {
						if wm.is_double[wm.double_nb] {
							wm.show_window()
						}
					} else {
						if !wm.is_double[wm.win_nb] {
							wm.show_window()
						}
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_G) && key.state ^ mod_super == 0 {
					spawn os.execute('ksnip -r')
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_D) && key.state ^ mod_super == 0 {
					spawn os.execute('rofi -show drun')
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_V) && key.state ^ mod_super == 0 {
					spawn os.execute("amixer sset 'Master' 5%+")
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_V)
					&& key.state ^ (mod_super | mod_shift) == 0 {
					spawn os.execute("amixer sset 'Master' 5%-")
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_C) && key.state ^ mod_super == 0 {
					spawn os.execute('brightnessctl set 1000+')
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_C)
					&& key.state ^ (mod_super | mod_shift) == 0 {
					spawn os.execute('brightnessctl set 1000-')
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_B) && key.state ^ mod_super == 0 {
					if os.execute("bluetoothctl show | awk 'NR==7 {printf $2}'").output.contains('no') {
						spawn os.execute('bluetoothctl power on')
					} else {
						spawn os.execute('bluetoothctl power off')
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_L) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb += 1
					} else {
						wm.win_nb += 1
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_H) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb -= 1
					} else {
						wm.win_nb -= 1
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_1) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 0
					} else {
						wm.win_nb = 0
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_2) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 1
					} else {
						wm.win_nb = 1
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_3) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 2
					} else {
						wm.win_nb = 2
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_4) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 3
					} else {
						wm.win_nb = 3
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_5) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 4
					} else {
						wm.win_nb = 4
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_6) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 5
					} else {
						wm.win_nb = 5
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_7) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 6
					} else {
						wm.win_nb = 6
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_8) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 7
					} else {
						wm.win_nb = 7
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_9) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 8
					} else {
						wm.win_nb = 8
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_0) && key.state ^ mod_super == 0 {
					if wm.double {
						wm.double_nb = 9
					} else {
						wm.win_nb = 9
					}
					wm.show_window()
				}
			}
			C.CreateNotify {}
			C.MapNotify {
				if unsafe { !wm.ev.xmap.override_redirect } {
					wm.windows << unsafe { wm.ev.xmap.window }
					wm.is_double << wm.double
					if wm.double {
						wm.double_nb = wm.windows.len - 1
					} else {
						wm.win_nb = wm.windows.len - 1
					}
					wm.show_window()
				}
			}
			C.UnmapNotify {
				unmapped_i := wm.windows.index(unsafe { wm.ev.xunmap.window })
				if unmapped_i != -1 {
					wm.windows.delete(unmapped_i)
					wm.is_double.delete(unmapped_i)
					wm.show_window()
				}
			}
			else {}
		}
	}
	C.XSetErrorHandler(unsafe { nil })
}
