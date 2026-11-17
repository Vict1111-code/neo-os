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

## Matrix PTY lifecycle hardening — Issue #5

- Stop now sends SIGHUP to the active foreground process group (when distinct from Bash's group) and the Bash process group, before using a bounded wait and force-kill fallback for the direct Bash child.
- This **does not** guarantee cleanup of detached, disowned or differently grouped background jobs. Full descendant supervision is future work; a PTY is not a sandbox.
- A live, headless CTest smoke test uses the real `forkpty()` backend, runs a fixed `echo NEO_PTY_INTEGRATION_OK`, verifies actual output rather than merely the echoed command, and tests stopping the shell.
- CI runs `ctest --test-dir out/neo-desktop --output-on-failure` after compilation.

### Local verification of the hardening branch
```bash
cd ~/neo-os
git fetch origin
git switch feat/5-matrix-pty-prototype
git pull --ff-only origin feat/5-matrix-pty-prototype
cmake -S desktop/shell -B out/neo-desktop -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build out/neo-desktop
ctest --test-dir out/neo-desktop --output-on-failure
./out/neo-desktop/neo-desktop
```
Use `git status` before switching if there may be uncommitted changes. Verify Ctrl+C, Stop/Start and a foreground `sleep` again; don't run destructive commands. Update test results on PR #6.

## Celestial visual refinement — Issue #9 (stacked on PR #6)

This branch implements a Qt/QML **reference-inspired** layout using a top workspace bar, glass sidebar and cards, generated celestial wallpaper fallback, center orbital launcher with actual pinned Linux apps, and an additional bottom pinned-app dock. Wallpaper URL and cyan/violet accent choice persist in QSettings. **The uploaded reference compositions are not embedded assets**; they include example interface elements, not clean wallpaper source images. To approach their scenery, select an actual background image from your own local collection.

### Build this stacked branch safely
```bash
cd ~/neo-os
git status
git fetch origin
git switch -c feat/9-celestial-desktop-refinement --track origin/feat/9-celestial-desktop-refinement
cmake -S desktop/shell -B out/neo-desktop -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build out/neo-desktop
ctest --test-dir out/neo-desktop --output-on-failure
./out/neo-desktop/neo-desktop
```
Use `git switch feat/9-celestial-desktop-refinement` if it already exists. Preserve local modifications.

### Wallpaper / theme setup
1. Open **Settings** on the left rail or gear button in the top bar.
2. Enter the absolute path to a readable JPG, PNG or WebP image on your Ubuntu host (ideally the clean planet/castle background without interface overlays) and click **Apply wallpaper**.
3. Use **Cyan** or **Violet** to switch neon accents. Appearance survives restarts through local QSettings.
4. Use **Use celestial fallback** for the built-in, canvas-generated planet/starfield when no image is configured.

No cloud image download or background networking is performed. A removed/unreadable saved image reverts to the fallback.

### UI acceptance checklist
- Check at both 1360×820 and 1024×640 (within minimum 980×640): top bar, navigation, orbit and cards stay visible. Overlap/clipping is a known risk at smaller sizes; report exact screenshots.
- Test Ctrl+K app search, Ctrl+Space dock expand/collapse, Escape dismissal, click/keyboard accessibility, real apps and pinned-app persistence.
- Test embedded Matrix CLI still executes `pwd` and `echo NEO-OS` and Ctrl+C, Stop/Start; this branch is stacked on PR #6.
- Test wallpaper persistence and both accent selections after restart.
- Confirm AI assistant, device sync, live system telemetry, universal store and workspaces are **explicitly preview-only**. They are not implemented as functional system services.
- Record CPU performance impact and preference for reduced motion. No animation should be required to operate core controls.

This is **a regular Ubuntu window**, not yet an installed NEO-OS shell/compositor. Visual reference fidelity is iterative and must be verified by side-by-side screenshots, not assumed.

## Celestial wallpaper pack and gallery — Issue #9 refinement

The four user-selected wallpapers are distributed as a downloadable `NEO-OS_Celestial_Wallpapers_v0.3.zip` attachment in the project's ChatGPT conversation. **They are not included as binary GitHub assets in this branch**; Qt must find them in the local wallpaper data directory.

1. Save and extract the wallpaper ZIP on your Ubuntu machine. If saved under `$HOME/Downloads`, run:
   ```bash
   mkdir -p "$HOME/Downloads/neo-wallpapers"
   unzip "$HOME/Downloads/NEO-OS_Celestial_Wallpapers_v0.3.zip" -d "$HOME/Downloads/neo-wallpapers"
   bash desktop/shell/install-wallpapers.sh "$HOME/Downloads/neo-wallpapers/wallpapers"
   ```
2. Restart NEO Desktop. It discovers image files from `${XDG_DATA_HOME:-$HOME/.local/share}/neo-os/wallpapers`. The first named wallpaper (`01-ringed-moon-citadel.webp`) is the default if no valid previously selected path is saved.
3. Open **Settings**. Select any thumbnail in the wallpaper gallery, adjust the **Wallpaper contrast** slider, or choose **Cyan / Violet**. These settings persist through QSettings.
4. Verify wallpaper rendering, correct image crop, label readability and no visual collision in a real screenshot. If the ZIP is unavailable, manually place clean PNG/JPG/WebP images in the same data directory using the installer. The generated Canvas fallback still works with zero external assets.

The installer copies images into the current user's XDG data directory with no `sudo`; it deliberately refuses symlinks and only accepts simple image file names. It is not an image parser or full security audit. Never execute downloaded scripts unrelated to the repository.

## Issue #9 — Native wallpaper chooser and empty-gallery fix (2026-11-17)

**Why the gallery was empty:** wallpaper binaries are not part of this Git branch. The application only scans `${XDG_DATA_HOME:-$HOME/.local/share}/neo-os/wallpapers`; it cannot automatically access ChatGPT uploads or a ZIP sitting in Downloads.

**Easy method (no typed file paths):** Open **Settings → Choose image from computer…**. The native Qt 6 `FileDialog` lets you select a PNG/JPG/WebP from any readable location. NEO Desktop validates the image, copies it to its own local gallery under the XDG data directory and sets it as your active wallpaper. The gallery refreshes immediately and is saved across application restarts.

To populate all four supplied wallpapers at once:
```bash
cd ~/neo-os
mkdir -p "$HOME/Downloads/neo-wallpapers"
unzip "$HOME/Downloads/NEO-OS_Celestial_Wallpapers_v0.3.zip" -d "$HOME/Downloads/neo-wallpapers"
bash desktop/shell/install-wallpapers.sh "$HOME/Downloads/neo-wallpapers/wallpapers"
```
Then reopen Settings or restart NEO Desktop. The gallery refreshes whenever Settings opens. The pack remains a separate conversation attachment, not a GitHub-hosted binary asset.

**Ubuntu 24.04 dependency:** install `qml6-module-qtquick-dialogs` if the file chooser's QML import is missing:
```bash
sudo apt install qml6-module-qtquick-dialogs
```
GitHub Actions installs this module. It adds a native Qt file picker, not system-level file-manager integration.

**Safety/limitations:** the import is a user-initiated copy with a 25 MiB size bound and image-format validation, not a security sandbox. Qt Quick.Dialogs uses the platform's available native dialog integration; behavior varies with desktop session and Qt plugins. No graphics compositor or LFS is required for this functionality.

## Wallpaper import failure diagnosis and bundled fallback presets (2026-11-17)

Screenshots showed the native dialog but no image selection result and an empty gallery. Previous code silently returned `false` when Qt could not decode the image, notably possible for WebP on Ubuntu without a plugin. The gallery also depended entirely on the downloaded/installed ZIP, and offered no guaranteed default image choices.

**Current fix:**
- On first run, Qt uses `QPainter` to generate **four built-in procedural celestial wallpaper presets** (PNG) in the current user's XDG library, without network or binary downloads. These are simple abstract planetary backdrops; they are **not** copies of the photoreal generated concept images.
- `Settings → Choose image from computer…` validates the selected image using Qt's image reader, converts it to a PNG in the local NEO gallery, and activates it. The gallery refreshes immediately.
- If import fails, an error line is displayed in Appearance and the C++ log (`NEO wallpaper:`) specifies the failure reason.
- On Ubuntu 24.04, install both Qt Quick Dialogs and additional image formats to read WebP:
  ```bash
  sudo apt install qml6-module-qtquick-dialogs qt6-image-formats-plugins
  ```
- A saved custom image takes precedence at startup. If none exists, the first built-in PNG preset is selected. Click a gallery thumbnail to switch, or Reset for procedural Canvas fallback.
- To use the four actual photoreal images from the chat, extract the ZIP and select individual WebP images through the file picker; these are not included in GitHub's text-only source branch.

**Manual acceptance after updating the branch:** confirm 4+ thumbnails even without installing the ZIP; pick each preset, restart, then choose a WebP from Downloads and confirm it becomes a `custom-*.png` gallery entry, remains visible on the background and persists on restart. If it fails, copy the visible error text or run `./out/neo-desktop/neo-desktop 2>&1 | tee neo-desktop-wallpaper.log`.

**Important:** Generated presets and conversion do not prove the final reference-standard GUI; full image-pack distribution and composition refinement remain open.

### Automated wallpaper regression gate
`neo-desktop --wallpaper-self-test` runs without loading QML: it seeds four built-in PNG presets and verifies that a synthetic local PNG is imported, selected, and visible in the gallery model. CI runs it with `QT_QPA_PLATFORM=offscreen` and a disposable `XDG_DATA_HOME`. This tests the C++ backend but **does not simulate clicking through FileDialog**; Ubuntu manual GUI testing remains required.
