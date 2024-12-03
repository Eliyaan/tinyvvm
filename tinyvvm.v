import os
import time
#include <X11/Xlib.h>
#include <X11/keysym.h>
#flag -lX11


const mod_super = C.Mod4Mask
const mod_shift = C.ShiftMask

// Get them automatically for the current window
const catched_events = i32(C.SubstructureNotifyMask | C.StructureNotifyMask | C.KeyPressMask | C.KeyReleaseMask | C.ButtonPressMask | C.ButtonReleaseMask)

const dpy = C.XOpenDisplay(unsafe { nil })
const root = C.XDefaultRootWindow(dpy)

struct WinMan {
mut:
	ev           C.XEvent
	windows      []C.Window // usable with number keys
	order_simple []C.Window // go through with H/L keys
	order_double []C.Window
	i_simple     int
	i_double     int
	stack_simple []C.Window // on the first screen
	stack_double []C.Window // second
	double       bool
}

struct KeyMod {
	key KeySym
	mod int // u int
}

type KeyCode = u8
type KeySym = int

fn grab_keys() {
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, desktop_key.key), desktop_key.mod, root, true,
		C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, launch_app_key.key), launch_app_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, wifi_key.key), wifi_key.mod, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, screenshot_key.key), screenshot_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, bluetooth_key.key), bluetooth_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, sound_up_key.key), sound_up_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, bright_up_key.key), bright_up_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, sound_down_key.key), sound_down_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, bright_down_key.key), bright_down_key.mod,
		root, true, C.GrabModeAsync, C.GrabModeAsync)
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
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_L), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_H), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XK_R), mod_super, root, true, C.GrabModeAsync,
		C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, wm_quit_key.key), wm_quit_key.mod, root, true,
		C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, close_key.key), close_key.mod, root, true,
		C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, terminal_key.key), terminal_key.mod, root,
		true, C.GrabModeAsync, C.GrabModeAsync)
}

// Called when asking to close current window
fn (wm WinMan) close_window() {
	if wm.windows.len > 0 {
		mut ke := C.XEvent{
			@type: C.ClientMessage
		}
		unsafe {
			if wm.double {
				if wm.stack_double.len > 0 {
					ke.xclient.window = wm.stack_double.last()
				} else {
					return
				}
			} else {
				if wm.stack_simple.len > 0 {
					ke.xclient.window = wm.stack_simple.last()
				} else {
					return
				}
			}
			ke.xclient.message_type = C.XInternAtom(dpy, c'WM_PROTOCOLS', true)
			ke.xclient.format = 32
			ke.xclient.data.l[0] = C.XInternAtom(dpy, c'WM_DELETE_WINDOW', true)
			ke.xclient.data.l[1] = C.CurrentTime
		}
		if wm.double {
			C.XSendEvent(dpy, wm.stack_double.last(), false, C.NoEventMask, &ke)
		} else {
			C.XSendEvent(dpy, wm.stack_simple.last(), false, C.NoEventMask, &ke)
		}
	}
}

fn (mut wm WinMan) show_window() {
	if (!wm.double && wm.stack_simple.len > 0) || (wm.double && wm.stack_double.len > 0) {
		win := if wm.double {
			wm.stack_double.last()
		} else {
			wm.stack_simple.last()
		}
		C.XRaiseWindow(dpy, win)
		C.XSetInputFocus(dpy, win, C.RevertToPointerRoot, C.CurrentTime)
		if wm.double {
			wm.i_double = wm.order_double.index(win)
			C.XMoveResizeWindow(dpy, win, double_x, double_y, double_w, double_h)
		} else {
			wm.i_simple = wm.order_simple.index(win)
			C.XMoveResizeWindow(dpy, win, 0, 0, width, height)
		}
	}
}

fn error_handler(display &C.Display, event &C.XErrorEvent) int {
	error_message := []u8{len: 256}
	C.XGetErrorText(display, event.error_code, error_message.data, error_message.len)
	eprintln(unsafe { cstring_to_vstring(error_message.data) })
	return 0
}

