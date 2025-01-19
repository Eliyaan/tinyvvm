fn C.XSetInputFocus(&C.Display, C.Window, Revert, C.Time)

struct C.XSizeHints {}

struct C.GC {}

@[typedef]
union C.XEvent {
mut:
	@type             int
	xkey              C.XKeyEvent
	xclient           C.XClientMessageEvent
	xbutton           C.XButtonEvent
	xmaprequest       C.XMapRequestEvent
	xconfigurerequest C.XConfigureRequestEvent
	xunmap            C.XUnmapEvent
	xmap              C.XMapEvent
	xdestroywindow    C.XDestroyWindowEvent
	xcreatewindow     C.XCreateWindowEvent
}

@[typedef]
struct C.XMapEvent {
	@type             int
	serial            u32
	send_event        bool
	display           &C.Display = unsafe { nil }
	event             C.Window
	window            C.Window
	override_redirect bool
}

@[typedef]
struct C.XCreateWindowEvent {
	@type             int
	serial            u32
	send_event        bool
	display           &C.Display = unsafe { nil }
	parent            C.Window
	window            C.Window
	x                 int
	y                 int
	width             int
	height            int
	border_width      int
	override_redirect bool
}

@[typedef]
struct C.XDestroyWindowEvent {
	@type      int  // DestroyNotify
	serial     int  // # of last request processed by server
	send_event bool // true if this came from a SendEvent request
	display    &C.Display = unsafe { nil } // Display the event was read from
	event      C.Window
	window     C.Window
}

@[typedef]
struct C.XMapRequestEvent {
	@type      int  // MapRequest
	serial     u32  // # of last request processed by server
	send_event bool // true if this came from a SendEvent request
	display    &C.Display = unsafe { nil } // Display the event was read from
	parent     C.Window
	window     C.Window
}

@[typedef]
struct C.XWindowChanges {
	x            int
	y            int
	width        int
	height       int
	border_width int
	sibling      C.Window
	stack_mode   int
}

@[typedef]
struct C.XConfigureRequestEvent {
	@type        int  // ConfigureRequest
	serial       i64  // # of last request processed by server
	send_event   bool // true if this came from a SendEvent request
	display      &C.Display = unsafe { nil } // Display the event was read from
	parent       C.Window
	window       C.Window
	x            int
	y            int
	width        int
	height       int
	border_width int
	above        C.Window
	detail       int // Above, Below, TopIf, BottomIf, Opposite
	value_mask   u64
}

@[typedef]
struct C.XUnmapEvent {
	@type          int  // UnmapNotify
	serial         u32  // # of last request processed by server
	send_event     bool // true if this came from a SendEvent request
	display        &C.Display = unsafe { nil } // Display the event was read from
	event          C.Window
	window         C.Window
	from_configure bool
}

union XClientMessageEventData {
mut:
	b [20]u8
	s [10]i16
	l [5]i64
}

type C.Atom = int

type C.Time = int

struct C.Time {}

fn C.XInternAtom(&C.Display, &u8, bool) C.Atom

@[typedef]
struct C.XClientMessageEvent {
mut:
	@type        int  // ClientMessage
	serial       int  // # of last request processed by server
	send_event   bool // true if this came from a SendEvent request
	display      &C.Display = unsafe { nil } // Display the event was read from
	window       C.Window
	message_type C.Atom
	format       int
	data         XClientMessageEventData
}

@[typedef]
struct C.XKeyEvent {
	@type       int
	serial      u32
	send_event  bool
	display     &C.Display = unsafe { nil }
	window      C.Window
	root        C.Window
	subwindow   C.Window
	time        C.Time
	x           int
	y           int
	x_root      int
	y_root      int
	state       int
	keycode     int
	same_screen bool
}

@[typedef]
struct C.XButtonEvent {
	@type       int  // ButtonPress or ButtonRelease
	serial      u32  // # of last request processed by server
	send_event  bool // true if this came from a SendEvent request
	display     &C.Display = unsafe { nil } // Display the event was read from
	window      C.Window // ``event'' window it is reported relative to
	root        C.Window // root window that the event occurred on
	subwindow   C.Window // child window
	time        C.Time   // milliseconds
	x           int
	y           int // pointer x, y coordinates in event window
	x_root      int
	y_root      int  // coordinates relative to root
	state       int  // key or button mask
	button      int  // detail
	same_screen bool // same screen flag
}

fn C.XSetErrorHandler(fn (&C.Display, &C.XErrorEvent) int) int

fn C.XGetErrorText(&C.Display, int, &u8, int)

type C.XID = int

@[typedef]
struct C.XErrorEvent {
	@type        int
	display      &C.Display = unsafe { nil }
	serial       u64 // serial number of failed request
	error_code   u8  // error code of failed request
	request_code u8  // Major op-code of failed request
	minor_code   u8  // Minor op-code of failed request
	resourceid   C.XID
}
fn C.XScreenOfDisplay(&C.Display, int) &C.Screen

fn C.XWidthOfScreen(&C.Screen) int

fn C.XHeightOfScreen(&C.Screen) int

fn C.XStringToKeysym(&u8) KeySym

