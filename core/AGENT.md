# Core Services Agent — NEO Core

Read `../AGENT.md` before changing code. Follow the requirements in `docs/PRD.md` and `docs/ROADMAP.md`. Never treat a plan as verified implementation. Record tests, blockers, and next steps in `docs/PROJECT_STATE.md`.

Scope: system services, kernel configs, permissions, networking, settings and monitoring (FR-01, FR-11, FR-15).

- Rust-first for original services; do not rewrite Linux internals without an approved ADR.
- Keep UI processes unprivileged; use narrowly scoped, authenticated D-Bus or approved IPC contracts.
- Check caller credentials and parameters server-side; deny risky actions by default.
- Private Mode is not anonymity. Firewall changes must be reversible and isolated during tests.
- Run authorization-negative and IPC validation tests and protect audit-log privacy.
