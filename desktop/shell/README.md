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

## Orbital launcher v0.4 visual pass — Issue #9 (2026-11-17)

The reference-highlighted spherical launcher is now a functional Qt/QML component, not a static image: larger responsive hub, layered luminous rings, underside elliptical pedestal, hover/press lighting, active keyboard focus and radial icon layout sourced from the real pinned application list.

- The orbital area now accounts for available space **between** left navigation and right cards and avoids the bottom dock on medium window heights.
- Each pinned app has a keyboard-focusable native `Button` over a styled circular container; Enter/Space launches via the existing Linux backend. Right-click on an icon unpins it.
- The center `dockButton` retains Ctrl+Space expand/collapse and shows a gold focus ring; the hover/press transformations are disabled when Reduce interface animations is selected.
- These are 2D QML effects (several translucent circles and gradients). They are intentionally lightweight for midrange hardware and do not require Qt Quick 3D or Linux From Scratch.

**Manual Ubuntu acceptance:** take screenshot at full size and at 1024×640; check orbit does not cover right cards, sidebar, or bottom dock. Verify all icons launch, keyboard Tab+Enter, right-click unpin and persistence, Ctrl+Space, wallpaper, Matrix CLI, and reduced motion. Note: screenshot fidelity to the original visual concept is still under review.

## Glass-orbit rendering pass — 2026-11-17

The user requested the **3D-like refractive sphere, luminous elliptical waves and curved metallic pedestal** visible in the cropped reference—not more flat concentric Rectangle objects. We replaced the orbit backdrop with `OrbitalGlassScene.qml`, a separate 2.5D Qt Canvas renderer painting a volumetric radial-gradient sphere, rim speculars, projected elliptical light bands, energy rings, and a layered metallic pedestal. `OrbitalGlassBubble.qml` paints glossy app spheres while **real installed Linux icons, launch buttons, right-click unpin and keyboard focus remain independent**.

This is an intentional compositing layer, not a true geometric 3D model, per-pixel backdrop refraction, framebuffer blur or physically based renderer. **Exact parity with photoreal reference art is not yet established.** A shader-based implementation with Qt 6 RHI/Qt Quick 3D may be required for per-pixel normals, blur, textured transparency and realtime volumetric lighting. Prefer reviewing Ubuntu screenshots first before adding GPU complexity.

Manual test: open the orbital launcher, check the glass globe appears behind eight (or however many are pinned) app spheres, compare pedestal and curved bands against reference, press Tab/Enter to launch, right-click to unpin, Ctrl+Space to expand, and verify low-motion behavior. Test at full and compact window sizes and check for Canvas redraw errors in the terminal log.

## Issue #11 — Experimental Qt Quick 3D glass sphere spike (2026-11-17)

Screenshot review of the 2.5D orbit shows basic curves and light trails work, but physically shaped reflective materials are still missing. This stacked experimental branch adds `OrbitalSphere3D.qml` with **genuine 3D sphere mesh and perspective camera**, two real lights, PrincipledMaterial shading, and a modeled pedestal, while the orbital trails and clickable app bubbles remain QML overlays. It is a feasibility spike, **not** an exact photoreal reproduction or physically accurate glass refraction.

### Ubuntu prerequisites
```bash
sudo apt install qt6-quick3d-dev qml6-module-quick3d
```
This package spelling is for Ubuntu 24.04. Run this only if you accept adding Qt developer/runtime packages on your existing Ubuntu machine. LFS is not required to run Qt Quick 3D.

Open **Settings → Use experimental 3D orbital sphere** to switch between the GPU 3D attempt and retained procedural 2.5D fallback. A missing Qt Quick 3D module should leave the 2.5D renderer available. This mode is currently opt-in/on for normal desktop launches; offscreen software CI smoke disables the 3D Loader to protect its graphics-independent test. User GPU compatibility is **not established**.

