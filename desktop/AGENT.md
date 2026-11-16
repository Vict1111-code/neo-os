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
