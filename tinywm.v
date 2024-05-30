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

	C.XGrabKey(dpy, C.XKeysymToKeycode(dpy, C.XStringToKeysym(c"Return")), C.Mod1Mask, C.XDefaultRootWindow(dpy), true, C.GrabModeAsync, C.GrabModeAsync)
	C.XGrabButton(dpy, 1, C.Mod1Mask, C.XDefaultRootWindow(dpy), true, C.ButtonPressMask|C.ButtonReleaseMask|C.PointerMotionMask, C.GrabModeAsync, C.GrabModeAsync, C.None, C.None)
	C.XGrabButton(dpy, 3, C.Mod1Mask, C.XDefaultRootWindow(dpy), true, C.ButtonPressMask|C.ButtonReleaseMask|C.PointerMotionMask, C.GrabModeAsync, C.GrabModeAsync, C.None, C.None)
	
	for {
		C.XNextEvent(dpy, &ev)
		match unsafe{ ev.@type } {
			C.ButtonPress {
				win_nb = (win_nb + if unsafe{ ev.xbutton.button } == 1 { -1 } else { 1 }) % windows.len
				C.XRaiseWindow(dpy, windows[win_nb])
			}
			C.KeyPress {
				spawn os.execute("alacritty")
			}
			C.CreateNotify {
				windows << unsafe{ ev.xcreatewindow.window }
				C.XMoveResizeWindow(dpy, windows.last(), 0, 0, width, height)
			}
			else {}
		}
	}
} 
