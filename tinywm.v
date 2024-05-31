import os

// Get them automatically for the current window
const width = 1366
const height = 768

fn max(a int, b int) int {
	if a > b {
		return a
	}
	return b
}

fn C.XOpenDisplay(&u8) &C.Display

fn main() {
	dpy := C.XOpenDisplay(unsafe{nil})
	mut ev := C.XEvent{}
	mut windows := []C.Window{}
	mut win_nb := -1
	root := C.XDefaultRootWindow(dpy)

	attr := C.XSetWindowAttributes{event_mask: i32(C.SubstructureNotifyMask|C.StructureNotifyMask|C.KeyPressMask|C.KeyReleaseMask|C.ButtonPressMask|C.ButtonReleaseMask)}
	C.XChangeWindowAttributes(dpy, C.XDefaultRootWindow(dpy), C.CWEventMask, &attr)
	//C.XGrabButton(dpy, 1, C.Mod4Mask, root, true, C.ButtonPressMask|C.ButtonReleaseMask|C.PointerMotionMask, C.GrabModeAsync, C.GrabModeAsync, C.None, C.None)
	//C.XGrabButton(dpy, 3, C.Mod4Mask, root, true, C.ButtonPressMask|C.ButtonReleaseMask|C.PointerMotionMask, C.GrabModeAsync, C.GrabModeAsync, C.None, C.None)


	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XStringToKeysym(c"Return")), C.Mod1Mask, C.XDefaultRootWindow(dpy), true, C.GrabModeAsync, C.GrabModeAsync)
	
	for {
		C.XNextEvent(dpy, &ev)
		match unsafe{ ev.@type } {
			C.ButtonPress {
				win_nb += 2 - unsafe{ ev.xbutton.button }
				if win_nb >= windows.len {
					win_nb = 0
				} else if win_nb < 0 {
					win_nb = windows.len - 1
				}
				C.XRaiseWindow(dpy, windows[win_nb])
				C.XSetInputFocus(dpy, windows[win_nb], C.RevertToPointerRoot, C.CurrentTime)
			}
			C.KeyPress {
				key := ev.xkey
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_Return) && key.state ^ C.Mod4Mask == 0 {
					spawn os.execute("alacritty")
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_BackSpace) && key.state ^ C.Mod4Mask == 0 {
					eprintln("TODO close window")
				}
				if key.keycode == C.XKeysymToKeycode(dpy, C.XK_K) && key.state ^ C.Mod4Mask == 0 {
					break
				}
			}
			C.CreateNotify {
				eprintln("Create Notify")
			}
			C.MapNotify {
				eprintln("Map Notify")
				windows << unsafe{ ev.xmap.window }
				C.XMoveResizeWindow(dpy, windows.last(), 0, 0, width, height)
				C.XSetInputFocus(dpy, windows.last(), C.RevertToPointerRoot, C.CurrentTime)
			}
			else {eprintln("ev type ${ev.@type}")}
		}
	}
}
