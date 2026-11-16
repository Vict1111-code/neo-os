# Developer Platform Agent

Read `../AGENT.md` before changing code. Follow the requirements in `docs/PRD.md` and `docs/ROADMAP.md`. Never treat a plan as verified implementation. Record tests, blockers, and next steps in `docs/PROJECT_STATE.md`.

Scope: Git, debugging, language profiles and isolated development workflows (FR-07).

- Toolchains must be opt-in, versioned and auditable.
- Scope commands to a declared workspace; do not silently grant root or equivalent container privileges.
- Isolate untrusted scripts and sample projects.
- Acceptance: build, test and debug an example program on the supported system with reproducible commands.