fn (mut wm WinMan) check_goto_window(nb_key int, key C.XKeyEvent) {
	if key.keycode == C.XKeysymToKeycode(dpy, nb_key) && key.state ^ mod_super == 0 {
		win := wm.windows[nb_key - 0x31] or { return } // https://www.cl.cam.ac.uk/~mgk25/ucs/keysymdef.h
		if wm.double {
			i := wm.order_double.index(win)
			if i != -1 {
				s_i := wm.stack_double.index(win)
				wm.stack_double.delete(s_i)
				wm.stack_double << win
				wm.i_double = i
			} else {
				o_i := wm.order_simple.index(win)
				wm.order_simple.delete(o_i)
				s_i := wm.stack_simple.index(win)
				wm.stack_simple.delete(s_i)
				wm.i_double = wm.order_double.len
				wm.order_double << win
				wm.stack_double << win
			}
		} else {
			i := wm.order_simple.index(win)
			if i != -1 {
				s_i := wm.stack_simple.index(win)
				wm.stack_simple.delete(s_i)
				wm.stack_simple << win
				wm.i_double = i
			} else {
				o_i := wm.order_double.index(win)
				wm.order_double.delete(o_i)
				s_i := wm.stack_double.index(win)
				wm.stack_double.delete(s_i)
				wm.i_simple = wm.order_simple.len
				wm.order_simple << win
				wm.stack_simple << win
			}
		}
		wm.show_window()
	}
}

