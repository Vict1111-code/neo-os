# NEO-OS Desktop Design System — Draft v0.1
**Status:** Proposed based on user-provided visual references; no UI implementation yet.

## Product visual direction
Classical-futuristic: architectural/celestial scenery, premium navy/charcoal surfaces, restrained cyan/violet/gold accents, translucent glass used selectively. A useful desktop takes priority over a constantly busy sci-fi dashboard.

## Initial tokens
| Token | Initial suggested value |
|---|---|
| Surface base | `#091525` |
| Window surface | `#142338` |
| Cyan accent | `#38BDF8` |
| Violet accent | `#A78BFA` |
| Gold accent | `#EABF72` |
| Main text | `#F1F5F9` |
| Secondary text | `#A8BAD0` |
| Spacing unit | 4 px increments |
| Corner radius | 8–16 px for panels; full circle for orbital hub |

These are candidates to validate against contrast ratios and user preference, not finalized brand colors.

## Layout
- Top bar: workspace selection, search/AI trigger, connectivity, sound, battery and clock.
- Desktop canvas: clear central workspace, wallpaper; file shortcuts in a restrained grid.
- Optional side rail for development sections; collapsible.
- Bottom-right compact orbital launcher expands on hover/click; users can relocate or switch to linear mode.
- Widgets appear on demand; avoid permanently covering all wallpaper/desktop.
- Floating windows follow compositor conventions and keyboard accessibility.

## Orbital dock states
Collapsed, expanded, keyboard focus, running, loading, attention, disabled, reduced-motion, compact and linear fallback. Pinned items persist and activate real applications using trusted .desktop entries. Animation must not make icons hard to click; test selection hitboxes and latency.

## Matrix CLI
Functional PTY-backed terminal with a green-on-black theme, optional dashboard panes and documented switch mechanism. A Wayland fullscreen terminal is not the same as an independent Linux virtual console. Expose a genuine recovery console.

## Accessibility and performance
Keyboard navigation, visible focus rings, high contrast mode, screen-reader semantics, configurable motion and 3D effect quality, multi-display scaling. On 8 GB hardware allow effects and local AI to be disabled. Never make text nonselectable by placing it solely in a rendered image.

## Prototype acceptance
Launcher launches a real installed application; dock pins survive restart; GUI and Matrix terminal coexist; hotkeys work; minimum contrast and reduced-motion variants tested at multiple resolutions.
