# NEO-OS — AI Agent Operating Manual

> Version 1.0 | 2026-11-16 | Status: **planning baseline, not implemented**
> Applies to the entire repository. Nested `AGENT.md` instructions narrow, never override, these safeguards.

## Mission
Develop **NEO-OS**, an AI-native, developer-first, hardware-oriented, source-built GNU/Linux distribution based initially on Linux From Scratch (LFS) and Beyond Linux From Scratch (BLFS), with a classical-futuristic Neon GUI, orbital launcher, and functional Matrix CLI. The OS must remain usable for everyday computing. The working name **NEO-OS** is provisional.

## Authoritative project references
- `docs/PRD.md` — product scope, FR-01 through FR-15, P0–P3 priority tags.
- `docs/ROADMAP.md` — Phases 0–10, milestones and acceptance gates.
- `docs/ARCHITECTURE.md` — approved design and module boundaries (create/review during Phase 0).
- `docs/ADR/` — accepted architectural decisions only; `proposed` is not `accepted`.
- `docs/DESIGN_SYSTEM.md` — visual system and interaction rules.
- `docs/SECURITY.md` — threat model and privileged-operation boundaries.
- `docs/PROJECT_STATE.md` — current implementation evidence and next work.

The PRD and roadmap **must be copied from the approved master documents** before an agent treats repository versions as authoritative. Do not invent approval or assume a file exists because it is referenced here. Source documents: `NEO-OS_Full_PRD_v1.0.docx` and `NEO-OS_Implementation_Roadmap_v1.0.docx` (provided separately; include corresponding Markdown exports when initializing repo).

## Project rules
1. Inspect the actual repository tree, working branch, existing code, and `docs/PROJECT_STATE.md` before edits. Never claim a feature is complete based on the PRD, screenshots or conversation alone.
2. Select one defined issue or small vertical slice. State the linked FR, Phase, test evidence, dependencies, and definition of done.
3. Prefer integrating mature, audited upstream Linux/Qt/Wayland components to rewriting entire subsystems. Rust-first applies to **new native system services**, not the Linux kernel or all third-party packages.
4. LFS is a build book, **not** a package manager or sustainable update service. Record all third-party sources, versions, checksums, patch provenance and licenses.
5. Use a version-pinned, isolated build environment (QEMU/virtual disk); **never** repartition, overwrite host disks, modify host bootloaders, or run destructive device commands without clear, explicit operator authorization.
6. Never run untrusted downloads, installers, generated scripts, firmware flashing, privilege escalation, or network-policy changes without review and explicit authorization. Do not expose secrets or API tokens.
7. AI has no implicit root privileges. Separate AI inference from privileged execution; apply explicit scopes, consent, logging, safe defaults, and user confirmation for consequential actions.
8. Security and privacy language must be precise: 'Private Mode' is not anonymity or guaranteed protection. Cross-platform app discovery is not universal runtime compatibility.
9. Accessibility, reduced motion, keyboard operation, legible text, and an uncomplicated default desktop are baseline requirements—even with elaborate visuals.
10. Verify code by running the most relevant tests and recording results. Mark tests **not run** when not executed. Never fabricate boot success, screenshots, deployments, hardware validation, performance metrics, or release artifacts.
11. Preserve third-party licenses and source attribution. Do not make unsupported binary-compatibility guarantees.
12. Update `docs/PROJECT_STATE.md` and relevant component `AGENT.md` at the end of any completed implementation, noting changed files, commands/tests and next actions.

## Project structure (target; do not assume it exists)
```text
neo-os/
├── AGENT.md                         # this file
├── docs/{PRD,ROADMAP,ARCHITECTURE,DESIGN_SYSTEM,SECURITY,PROJECT_STATE}.md
├── docs/ADR/                       # individual decision records
├── docs/agent/                     # templates, workflow and test policy
├── build/{lfs,blfs,packages}/
├── core/{kernel,services,security}/
├── desktop/{shell,orbital-dock,matrix-cli,control-center}/
├── ai/  developer/  hardware/  app-store/  installer/
├── tests/  .github/workflows/
└── assets/references/              # authorized source images, if added
```

## Release boundaries
- **P0 / v0.1 developer preview:** bootable source-built base; initial GUI, dock, Matrix CLI, developer tools and basic configuration.
- **P1:** AI foundation, NEO Guard, NEO Market prototype, everyday productivity and distribution/update capabilities.
- **P2:** advanced compatibility, device sync and hardware toolkit.
- **P3:** experimental gestures and speculative platform research.
Do not automatically schedule all P1–P3 features into the first milestone.

## Work intake and execution
1. **Discover:** inspect `git status`, repository files, issue, current phase, applicable nested instructions and referenced requirements.
2. **Plan:** outline exact files, risks, dependencies and acceptance criteria; note assumptions.
3. **Implement:** minimal well-scoped change; avoid unrelated refactoring.
4. **Verify:** build, unit tests, integration tests, static checks and manual UI tests where available; capture exact commands and outcomes.
5. **Document:** update API docs/ADRs for changes, log limitations and evidence in `docs/PROJECT_STATE.md`.
6. **Handoff:** summarize what changed, what has **not** been verified, and next actionable issue.

## Mandatory pre-merge checklist
- [ ] FR/Phase issue link and acceptance criteria identified
- [ ] Existing behavior inspected; no unintended scope expansion
- [ ] Build and tests executed or explicitly marked not run
- [ ] Secrets and privileged operations reviewed
- [ ] UX/accessibility and error handling considered
- [ ] Third-party dependencies licensed and pinned when relevant
- [ ] Documentation and `docs/PROJECT_STATE.md` updated
- [ ] Known limitations and rollback/recovery plan stated

## Current verified project status
**No source implementation, LFS build, OS boot, hardware test, or CI execution is verified by this agent-file package.** Phase 0 remains an evidence-gathering and design-approval gate. The PRD and roadmap are prepared separately as planning documents. See `docs/PROJECT_STATE.md`.
## Required GitHub delivery lifecycle and teaching handoff
Every repository change, including documentation, must follow **Issue → feature branch → commits → pull request → review/checks → merge → issue closure**. Do not commit directly to `master` in normal development. Exceptions (e.g. production emergency) require a documented issue and follow-up PR; never bypass repository protection or falsely claim checks passed. Link PRs to issues using `Closes #N` when appropriate; merge only after relevant tests and review evidence are established. If CI or an independent reviewer is unavailable, disclose that clearly and keep the PR open for review rather than asserting approval. Close issues only after validated acceptance criteria are met.

After every implementation, give the user a **substantive engineering lesson**: why the change was needed; relevant OS, C++, Qt/QML, Rust, Linux or Git concepts; precise files/functions changed; how data/control flows; security/trade-offs; commands to reproduce; test evidence and limits; and 1–3 short comprehension questions or hands-on exercises. Explain new terminology progressively, relate learning to actual changed code, and invite the user to demonstrate understanding. Do not confuse explanation with test evidence.

Pull request descriptions must include issue, scope, tests, screenshots/logs if relevant, risks, rollback, and a teaching section. Update `docs/PROJECT_STATE.md` and applicable `AGENT.md` as part of the same PR. See `docs/agent/WORKFLOW.md`.
