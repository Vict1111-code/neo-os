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
