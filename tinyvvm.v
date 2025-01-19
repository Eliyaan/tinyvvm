import os
import time

#include <X11/Xlib.h>
#include <X11/keysym.h>
#flag -lX11

// Masks used by X11
const mod_super = C.Mod4Mask
const mod_shift = C.ShiftMask

// Catch these events
const catched_events = i32(C.SubstructureNotifyMask | C.StructureNotifyMask | C.KeyPressMask | C.KeyReleaseMask | C.ButtonPressMask | C.ButtonReleaseMask)

// Provides a root window and a display, as we dont need to change them, needed in a lot of functions calls
const dpy = C.XOpenDisplay(unsafe { nil })
const root = C.XDefaultRootWindow(dpy)

// Constants to manage the size of the different screens
const width = C.XDisplayWidth(dpy, 0) // first screen
const height = C.XDisplayHeight(dpy, 0)
const sec_x = width // for the screen to be adjacent
const sec_y = 0
const sec_w = C.XDisplayWidth(dpy, 1)
const sec_h = C.XDisplayHeight(dpy, 1)

struct WinMan {
mut:
	ev          C.XEvent
	windows     []C.Window // All the opened windows, the number keys 1-9 correspond to (the index + 1) of a window in this array
	order_first []C.Window // First screen: go through with H/L keys, "sorted" in order of arrival
	order_sec   []C.Window // Second screen: go through with H/L keys, "sorted" in order of arrival
	i_first     int        // index (first screen) of the current window in order_first (used for H/L keys)
	i_sec       int        // index (second screen) of the current window in order_first (used for H/L keys)
	stack_first []C.Window // stack of windows on the first screen (the last (top of the stack) will be brought forward if you close the current window)
	stack_sec   []C.Window // same for the second screen
	sec         bool       // Is the sec screen selected (or the first)
}

// Describes a keyboard shorcut : a key and a modifier, example: Super + T
struct KeyMod {
	key KeySym
	mod int
}

// TODO
type KeyCode = u8
type KeySym = int

