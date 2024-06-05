import os

const mod_super = C.Mod4Mask
const mod_shift = C.ShiftMask

const terminal_name = 'alacritty'
const terminal_key = KeyMod{C.XK_Return, mod_super}
const close_key = KeyMod{C.XK_BackSpace, mod_super}
const wm_quit_key = KeyMod{C.XK_E, mod_super | mod_shift}
// Get them automatically for the current window
const width = 1566
const height = 1068

fn main() {
	dpy := C.XOpenDisplay(unsafe { nil })
	mut ev := C.XEvent{}
	mut windows := []C.Window{}
	mut win_nb := -1
	root := C.XDefaultRootWindow(dpy)

	attr := C.XSetWindowAttributes{
		event_mask: i32(C.SubstructureNotifyMask | C.StructureNotifyMask | C.KeyPressMask | C.KeyReleaseMask | C.ButtonPressMask | C.ButtonReleaseMask)
	}
	C.XChangeWindowAttributes(dpy, C.XDefaultRootWindow(dpy), C.CWEventMask, &attr)

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

	for {
		C.XNextEvent(dpy, &ev)
		match unsafe { ev.@type } {
			C.ButtonPress {
				C.XSetInputFocus(dpy, unsafe { ev.xbutton.window }, C.RevertToPointerRoot,
					C.CurrentTime)
			}
			C.ButtonRelease {
				C.XSetInputFocus(dpy, unsafe { ev.xbutton.window }, C.RevertToPointerRoot,
					C.CurrentTime)
			}
			C.KeyPress {
				key := unsafe { ev.xkey }
				if key.keycode == C.XKeysymToKeycode(dpy, terminal_key.key)
					&& key.state ^ terminal_key.mod == 0 {
					spawn os.execute(terminal_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, close_key.key)
					&& key.state ^ close_key.mod == 0 {
					eprintln('TODO close window')
				}
				if key.keycode == C.XKeysymToKeycode(dpy, wm_quit_key.key)
					&& key.state ^ wm_quit_key.mod == 0 {
					break
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_L) && key.state ^ C.Mod4Mask == 0 {
					if windows.len > 0 {
						win_nb += 1
						if win_nb >= windows.len {
							win_nb = 0
						} else if win_nb < 0 {
							win_nb = windows.len - 1
						}
						C.XRaiseWindow(dpy, windows[win_nb])
						C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot,
							C.CurrentTime)
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_H) && key.state ^ C.Mod4Mask == 0 {
					if windows.len > 0 {
						win_nb -= 1
						if win_nb >= windows.len {
							win_nb = 0
						} else if win_nb < 0 {
							win_nb = windows.len - 1
						}
						C.XRaiseWindow(dpy, windows[win_nb])
						C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot,
							C.CurrentTime)
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_1) && key.state ^ mod_super == 0 {
					win_nb = 0
					if windows.len > 0 {
						if win_nb >= windows.len {
							win_nb = 0
						} else if win_nb < 0 {
							win_nb = windows.len - 1
						}
						C.XRaiseWindow(dpy, windows[win_nb])
						C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot,
							C.CurrentTime)
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_2) && key.state ^ mod_super == 0 {
					win_nb = 1
					if windows.len > 0 {
						if win_nb >= windows.len {
							win_nb = 0
						} else if win_nb < 0 {
							win_nb = windows.len - 1
						}
						C.XRaiseWindow(dpy, windows[win_nb])
						C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot,
							C.CurrentTime)
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_3) && key.state ^ mod_super == 0 {
					win_nb = 2
					if windows.len > 0 {
						if win_nb >= windows.len {
							win_nb = 0
						} else if win_nb < 0 {
							win_nb = windows.len - 1
						}
						C.XRaiseWindow(dpy, windows[win_nb])
						C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot,
							C.CurrentTime)
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_4) && key.state ^ mod_super == 0 {
					win_nb = 3
					if windows.len > 0 {
						if win_nb >= windows.len {
							win_nb = 0
						} else if win_nb < 0 {
							win_nb = windows.len - 1
						}
						C.XRaiseWindow(dpy, windows[win_nb])
						C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot,
							C.CurrentTime)
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_5) && key.state ^ mod_super == 0 {
					win_nb = 4
					if windows.len > 0 {
						if win_nb >= windows.len {
							win_nb = 0
						} else if win_nb < 0 {
							win_nb = windows.len - 1
						}
						C.XRaiseWindow(dpy, windows[win_nb])
						C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot,
							C.CurrentTime)
					}
				}
				// TODO map all the keys
			}
			C.CreateNotify {}
			C.MapNotify {
				windows << unsafe { ev.xmap.window }
				C.XMoveResizeWindow(dpy, windows.last(), 0, 0, width, height)
				C.XSetInputFocus(dpy, windows.last(), C.RevertToPointerRoot, C.CurrentTime)
			}
			C.UnmapNotify {
				unmapped_i := windows.index(ev.xunmap.window)
				if unmapped_i != -1 {
					windows.delete(unmapped_i)
				}
				win_nb -= 1
				if windows.len > 0 {
					if win_nb >= windows.len {
						win_nb = 0
					} else if win_nb < 0 {
						win_nb = windows.len - 1
					}
					C.XRaiseWindow(dpy, windows[win_nb])
					C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot, C.CurrentTime)
				}
			}
			else {}
		}
	}
}
