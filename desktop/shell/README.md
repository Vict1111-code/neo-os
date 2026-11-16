# NEO Desktop — Qt/QML Proof of Concept
**Phase:** 1 / Track A. **Status:** Source committed; compilation and runtime behavior not yet verified.

This is a normal desktop *application*, not a replacement for your host desktop compositor or an installed operating system. It draws a classical-neon desktop concept, an expandable orbital launcher, a visible Matrix CLI action, and an installed-app pinning panel.

## Requirements
- Linux with a graphical session (X11 or Wayland)
- Qt 6.4+ with Qt Quick, Qt QML, Qt Quick Controls
- CMake 3.21+, C++17 compiler, Ninja or Make
- GIO command-line launcher (`gio`, commonly from GLib)
- At least one terminal for Matrix CLI (`xterm`, `kitty`, `konsole`, `gnome-terminal`, or `xfce4-terminal`)

Example setup on a supported Ubuntu/Debian release; package names may vary:
```bash
sudo apt update
sudo apt install -y cmake ninja-build g++ qt6-base-dev qt6-declarative-dev \
  qml6-module-qtquick qml6-module-qtquick-controls \
  qml6-module-qtquick-layouts qml6-module-qtquick-window \
  libglib2.0-bin xterm
```

## Build and run
From the repository root:
```bash
cmake -S desktop/shell -B out/neo-desktop -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build out/neo-desktop
./out/neo-desktop/neo-desktop
```

This should open an application window, not replace your existing desktop session.

## Interactions
- Click the central ◈ button to expand/collapse the orbital dock.
- Hover over dock icons to expand; left-click one to launch via `gio launch <installed.desktop>`.
- Right-click a dock icon to unpin.
- Open **Apps** in the left rail and pin a discovered installed application.
- Select **Matrix CLI** to launch the first detected terminal. A themed xterm/kitty receives dark/green colors; some other terminals keep their default theme.
- Toggle **Motion effects** in the control panel. Pins persist through `QSettings` under the current user.

## Important limitations
- This is a prototype inside one window. It does **not** own global window management, running-app tracking, top-level wallpaper, system notifications, GPU dashboard, AI actions, package installation, or login/session switching.
- The prototype does not yet draw desktop application icons from the freedesktop icon theme; it displays app initials.
- Applications are discovered from installed `.desktop` entries. Those files are executable system instructions: only pin trusted installed applications. Listing filters are a convenience, not a sandbox or complete trust validation.
- If `gio` or supported terminals are missing, actions return an explanatory message.
- No source compilation or functional GUI test was possible in the current assistant environment because Qt 6 development libraries were unavailable. Tests must be executed on a properly equipped Linux host or CI.

## Manual acceptance checklist
- [ ] Builds on target Linux with Qt 6.
- [ ] Opens preview without replacing/compressing current desktop session.
- [ ] At least one .desktop launcher opens a real app.
- [ ] Pin and unpin survives relaunch.
- [ ] Keyboard controls and accessibility are evaluated (partially implemented).
- [ ] Matrix CLI opens terminal and executes normal shell commands.
- [ ] Motion toggle reduces animation; behavior checked.
- [ ] Windows and screen scaling tested.
Record commands/screenshots/errors in `docs/PROJECT_STATE.md`.
