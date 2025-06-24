//go:build !windows
// +build !windows

package terminal

import (
	"io"
	"os"
	"os/exec"
	"path/filepath"

	"fyne.io/fyne/v2"
	"github.com/creack/pty"
)

func (t *Terminal) updatePTYSize() {
	if t.pty == nil { // SSH or other direct connection?
		return
	}
	scale := float32(1.0)
	c := fyne.CurrentApp().Driver().CanvasForObject(t)
	if c != nil {
		scale = c.Scale()
	}

	// Safely convert uint to uint16 with bounds checking
	rows := t.config.Rows
	if rows > 65535 {
		rows = 65535
	}
	cols := t.config.Columns
	if cols > 65535 {
		cols = 65535
	}

	width := t.Size().Width * scale
	if width > 65535 {
		width = 65535
	}
	height := t.Size().Height * scale
	if height > 65535 {
		height = 65535
	}

	_ = pty.Setsize(t.pty.(*os.File), &pty.Winsize{
		Rows: uint16(rows), Cols: uint16(cols),
		X: uint16(width), Y: uint16(height)})
}

func (t *Terminal) startPTY() (io.WriteCloser, io.Reader, io.Closer, error) {
	shell := os.Getenv("SHELL")
	if shell == "" {
		shell = "bash"
	}

	// Validate shell path to prevent command injection
	allowedShells := []string{"bash", "sh", "zsh", "fish", "csh", "tcsh", "ksh"}
	shellName := filepath.Base(shell)
	isAllowed := false
	for _, allowed := range allowedShells {
		if shellName == allowed {
			isAllowed = true
			break
		}
	}
	if !isAllowed {
		shell = "bash" // fallback to safe default
	}

	_ = os.Chdir(t.startingDir())
	env := os.Environ()
	env = append(env, "TERM=xterm-256color")
	c := exec.Command(shell)
	c.Env = env

	t.cmdLock.Lock()
	t.cmd = c
	t.cmdLock.Unlock()

	// Start the command with a pty.
	f, err := pty.Start(c)
	return f, f, f, err
}
