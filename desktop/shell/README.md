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
