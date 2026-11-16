# NEO Desktop — Native Qt/QML Preview (Iteration 0.2)

**Status:** Source updated. The 0.1 preview was compiled and launched successfully on an Ubuntu 24.04 host (user-provided screenshot, 2026-11-16). **The 0.2 changes have not yet been compiled or tested on that host.**

This is a **normal Qt desktop application window**. It will not replace GNOME, change your login manager, install NEO-OS, or modify the Linux From Scratch base.

## Setup (Ubuntu 24.04)
```bash
sudo apt update
sudo apt install -y cmake ninja-build build-essential git \
  qt6-base-dev qt6-declarative-dev libxkbcommon-dev \
  qml6-module-qtqml-workerscript qml6-module-qtqml-models \
  qml6-module-qtquick qml6-module-qtquick-controls \
  qml6-module-qtquick-layouts qml6-module-qtquick-window \
  libglib2.0-bin xterm
```

## Update and run
From a clean local checkout:
```bash
cd ~/neo-os
git status
git pull --ff-only origin master
cmake -S desktop/shell -B out/neo-desktop -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build out/neo-desktop
./out/neo-desktop/neo-desktop
```

If `git pull --ff-only` refuses because of local modifications, preserve those modifications rather than resetting or overwriting. If the GUI fails, run `./out/neo-desktop/neo-desktop 2>&1 | tee neo-desktop-runtime.log` and share the terminal output.

## Keyboard controls (Issue #3)
- **Ctrl+Space** toggles the orbital dock within the preview window.
- **Ctrl+K** opens/closes the installed-app panel and focuses its search field.
- **Escape** dismisses the application panel or collapses the dock.
- The dock center is a focusable button. When keyboard-focused, its border changes to gold; **Enter/Space** should activate it.

**Important:** These controls are a new *unverified* source change and need Ubuntu runtime testing before acceptance.

## New in this iteration
- Real system application icons through Qt `QIcon` and `image://appicons` (fall back to initials where no icon exists).
- Cleaner default desktop composition with subtle celestial rings and less visual clutter.
- Expandable circular dock at bottom-right, with improved hover states and app labels.
- Searchable installed-app listing with **Open** and **Pin** actions.
- `QSettings` backed pinned application persistence from the existing C++ backend.
- Matrix CLI action launches an installed terminal such as xterm or kitty.
- Accessible names on buttons, with an initial reduced-motion toggle.

## Manual test plan
1. The window starts after the Qt runtime modules are installed.
2. Click center of orbit; icons reposition when expanded. Click again to collapse.
3. Click the Chromium/Firefox icon (or another known trusted app). The installed application should launch.
4. Open **Apps**, search for an installed app, click **Pin**, close and restart preview. Confirm pinned app persists.
5. Right-click a pinned app icon to unpin; verify state persists after restart.
6. Open Matrix CLI. Run `pwd` or `echo NEO-OS` inside the terminal.
7. Disable motion effects and check that interface remains usable.
8. Check window layout at smaller widths and note any clipping or QML errors.

## Current limitations and risks
- Real running-window tracking, embedded PTY terminal, compositor/session integration, AI tools and OS-level functionality are **not** implemented.
- Some desktop entries use unusual icon formats and may show a fallback letter. Qt's icon theme determines icon availability.
- The Gio launcher executes installed `.desktop` entries, which should be trusted as system applications. It is not a sandbox.
- Full keyboard navigation, focus behavior, screen-reader tests and launch status tracking remain outstanding.
- CI and the 0.2 source build result are not yet verified. Do not treat source-level inspection as runtime testing.

## Static source tests
```bash
python3 -m unittest discover -s tests -p 'test_desktop_source.py' -v
```

Record the observed results, warnings and screenshots in `docs/PROJECT_STATE.md`.

## Matrix CLI embedded PTY proof of concept — Issue #5 (unverified)

The Matrix CLI button now proposes opening an **embedded PTY-backed shell panel** instead of only launching a separate terminal. The external terminal remains available as a fallback from inside the panel.

### Dependencies
The Linux prototype uses `forkpty()` from libutil and the system's `/bin/bash`. The existing Qt 6/CMake prerequisites still apply. Linux only; no change to host desktop/session/bootloader.

### Manual tests on Ubuntu (run before merging)
1. Build this issue branch using the regular CMake/Ninja commands. Open the desktop preview.
2. Click **Matrix CLI**. A green-on-black **Matrix CLI • Linux PTY preview** panel should appear.
3. Type `pwd` and press Enter; your current working directory should appear.
4. Type `echo NEO-OS`; output should contain `NEO-OS`.
5. Run `sleep 20`, then click **Ctrl+C**; the command should be interrupted.
6. Click **Stop**, observe the shell stop, then **Start** and run `echo restart`.
7. Close and reopen the panel; verify the desktop continues responding and the session behavior is clear.
8. Confirm orbital dock launching, Ctrl+Space, Ctrl+K, Escape and pinned apps still work. Copy build errors or screenshot to the issue/PR.

**Known limitations:** This is *not* a complete VT/ANSI terminal emulator. It uses a line-input box (no per-keystroke shell editing), a simple text output view, fixed 80x24 PTY geometry, partial ANSI stripping and approximate UTF-8 chunk decoding. Full-screen editors, interactive TUIs, clipboard fidelity, resize signaling and process-group behavior need stronger testing and a mature terminal engine. Closing the panel hides it; **Stop** ends the shell. It is a real user shell and is **not sandboxed**. Never enter destructive commands merely to test the interface.

### Learning concepts
- `forkpty()` creates a PTY master/slave pair and a child process connected to the slave.
- `QSocketNotifier` integrates the PTY file descriptor into Qt's event loop without blocking the UI.
- QML property bindings expose shell output and running state to the frontend.
- `Ctrl+C` is written as ASCII ETX to the PTY; the line discipline can deliver SIGINT to the foreground process group.