fn grab_keys() {
	// Grab all the keyboard shortcuts used by the window manager, no one will be able to get these shortcuts (as far as I know)
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

// Called when asked to close current window
fn (wm WinMan) close_window() {
	if wm.windows.len > 0 {
		// We send an event to the X server (or the concerned app directly) that will ask to kill a specific window
		mut ke := C.XEvent{
			@type: C.ClientMessage
		}
		unsafe {
			// We take the last window of the selected stack as it is the one the user is currently using (so the user is asking to close this one)
			if wm.sec {
				if wm.stack_sec.len > 0 {
					ke.xclient.window = wm.stack_sec.last()
				} else {
					return
				}
			} else {
				if wm.stack_first.len > 0 {
					ke.xclient.window = wm.stack_first.last()
				} else {
					return
				}
			}
			// Tells X to kill this window (irrc X will ask the app to close itself, but some apps (example:steam) will just run in the background with no window)
			ke.xclient.message_type = C.XInternAtom(dpy, c'WM_PROTOCOLS', true)
			ke.xclient.format = 32
			ke.xclient.data.l[0] = C.XInternAtom(dpy, c'WM_DELETE_WINDOW', true)
			ke.xclient.data.l[1] = C.CurrentTime
		}
		// Send the request
		if wm.sec {
			C.XSendEvent(dpy, wm.stack_sec.last(), false, C.NoEventMask, &ke) // we send the event to the good window https://tronche.com/gui/x/xlib/event-handling/XSendEvent.html
		} else {
			C.XSendEvent(dpy, wm.stack_first.last(), false, C.NoEventMask, &ke)
		}
	}
}

// Raise and select/focus the current window
fn (mut wm WinMan) show_window() {
	if (!wm.sec && wm.stack_first.len > 0) || (wm.sec && wm.stack_sec.len > 0) { // if there is a window
		win := if wm.sec { // find which one is the current one
			wm.stack_sec.last()
		} else {
			wm.stack_first.last()
		}
		C.XRaiseWindow(dpy, win) // raise this window above all other windows
		C.XSetInputFocus(dpy, win, C.RevertToPointerRoot, C.CurrentTime) // The keyboard inputs will be caught by this app (the text editing cursor will work)
		if wm.sec {
			wm.i_sec = wm.order_sec.index(win) // remember that we are on this window (useful to circle through windows with H/L keys)
			C.XMoveResizeWindow(dpy, win, sec_x, sec_y, sec_w, sec_h) // resize the window to the full screen (expected) size and the right position (top left corner of the screen)
		} else {
			wm.i_first = wm.order_first.index(win)
			C.XMoveResizeWindow(dpy, win, 0, 0, width, height)
		}
	}
}

// avoid crashes as X will redirect errors here instead of shutting down
fn error_handler(display &C.Display, event &C.XErrorEvent) int {
	error_message := []u8{len: 256}
	C.XGetErrorText(display, event.error_code, error_message.data, error_message.len)
	eprintln(unsafe { cstring_to_vstring(error_message.data) })
	return 0
}

// Checks if user asks to go to the window at the index nb_key (in the windows array) and if yes show it
// Useful to move windows from one screen to another
fn (mut wm WinMan) check_goto_window(nb_key int, key C.XKeyEvent) {
	if key.keycode == C.XKeysymToKeycode(dpy, nb_key) && key.state ^ mod_super == 0 { // if Super + nb_key
		win := wm.windows[nb_key - 0x31] or { return } // https://www.cl.cam.ac.uk/~mgk25/ucs/keysymdef.h get the good window
		if wm.sec {
			i := wm.order_sec.index(win)
			if i != -1 { // it is on the sec screen
				// Move it on the top of the stack
				s_i := wm.stack_sec.index(win)
				wm.stack_sec.delete(s_i)
				wm.stack_sec << win
				wm.i_sec = i // we are on the window i in the order_sec array
			} else { // it's on the first screen
				// transfer the window to the first screen
				o_i := wm.order_first.index(win)
				wm.order_first.delete(o_i)
				wm.order_sec << win
				wm.i_sec = wm.order_sec.len - 1
				// move it on the top of the stack
				s_i := wm.stack_first.index(win)
				wm.stack_first.delete(s_i)
				wm.stack_sec << win
			}
		} else {
			i := wm.order_first.index(win)
			if i != -1 { // it is on the first screen
				// Move it on the top of the stack
				s_i := wm.stack_first.index(win)
				wm.stack_first.delete(s_i)
				wm.stack_first << win
				wm.i_sec = i
			} else { // it is on the sec screen
				// transfer the window to the first screen
				o_i := wm.order_sec.index(win)
				wm.order_sec.delete(o_i)
				wm.order_first << win
				wm.i_first = wm.order_first.len
				// move it on the top of the stack
				s_i := wm.stack_sec.index(win)
				wm.stack_sec.delete(s_i)
				wm.stack_first << win
			}
		}
		wm.show_window()
	}
}

fn main() {
	mut wm := WinMan{}

	println("width ${width}  height ${height} sec_x ${sec_x} sec_y ${sec_y} sec_w ${sec_w} sec_h ${sec_h}")

	// Set the error handler
	C.XSetErrorHandler(error_handler)

	// say to X which event we want to get notified about
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
	println("width ${width}  height ${height} sec_x ${sec_x} sec_y ${sec_y} sec_w ${sec_w} sec_h ${sec_h}")
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
					wm.sec = !wm.sec // change of screen
					if wm.sec {
						if wm.order_sec.len > 0 {
							wm.show_window()
						}
					} else {
						if wm.order_first.len > 0 {
							wm.show_window()
						}
					}
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_R) && key.state == mod_super { // refocus
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
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_L) && key.state == mod_super { // cycle forward
					if wm.sec {
						if wm.order_sec.len > 0 {
							wm.i_sec += 1
							if wm.i_sec >= wm.order_sec.len {
								wm.i_sec = 0 // cycle
							}
							win := wm.order_sec[wm.i_sec]
							// put it on top of the stack
							s_i := wm.stack_sec.index(win)
							wm.stack_sec.delete(s_i)
							wm.stack_sec << win
						} else {
							continue main_l // if there is no window
						}
					} else {
						if wm.order_first.len > 0 {
							wm.i_first += 1
							if wm.i_first >= wm.order_first.len {
								wm.i_first = 0 // cycle
							}
							win := wm.order_first[wm.i_first]
							// put it on top of the stack
							s_i := wm.stack_first.index(win)
							wm.stack_first.delete(s_i)
							wm.stack_first << win
						} else {
							continue main_l // if there is no window
						}
					}
					wm.show_window()
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_H) && key.state == mod_super { // cycle backward
					if wm.sec {
						if wm.order_sec.len > 0 {
							wm.i_sec -= 1
							if wm.i_sec < 0 {
								wm.i_sec = wm.order_sec.len - 1 // cycle
							}
							win := wm.order_sec[wm.i_sec]
							// put it on top of the stack
							s_i := wm.stack_sec.index(win)
							wm.stack_sec.delete(s_i)
							wm.stack_sec << win
						} else {
							continue main_l
						}
					} else {
						if wm.order_first.len > 0 {
							wm.i_first -= 1
							if wm.i_first < 0 {
								wm.i_first = wm.order_first.len - 1 // cycle
							}
							win := wm.order_first[wm.i_first]
							// put it on top of the stack
							s_i := wm.stack_first.index(win)
							wm.stack_first.delete(s_i)
							wm.stack_first << win
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
			C.MapNotify { // when the window is created
				if unsafe { !wm.ev.xmap.override_redirect } { // if the window does not want to be managed by the WM
					// get the window and add it to the arrays
					wm.windows << unsafe { wm.ev.xmap.window }
					if wm.sec {
						wm.stack_sec << wm.windows.last()
						wm.order_sec << wm.windows.last()
						wm.i_sec = wm.order_sec.len - 1
					} else {
						wm.stack_first << wm.windows.last()
						wm.order_first << wm.windows.last()
						wm.i_first = wm.order_first.len - 1
					}
					wm.show_window()
				}
			}
			C.UnmapNotify { // when the window is destroyed
				// Remove the window
				win := unsafe { wm.ev.xunmap.window }
				unmapped_i := wm.windows.index(win)
				if unmapped_i != -1 {
					wm.windows.delete(unmapped_i)
					if win in wm.order_sec {
						o_i := wm.order_sec.index(win)
						wm.order_sec.delete(o_i)
						s_i := wm.stack_sec.index(win)
						wm.stack_sec.delete(s_i)
					} else {
						o_i := wm.order_first.index(win)
						wm.order_first.delete(o_i)
						s_i := wm.stack_first.index(win)
						wm.stack_first.delete(s_i)
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
