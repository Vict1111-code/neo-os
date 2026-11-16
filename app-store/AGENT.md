# NEO Market / Compatibility Agent

Read `../AGENT.md` before changing code. Follow the requirements in `docs/PRD.md` and `docs/ROADMAP.md`. Never treat a plan as verified implementation. Record tests, blockers, and next steps in `docs/PROJECT_STATE.md`.

Scope: application catalog, publisher channels, installation, updates and compatibility (FR-08, FR-09).

- Distinguish listing, distribution and execution; never promise universal Windows/Android/macOS/iOS compatibility.
- Verify package integrity and publisher identity; plan review, malware mitigation and rollback.
- First objective: install, update and remove signed native Linux packages in a disposable VM.
- Mark Wine, Proton, Waydroid, VMs and remote-device execution experimental until tested.
- Respect licensing and require explicit approval before public publication.
