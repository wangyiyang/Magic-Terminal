package terminal

import (
	"runtime"
	"unicode/utf8"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/driver/desktop"
)

// TypedRune is called when the user types a visible character
func (t *Terminal) TypedRune(r rune) {
	b := make([]byte, utf8.UTFMax)
	size := utf8.EncodeRune(b, r)
	_, _ = t.in.Write(b[:size])
}

// keySequence represents a key sequence to be written to the terminal
type keySequence []byte

// keyHandlerMap maps key names to their corresponding byte sequences
var keyHandlerMap = map[fyne.KeyName]keySequence{
	fyne.KeyReturn:    {'\r'},
	fyne.KeyTab:       {'\t'},
	fyne.KeyF1:        {asciiEscape, 'O', 'P'},
	fyne.KeyF2:        {asciiEscape, 'O', 'Q'},
	fyne.KeyF3:        {asciiEscape, 'O', 'R'},
	fyne.KeyF4:        {asciiEscape, 'O', 'S'},
	fyne.KeyF5:        {asciiEscape, '[', '1', '5', '~'},
	fyne.KeyF6:        {asciiEscape, '[', '1', '7', '~'},
	fyne.KeyF7:        {asciiEscape, '[', '1', '8', '~'},
	fyne.KeyF8:        {asciiEscape, '[', '1', '9', '~'},
	fyne.KeyF9:        {asciiEscape, '[', '2', '0', '~'},
	fyne.KeyF10:       {asciiEscape, '[', '2', '1', '~'},
	fyne.KeyF11:       {asciiEscape, '[', '2', '3', '~'},
	fyne.KeyF12:       {asciiEscape, '[', '2', '4', '~'},
	fyne.KeyEscape:    {asciiEscape},
	fyne.KeyBackspace: {asciiBackspace},
	fyne.KeyDelete:    {asciiEscape, '[', '3', '~'},
	fyne.KeyPageUp:    {asciiEscape, '[', '5', '~'},
	fyne.KeyPageDown:  {asciiEscape, '[', '6', '~'},
	fyne.KeyHome:      {asciiEscape, 'O', 'H'},
	fyne.KeyInsert:    {asciiEscape, '[', '2', '~'},
	fyne.KeyEnd:       {asciiEscape, 'O', 'F'},
}

// shiftKeyHandlerMap maps key names to their corresponding byte sequences when Shift is pressed
var shiftKeyHandlerMap = map[fyne.KeyName]keySequence{
	fyne.KeyF1:       {asciiEscape, '[', '2', '5', '~'},
	fyne.KeyF2:       {asciiEscape, '[', '2', '6', '~'},
	fyne.KeyF3:       {asciiEscape, 'O', 'R', ';', '2', '~'},
	fyne.KeyF4:       {asciiEscape, '[', '1', ';', '2', 'S'},
	fyne.KeyF5:       {asciiEscape, '[', '1', '5', ';', '2', '~'},
	fyne.KeyF6:       {asciiEscape, '[', '1', '7', ';', '2', '~'},
	fyne.KeyF7:       {asciiEscape, '[', '1', '8', ';', '2', '~'},
	fyne.KeyF8:       {asciiEscape, '[', '1', '9', ';', '2', '~'},
	fyne.KeyF9:       {asciiEscape, '[', '2', '0', ';', '2', '~'},
	fyne.KeyF10:      {asciiEscape, '[', '2', '1', ';', '2', '~'},
	fyne.KeyF11:      {asciiEscape, '[', '2', '3', ';', '2', '~'},
	fyne.KeyF12:      {asciiEscape, '[', '2', '4', ';', '2', '~'},
	fyne.KeyPageUp:   {asciiEscape, '[', '5', ';', '2', '~'},
	fyne.KeyPageDown: {asciiEscape, '[', '6', ';', '2', '~'},
	fyne.KeyHome:     {asciiEscape, '[', '1', ';', '2', 'H'},
	fyne.KeyInsert:   {asciiEscape, '[', '2', ';', '2', '~'},
	fyne.KeyDelete:   {asciiEscape, '[', '3', ';', '2', '~'},
	fyne.KeyEnd:      {asciiEscape, '[', '1', ';', '2', 'F'},
}

// shiftCursorKeyMap maps cursor keys to their Shift+key sequences
var shiftCursorKeyMap = map[fyne.KeyName]keySequence{
	fyne.KeyUp:    {asciiEscape, '[', 'A', ';', '2'},
	fyne.KeyDown:  {asciiEscape, '[', 'B', ';', '2'},
	fyne.KeyLeft:  {asciiEscape, '[', 'D', ';', '2'},
	fyne.KeyRight: {asciiEscape, '[', 'C', ';', '2'},
}

func (t *Terminal) TypedKey(e *fyne.KeyEvent) {
	if t.keyboardState.shiftPressed {
		t.keyTypedWithShift(e)
		return
	}

	// Handle Enter key specially based on newLineMode
	if e.Name == fyne.KeyEnter {
		t.handleEnterKey()
		return
	}

	// Handle cursor keys
	if t.isCursorKey(e.Name) {
		t.typeCursorKey(e.Name)
		return
	}

	// Handle other keys using the map
	t.handleMappedKey(e.Name)
}

// handleEnterKey handles the Enter key based on newLineMode
func (t *Terminal) handleEnterKey() {
	if t.newLineMode {
		_, _ = t.in.Write([]byte{'\r'})
		return
	}
	_, _ = t.in.Write([]byte{'\n'})
}

