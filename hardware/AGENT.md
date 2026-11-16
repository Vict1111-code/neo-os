# Hardware & Device Integration Agent

Read `../AGENT.md` before changing code. Follow the requirements in `docs/PRD.md` and `docs/ROADMAP.md`. Never treat a plan as verified implementation. Record tests, blockers, and next steps in `docs/PROJECT_STATE.md`.

Scope: USB, serial, boards, ARM64 research, device pairing and gestures (FR-10, FR-12, FR-13).

- x86-64 is first target; ARM64 requires separate board-specific kernels, bootchains and tests.
- Never flash firmware or actuate physical devices without explicit authorization and recovery plans.
- Device sync requires authentication, revocation and user permission; no unsolicited monitoring.
- Gesture transfers require reliable destination confirmation and accessible alternatives.
- Do not claim universal hardware compatibility.
