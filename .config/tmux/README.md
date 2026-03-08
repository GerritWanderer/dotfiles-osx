# tmux config

## Prefix Keys
- **`C-Space`** — primary prefix (instead of the default `C-b`)
- **`C-b`** — secondary prefix (kept as fallback)
- **`prefix q`** — reload config

---

## Copy Mode (Vi-style)
- **`v`** — start selection
- **`y`** — copy selection and exit copy mode

---

## Pane Controls
| Key | Action |
|-----|--------|
| `prefix h` | Split horizontally (new pane below) |
| `prefix v` | Split vertically (new pane right) |
| `prefix x` | Kill pane |
| `prefix z` | Toggle pane fullscreen (zoom) |
| `C-M-Arrow` | Navigate between panes (no prefix needed) |
| `C-M-S-Arrow` | Resize panes by 5 cells (no prefix needed) |

> Note: `h`/`v` mnemonics are swapped from their intuitive meaning — `h` gives a horizontal split line (pane below), `v` gives a vertical split line (pane right).

---

## Window Controls
| Key | Action |
|-----|--------|
| `prefix r` | Rename window |
| `prefix c` | New window (same path) |
| `prefix k` | Kill window |
| `M-1` … `M-9` | Jump to window by number |
| `M-Left/Right` | Previous/next window |
| `M-S-Left/Right` | Swap window left/right |

---

## Session Controls
| Key | Action |
|-----|--------|
| `prefix R` | Rename session |
| `prefix C` | New session |
| `prefix K` | Kill session |
| `prefix P/N` | Previous/next session |
| `M-Up/Down` | Previous/next session (no prefix) |

---

## General Settings
- **256-color + true color (RGB)** terminal support
- **Mouse enabled**
- **Windows/panes indexed from 1** (not 0), auto-renumbered on close
- **50,000 line scrollback**
- **`escape-time 0`** — no delay for Escape key (important for Neovim)
- **`focus-events on`** — passes focus events to apps (useful for Neovim autoread)
- **`set-clipboard` + `allow-passthrough`** — clipboard integration with terminal/OSC52
- **`detach-on-destroy off`** — when a session is killed, switches to another session instead of detaching
- **`aggressive-resize on`** — uses the smallest attached client's size only when multiple clients share a window

---

## Status Bar
- Positioned at the **top**
- **Left:** session name in a blue badge
- **Right:** shows `PREFIX` indicator when prefix is active, `ZOOM` when a pane is zoomed, and the hostname
- Windows auto-rename to the **current directory name** (`#{b:pane_current_path}`)
- Minimal blue/grey theme with transparent background
