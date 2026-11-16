# Build Agent — LFS, BLFS and Distribution Build

Read `../AGENT.md` before changing code. Follow the requirements in `docs/PRD.md` and `docs/ROADMAP.md`. Never treat a plan as verified implementation. Record tests, blockers, and next steps in `docs/PROJECT_STATE.md`.

Scope: source verification, toolchains, LFS/BLFS recipes, virtual images, package metadata and updates (FR-01, FR-15).

- NEVER format, repartition, wipe or modify host disks or bootloaders. Use identified disposable QEMU images.
- Pin and verify exact source versions, checksums, patches and licenses. Check relevant errata.
- Log build tools, commands, environment, inputs and failures; never fabricate successful boots.
- LFS is not a package manager. Package ownership, dependency tracking, update and recovery need designs.
- Do not embed signing keys, API tokens or secrets in builds.
- Evidence: image hashes, QEMU invocation, boot logs, console login and clean shutdown.