fn C.XNextEvent(&C.Display, &C.XEvent) int

fn C.XDefaultGC(&C.Display, int) C.GC

fn C.XSetForeground(&C.Display, C.GC, u32)

fn C.XFillRectangle(&C.Display, C.Window, C.GC, int, int, int, int)

fn C.XClearWindow(&C.Display, C.Window)

fn C.XSetStandardProperties(&C.Display, C.Window, &u8, &u8, C.Pixmap, &&u8, int, C.XSizeHints)

fn C.XSelectInput(&C.Display, C.Window, i32)

fn C.XSetInputFocus(&C.Display, C.Window, int, C.Time)

fn C.XCloseDisplay(&C.Display)

fn C.XDefaultRootWindow(&C.Display) C.Window

fn C.XDefaultScreenOfDisplay(&C.Display) &C.Screen

fn C.XDefaultScreen(&C.Display) int

fn C.XDisplayWidth(&C.Display, int) int

fn C.XDisplayHeight(&C.Display, int) int

fn C.XMoveWindow(&C.Display, C.Window, int, int)

fn C.XGrabKey(&C.Display, int, int, C.Window, bool, int, int) // the 2th int is a u int

fn C.XGrabButton(&C.Display, int, int, C.Window, bool, int, int, int, C.Window, C.Cursor)

fn C.XKeysymToKeycode(&C.Display, KeySym) KeyCode

fn C.XUnmapWindow(&C.Display, C.Window)

fn C.XMapWindow(&C.Display, C.Window)

fn C.XFetchName(&C.Display, C.Window, &&u8)

fn C.XSetWindowBorderWidth(&C.Display, C.Window, int)

fn C.XSetWindowBorder(&C.Display, C.Window, u64)

fn C.XGetClassHint(&C.Display, C.Window, &C.XClassHint) int

fn C.XConfigureWindow(&C.Display, C.Window, int, &C.XWindowChanges)

fn C.XRaiseWindow(&C.Display, C.Window)

fn C.XMoveResizeWindow(&C.Display, C.Window, int, int, int, int)

fn C.XCreateFontCursor(&C.Display, int) C.Cursor

fn C.XChangeWindowAttributes(&C.Display, C.Window, u32, &C.XSetWindowAttributes)

fn C.XSetClassHint(&C.Display, C.Window, &C.XClassHint)

fn C.XftFontOpenName(&C.Display, int, &u8) &C.XftFont

struct C.Visual {}

fn C.XDefaultVisual(&C.Display, int) &C.Visual

struct C.Colormap {}

fn C.XOpenDisplay(&u8) &C.Display

fn C.XDefaultColormap(&C.Display, int) C.Colormap

fn C.XftDrawCreate(&C.Display, C.Window, &C.Visual, C.Colormap) &C.XftDraw

fn C.XFlush(&C.Display)

fn C.XftDrawStringUtf8(&C.XftDraw, &C.XftColor, &C.XftFont, int, int, &C.XftChar8, int)

fn C.XSendEvent(&C.Display, C.Window, bool, int, &C.XEvent)

struct C.XftChar8 {}

@[typedef]
struct C.XRenderColor {
	red   u16
	green u16
	blue  u16
	alpha u16
}

fn C.XftColorAllocValue(&C.Display, &C.Visual, C.Colormap, &C.XRenderColor, &C.XftColor) bool

fn C.XCreateSimpleWindow(&C.Display, C.Window, int, int, int, int, int, u32, u32) C.Window

@[heap; typedef]
struct C.Display {}

type C.Window = u64

struct C.Screen {}

struct C.XftFont {}

@[typedef]
struct C.XftColor {}

struct C.XftDraw {}

type C.Cursor = int

fn C.XFree(&u8)

@[typedef]
struct C.XClassHint {
	res_name  &u8 = unsafe { nil }
	res_class &u8 = unsafe { nil }
}

@[typedef]
struct C.Pixmap {}

struct C.Colormap {}

@[typedef]
struct C.XWindowAttributes {
	x      int
	y      int
	width  int
	height int

	override_redirect bool
}

fn C.XGetWindowAttributes(&C.Display, C.Window, &C.XWindowAttributes) int

@[heap; typedef]
struct C.XSetWindowAttributes {
mut:
	background_pixmap     C.Pixmap   // background, None, or ParentRelative
	background_pixel      u32        // background pixel
	border_pixmap         C.Pixmap   // border of the window or CopyFromParent
	border_pixel          u32        // border pixel value
	bit_gravity           int        // one of bit gravity values
	win_gravity           int        // one of the window gravity values
	backing_store         int        // NotUseful, WhenMapped, Always
	backing_planes        u32        // planes to be preserved if possible
	backing_pixel         u32        // value to use in restoring planes
	save_under            bool       // should bits under be saved? (popups)
	event_mask            i32        // set of events that should be saved
	do_not_propagate_mask i32        // set of events that should not propagate
	override_redirect     bool       // boolean value for override_redirect
	colormap              C.Colormap // color map to be associated with window
	cursor                C.Cursor   // cursor to be displayed (or None)
}