### Test after CI
- Confirm 3D sphere is visible and responsive at the real Ubuntu display resolution, and contrast it with the fallback using the checkbox.
- Test changing cyan/violet, Reduce Animations, Ctrl+Space, Tab+Enter application launch, right-click unpin, wallpaper/file picker, Matrix CLI.
- Test 1024×640 and a full-size screenshot; record GPU/CPU performance and graphical warnings.
- If QML reports `module QtQuick3D is not installed`, verify the Ubuntu package; if it renders black, report graphics backend and Qt warnings.
- Shaders/texture maps, bloom pipeline, proper refraction, fully modeled orbit bands and platform detail remain future steps. Do **not** advertise exact matching before the screenshots demonstrate it.

### Ubuntu v0.6 screenshot review and 3D lighting correction (2026-11-17)
User screenshot confirms the experimental Quick 3D scene loads and remains embedded in the celestial desktop, with real pinned app bubbles, but reveals a **nearly black central sphere and solid dark pedestal**. Core problem in the scene code: highly metallic, dark, stacked transparent shells with no image-based light probe give poor perceived illumination; the podium had only two dark cylinders.

The next increment changes the mesh composition to a **lit opaque colored core** plus a restrained transparent outer shell, brighter directional/point lights, and five layered pedestal discs with luminous cyan/purple rims. `PrincipledMaterial.emissiveFactor` adds visible self-illumination, not true light emission onto neighboring objects, and the rings still use the Canvas overlay. A realistic environment reflection/light probe, refraction, screen-space background blur and bloom pipeline remain future tasks.

After updating, compare new Ubuntu screenshots with the previous result. In Settings, toggle **Use experimental 3D orbital sphere** and **Reduce interface animations**. Check that actual Linux app icons still launch and the 2.5D fallback remains. If sphere or pedestal appears dark/black, capture console warnings and GPU info. A successful CI compile does **not** establish the look on the target HP all-in-one GPU.

### 3D glass contrast correction after Ubuntu screenshot (2026-11-17)
The material tuning from the prior pass made the sphere **too luminous and opaque** on the user's machine. The next revision deliberately darkens the opaque 3D core to navy/violet, reduces direct/point-light intensity and pedestal emission, and adds narrow low-opacity edge highlights to suggest glass. It does not yet offer physically correct refraction, screen-space blur or environment reflections. Test with a busy photoreal wallpaper and with a simple solid background, then compare against the close-up reference. A screenshot is needed to determine whether the tuning worked.

### 3D glass clarity control — 16:53 visual feedback
The newest Ubuntu screenshot shows a darker sphere, but the opaque core still hides the scenery instead of resembling transparent glass. The **3D glass clarity** slider in Settings now adjusts transparency of both real 3D `#Sphere` model layers; the default is 78%. It is not physically accurate glass or blur and does not persist yet. Change the slider without rebuilding and compare the same wallpaper at several values. Check for depth/sorting artifacts and whether icons remain keyboard-operable. **Do not accept reference visual parity based solely on alpha blending.**

### v0.7 image-based lighting and polished glass (Issue #11)
The previous transparency tuning alone cannot create realistic specular reflections. This branch now generates a deterministic **low-dynamic-range equirectangular studio reflection probe** in the user's XDG data folder (`neo-os/render/orbital_studio_probe_v1.png`). It is created locally using QPainter (no downloads or privilege escalation), and the Qt Quick 3D `SceneEnvironment.lightProbe` consumes it to supply *actual environment-based lighting* to sphere/pedestal materials. A clearcoat layer is also applied to the outer shell.

In Appearance, toggle **Studio reflections (experimental)** on/off while the 3D scene is active and compare the glossy highlight structure. The 3D glass clarity slider remains adjustable. The generated probe is independent of the currently chosen desktop wallpaper; it is not real-time screen-space reflection/refraction or an HDRI. The probe's specular quality depends on the Qt Quick 3D runtime, available graphics backend and material opacity.

The headless wallpaper backend test also confirms that the local PNG probe is present and readable. **GitHub's software offscreen QML smoke intentionally uses the non-3D fallback**, so confirm actual GPU illumination using Ubuntu screenshots and logs before accepting. No LFS build is required.
