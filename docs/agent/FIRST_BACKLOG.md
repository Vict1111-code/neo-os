# Initial NEO-OS Engineering Backlog

## Phase 0 — Architecture and Technical Foundation
- [ ] Review PRD and roadmap text exports against original signed-off candidates.
- [ ] Approve system architecture and module boundaries.
- [ ] Write initial ADRs: LFS, Wayland/Qt, package management, IPC, security.
- [ ] Document source verification, build environment and release requirements.
- [ ] Inventory host OS, CPU, RAM, disk, virtualization and available storage.
- [ ] Establish repository tests and CI workflow.

## Track A — Desktop Proof of Concept
- [ ] Initialize Qt/QML application shell.
- [ ] Implement compact expandable orbital dock with real application launch.
- [ ] Add saved pins, keyboard support, reduced motion and UI tests.
- [ ] Add Matrix CLI terminal prototype with working shell.

## Track B — LFS Core
- [ ] Prepare safe isolated virtual build environment.
- [ ] Pin source downloads and checksum manifest.
- [ ] Build cross-toolchain, LFS base, kernel and boot setup.
- [ ] Verify QEMU console login and shutdown with logs.

## Integration
- [ ] Build BLFS graphical prerequisites and launch NEO Desktop on NEO Core.
- [ ] Track open risks and actual verification evidence.
