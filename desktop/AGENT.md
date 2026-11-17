# Desktop Agent — NEO Desktop

Read `../AGENT.md` before changing code. Follow the requirements in `docs/PRD.md` and `docs/ROADMAP.md`. Never treat a plan as verified implementation. Record tests, blockers, and next steps in `docs/PROJECT_STATE.md`.

Scope: Qt/QML shell, orbital dock, Matrix CLI, settings and accessibility (FR-02 through FR-05, FR-14).

- Prototype under an existing compositor without replacing the host login session.
- Use Qt 6/QML; apply Qt Quick 3D only where justified by usefulness and performance.
- Orbital dock must launch real apps, retain pins, support keyboard and reduced motion, and reflect runtime state when supported.
- Matrix CLI must execute real commands; themed terminal != independent recovery console.
- Keep layouts readable and uncluttered; references are design inspiration, not implemented evidence.
- Test multiple resolutions, scale factors and reduced-effects mode; no invented compositor claims.
- First deliverable: Qt shell and dock launching an allowlisted application with UI tests.

## Current prototype status (2026-11-16)
- Qt Quick shell proof-of-concept source committed under `desktop/shell/` (CMake, C++, QML, README).
- Dock, pin persistence, installed application enumeration, and terminal launch are implemented **in source only**. No compilation, runtime UI behavior, or application launch has yet been verified.
- Static source checks were inspected; GitHub CI workflow exists but passing execution is unverified.
- Next: verify Qt CMake compilation and QML startup; confirm real app launch, pin persistence, reduced motion, and terminal behavior on supported Linux. Fix errors before claiming a working demo.

## Issue #3 — Keyboard-first dock validation (in review)
- Source branch `feat/3-keyboard-orbital-dock` proposes window-scoped shortcuts Ctrl+Space (dock), Ctrl+K (app search), Escape (dismiss), and keyboard-focus styling.
- Relevant Qt Quick QML feature: `Shortcut` with window context; `Button` with strong focus policy.
- C++ launcher/pins unchanged. Ubuntu compilation and runtime keyboard behavior still need validation; do not claim completion until issue criteria are verified.

## Issue #3 validation update (2026-11-16)
- User reports 6/6 manual Ubuntu checks passed: Ctrl+Space, Ctrl+K, Escape, dock-center keyboard activation, real app launching, and pin persistence.
- GitHub Actions PR #4 run #14 built successfully and passed static source tests; broader automated GUI interaction and independent review were not performed.
- Remaining engineering work: real window management integration, fuller keyboard/a11y checks, reliable app-state tracking, and LFS integration.

## Issue #5 — Embedded Matrix PTY prototype
- On `feat/5-matrix-pty-prototype`, `MatrixPty.h/.cpp` supplies a limited `forkpty()` shell; `MatrixTerminal.qml` renders output and sends line-oriented input.
- ADR-011 records the limited PTY prototype versus mature terminal widget alternatives. **Not a full terminal emulator**; no claim of full Unicode, ANSI, resize, per-keystroke shell control or complete cleanup without testing.
- Confirm CI build, Ubuntu GUI interaction, Ctrl+C, Stop/Start, regression checks and shell cleanup before merging or closing Issue #5.

## Issue #5 lifecycle hardening (review pending)
- `MatrixPty::stop()` now attempts to signal the foreground PTY process group and Bash process group before reap/force-kill of the direct child.
- `MatrixPtySmoke.cpp` adds a live headless integration test and CTest/CI integration. It does not establish cleanup of arbitrary detached descendants.
- Do not call this a production-quality terminal emulator. Review/test errors and manual Ubuntu behavior before merging.

## Issue #9 — Reference-driven celestial refinement
- Branch `feat/9-celestial-desktop-refinement` is **stacked on** `feat/5-matrix-pty-prototype` / PR #6. Its PR must target the same base until Matrix #6 merges; then rebase/retarget and rerun CI. Do not accidentally discard `MatrixPty`.
- User-supplied UI references show starry planetary/fantasy celestial scenes, dark translucent glass panels, cyan/violet/pink highlights, top workspace switcher, left navigation, orbit-style launcher and status/AI/store/device cards.
- Implement real local app controls; label unsupported AI, telemetry, universal app store, device sync and workspace isolation as preview. No fake live statistics.
- Wallpaper setting accepts a verified readable **local** image path and stores a file URL; fallback is generated Canvas scenery, not a claim that the uploaded screenshot has been embedded as a clean wallpaper.
- Verify 1360×820 and 1024×640, QML errors, app launching, pins, wallpaper persistence, keyboard focus, Matrix CLI and reduced motion before merge.

## Issue #9 — Celestial wallpaper/gallery refinement
- `desktop/shell/install-wallpapers.sh` copies local PNG/JPG/WebP assets from a user-supplied extracted wallpaper pack into the user's XDG data directory without sudo. **The generated image binaries are not yet committed in GitHub.**
- `DesktopBackend` discovers readable image assets in `neo-os/wallpapers`, defaults to sorted `01-ringed-moon-citadel.webp` if installed and no saved choice, and persists selected wallpaper and dim level.
- `Main.qml` now provides a scrollable thumbnail gallery, wallpaper contrast slider, luminous orbit-ring halo and compact dock styling.
- Verify actual renders and settings persistence on Ubuntu. CI compile and source checks do not guarantee pixel-level reference fidelity.

## Issue #9 native wallpaper picker (2026-11-17)
- Screenshots from Ubuntu show no gallery entries because the wallpaper pack was not present in the expected XDG data directory, not because Qt/C++ cannot render image assets.
- `QtQuick.Dialogs FileDialog` now allows choosing an image through a graphical picker, avoiding manual path entry. `DesktopBackend.importWallpaper()` validates and copies the user-selected image to an XDG wallpaper gallery and refreshes it immediately via `wallpaperThemesChanged`.
- `refreshWallpapers()` is called on startup and when opening Settings; gallery displays an explicit empty state rather than a blank strip. Qt Quick Dialogs Ubuntu runtime module must be installed.
- Follow through with source tests, compile CI, Ubuntu picker/selection/gallery/restart screenshots; **do not declare the UI visually equivalent to user concept art yet**. Graphic polish can proceed on Ubuntu; LFS is needed later for the independent OS session, boot and system integration.