// isCursorKey checks if the given key is a cursor key
func (t *Terminal) isCursorKey(key fyne.KeyName) bool {
	return key == fyne.KeyUp || key == fyne.KeyDown || key == fyne.KeyLeft || key == fyne.KeyRight
}

// handleMappedKey handles keys that are in the keyHandlerMap
func (t *Terminal) handleMappedKey(key fyne.KeyName) {
	if sequence, exists := keyHandlerMap[key]; exists {
		_, _ = t.in.Write(sequence)
	}
}

func (t *Terminal) keyTypedWithShift(e *fyne.KeyEvent) {
	// Handle cursor keys with Shift
	if t.isCursorKey(e.Name) {
		t.handleShiftCursorKey(e.Name)
		return
	}

	// Handle other keys using the map
	t.handleShiftMappedKey(e.Name)
}

// handleShiftCursorKey handles cursor keys when Shift is pressed
func (t *Terminal) handleShiftCursorKey(key fyne.KeyName) {
	if sequence, exists := shiftCursorKeyMap[key]; exists {
		_, _ = t.in.Write(sequence)
	}
}

// handleShiftMappedKey handles keys that are in the shiftKeyHandlerMap
func (t *Terminal) handleShiftMappedKey(key fyne.KeyName) {
	if sequence, exists := shiftKeyHandlerMap[key]; exists {
		_, _ = t.in.Write(sequence)
	}
}

func (t *Terminal) trackKeyboardState(down bool, e *fyne.KeyEvent) {
	switch e.Name {
	case desktop.KeyShiftLeft:
		t.keyboardState.shiftPressed = down
	case desktop.KeyAltLeft:
		t.keyboardState.altPressed = down
	case desktop.KeyControlLeft:
		t.keyboardState.ctrlPressed = down
	case desktop.KeyShiftRight:
		t.keyboardState.shiftPressed = down
	case desktop.KeyAltRight:
		t.keyboardState.altPressed = down
	case desktop.KeyControlRight:
		t.keyboardState.ctrlPressed = down
	}
}

// KeyDown is called when we get a down key event
func (t *Terminal) KeyDown(e *fyne.KeyEvent) {
	t.trackKeyboardState(true, e)
}

// KeyUp is called when we get an up key event
func (t *Terminal) KeyUp(e *fyne.KeyEvent) {
	t.trackKeyboardState(false, e)
}

// FocusGained notifies the terminal that it has focus
func (t *Terminal) FocusGained() {
	t.focused = true
	t.Refresh()
}

// TypedShortcut handles key combinations, we pass them on to the tty.
func (t *Terminal) TypedShortcut(s fyne.Shortcut) {
	if ds, ok := s.(*desktop.CustomShortcut); ok {
		t.ShortcutHandler.TypedShortcut(s) // it's not clear how we can check if this consumed the event

		// handle CTRL+A to CTRL+_ and everything in-between
		if ds.Modifier == fyne.KeyModifierControl && len(ds.KeyName) > 0 {
			char := ds.KeyName[0]
			off := char - 'A' + 1
			switch {
			case ds.Key() == fyne.KeySpace:
				fallthrough
			case ds.Key() == "@":
				off = 0
				fallthrough
			case char >= 'A' && char <= '_':
				_, _ = t.in.Write([]byte{off})
			}
		}
		return
	}

	if runtime.GOOS == "darwin" {
		// do the default thing for macOS as they separete ctrl/cmd
		t.ShortcutHandler.TypedShortcut(s)
	} else {
		// we need to override the default ctrl-X/C/V/A for non-mac and do it ourselves

		if _, ok := s.(*fyne.ShortcutCut); ok {
			_, _ = t.in.Write([]byte{0x18})

		} else if _, ok := s.(*fyne.ShortcutCopy); ok {
			_, _ = t.in.Write([]byte{0x3})

		} else if _, ok := s.(*fyne.ShortcutPaste); ok {
			_, _ = t.in.Write([]byte{0x16})

		} else if _, ok := s.(*fyne.ShortcutUndo); ok {
			_, _ = t.in.Write([]byte{0x1a})

		} else if _, ok := s.(*fyne.ShortcutSelectAll); ok {
			_, _ = t.in.Write([]byte{0x1})

		}
	}
}

// FocusLost tells the terminal it no longer has focus
func (t *Terminal) FocusLost() {
	t.focused = false
	t.Refresh()
}

// Focused is used to determine if this terminal currently has focus
func (t *Terminal) Focused() bool {
	return t.focused
}

func (t *Terminal) typeCursorKey(key fyne.KeyName) {
	cursorPrefix := byte('[')
	if t.bufferMode {
		cursorPrefix = 'O'
	}

	switch key {
	case fyne.KeyUp:
		_, _ = t.in.Write([]byte{asciiEscape, cursorPrefix, 'A'})
	case fyne.KeyDown:
		_, _ = t.in.Write([]byte{asciiEscape, cursorPrefix, 'B'})
	case fyne.KeyLeft:
		_, _ = t.in.Write([]byte{asciiEscape, cursorPrefix, 'D'})
	case fyne.KeyRight:
		_, _ = t.in.Write([]byte{asciiEscape, cursorPrefix, 'C'})
	}
}

type discardWriter struct{}

func (d discardWriter) Write(p []byte) (n int, err error) {
	return len(p), nil
}

func (d discardWriter) Close() error {
	return nil
}