fn main() {
	mut wm := WinMan{}

	C.XSetErrorHandler(error_handler)

	attr := C.XSetWindowAttributes{
		event_mask: catched_events
	}
	C.XChangeWindowAttributes(dpy, C.XDefaultRootWindow(dpy), C.CWEventMask, &attr)

	grab_keys()

	main_l: for {
		C.XNextEvent(dpy, &wm.ev)
		match unsafe { wm.ev.@type } {
			C.ButtonPress {}
			C.ButtonRelease {}
			C.CirculateNotify {}
			C.MotionNotify {}
			C.EnterNotify {}
			C.LeaveNotify {}
			C.KeyRelease {}
			C.FocusIn {}
			C.FocusOut {}
			C.KeymapNotify {}
			C.Expose {}
			C.GraphicsExpose {}
			C.NoExpose {}
			C.CirculateRequest {}
			C.MapRequest {}
			C.ResizeRequest {}
			C.ConfigureNotify {}
			C.DestroyNotify {}
			C.GravityNotify {}
			C.MappingNotify {}
			C.ReparentNotify {}
			C.VisibilityNotify {}
			C.ColormapNotify {}
			C.ClientMessage {}
			C.PropertyNotify {}
			C.SelectionClear {}
			C.SelectionNotify {}
			C.SelectionRequest {}
			C.KeyPress {
				key := unsafe { wm.ev.xkey }
				if key.keycode == C.XKeysymToKeycode(dpy, terminal_key.key)
					&& key.state == terminal_key.mod {
					spawn os.execute(terminal_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, close_key.key)
					&& key.state == close_key.mod {
					wm.close_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, wm_quit_key.key)
					&& key.state == wm_quit_key.mod {
					break
				}
				if key.keycode == C.XKeysymToKeycode(dpy, wifi_key.key) && key.state == wifi_key.mod {
					if os.execute('nmcli r wifi').output.contains('enabled') {
						spawn os.execute(wifi_name + ' off')
					} else {
						spawn os.execute(wifi_name + ' on')
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, desktop_key.key)
					&& key.state == desktop_key.mod {
					wm.double = !wm.double // change of screen
					if wm.double {
						if wm.order_double.len > 0 {
							wm.show_window()
						}
					} else {
						if wm.order_simple.len > 0 {
							wm.show_window()
						}
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_R) && key.state == mod_super { // refocus if did not work auto (need to investigate)
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, screenshot_key.key)
					&& key.state == screenshot_key.mod {
					spawn os.execute(screenshot_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, launch_app_key.key)
					&& key.state == launch_app_key.mod {
					spawn os.execute(launch_app_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, sound_up_key.key)
					&& key.state == sound_up_key.mod {
					spawn os.execute(sound_up_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, sound_down_key.key)
					&& key.state == sound_down_key.mod {
					spawn os.execute(sound_down_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, bright_up_key.key)
					&& key.state == bright_up_key.mod {
					spawn os.execute(bright_up_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, bright_down_key.key)
					&& key.state == bright_down_key.mod {
					spawn os.execute(bright_down_name)
				}
				if key.keycode == C.XKeysymToKeycode(dpy, bluetooth_key.key)
					&& key.state == bluetooth_key.mod {
					if os.execute("bluetoothctl show | awk 'NR==7 {printf $2}'").output.contains('no') {
						spawn os.execute(bluetooth_name + ' on')
					} else {
						spawn os.execute(bluetooth_name + ' off')
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_L) && key.state == mod_super {
					if wm.double {
						if wm.order_double.len > 0 {
							wm.i_double += 1
							if wm.i_double >= wm.order_double.len {
								wm.i_double = 0
							}
							win := wm.order_double[wm.i_double]
							s_i := wm.stack_double.index(win)
							wm.stack_double.delete(s_i)
							wm.stack_double << win
						} else {
							continue main_l
						}
					} else {
						if wm.order_simple.len > 0 {
							wm.i_simple += 1
							if wm.i_simple >= wm.order_simple.len {
								wm.i_simple = 0
							}
							win := wm.order_simple[wm.i_simple]
							s_i := wm.stack_simple.index(win)
							wm.stack_simple.delete(s_i)
							wm.stack_simple << win
						} else {
							continue main_l
						}
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_H) && key.state == mod_super {
					if wm.double {
						if wm.order_double.len > 0 {
							wm.i_double -= 1
							if wm.i_double < 0 {
								wm.i_double = wm.order_double.len - 1
							}
							win := wm.order_double[wm.i_double]
							s_i := wm.stack_double.index(win)
							wm.stack_double.delete(s_i)
							wm.stack_double << win
						} else {
							continue main_l
						}
					} else {
						if wm.order_simple.len > 0 {
							wm.i_simple -= 1
							if wm.i_simple < 0 {
								wm.i_simple = wm.order_simple.len - 1
							}
							win := wm.order_simple[wm.i_simple]
							s_i := wm.stack_simple.index(win)
							wm.stack_simple.delete(s_i)
							wm.stack_simple << win
						} else {
							continue main_l
						}
					}
					wm.show_window()
				}
				wm.check_goto_window(C.XK_1, key)
				wm.check_goto_window(C.XK_2, key)
				wm.check_goto_window(C.XK_3, key)
				wm.check_goto_window(C.XK_4, key)
				wm.check_goto_window(C.XK_5, key)
				wm.check_goto_window(C.XK_6, key)
				wm.check_goto_window(C.XK_7, key)
				wm.check_goto_window(C.XK_8, key)
				wm.check_goto_window(C.XK_9, key)
			}
			C.CreateNotify {}
			C.MapNotify {
				if unsafe { !wm.ev.xmap.override_redirect } {
					wm.windows << unsafe { wm.ev.xmap.window }
					if wm.double {
						wm.stack_double << wm.windows.last()
						wm.order_double << wm.windows.last()
						wm.i_double = wm.order_double.len - 1
					} else {
						wm.stack_simple << wm.windows.last()
						wm.order_simple << wm.windows.last()
						wm.i_simple = wm.order_simple.len - 1
					}
					wm.show_window()
				}
			}
			C.UnmapNotify {
				win := unsafe { wm.ev.xunmap.window }
				unmapped_i := wm.windows.index(win)
				if unmapped_i != -1 {
					wm.windows.delete(unmapped_i)
					if win in wm.order_double {
						o_i := wm.order_double.index(win)
						wm.order_double.delete(o_i)
						s_i := wm.stack_double.index(win)
						wm.stack_double.delete(s_i)
					} else {
						o_i := wm.order_simple.index(win)
						wm.order_simple.delete(o_i)
						s_i := wm.stack_simple.index(win)
						wm.stack_simple.delete(s_i)
					}
					wm.show_window()
				}
			}
			else {
				time.sleep(30 * time.millisecond)
			}
		}
	}
	C.XSetErrorHandler(unsafe { nil })
}
