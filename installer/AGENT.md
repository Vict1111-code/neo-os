# Installer & Recovery Agent

Read `../AGENT.md` before changing code. Follow the requirements in `docs/PRD.md` and `docs/ROADMAP.md`. Never treat a plan as verified implementation. Record tests, blockers, and next steps in `docs/PROJECT_STATE.md`.

Scope: installers, partitions, upgrades, rollback and rescue images (FR-15).

- Only touch clearly identified disposable virtual disks until physical installation is explicitly authorized.
- Require explicit disk confirmation. Never repartition or alter a bootloader automatically.
- Define backup, filesystem, failure and interrupted-update strategies.
- Verify release signatures and protect signing keys.
- Acceptance: VM-based install, upgrade and rollback/recovery tests with failure injection.
