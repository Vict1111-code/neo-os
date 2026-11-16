# NEO-OS

**AI-native · Developer-first · Hardware-oriented GNU/Linux operating system**

NEO-OS is a proposed source-built operating system based on Linux From Scratch (LFS) and Beyond Linux From Scratch (BLFS), targeting x86-64 first. The project envisions a classical-futuristic Qt/QML desktop with an orbital app dock, working Matrix CLI, protected AI tools, developer workspaces, and future device integration.

> **Status:** Planning / Phase 0. No verified OS build, desktop implementation, installer, AI daemon, or hardware certification. The working name is provisional.

## Start here

- [`docs/PRD.md`](docs/PRD.md) — PRD v1.0 candidate text export (tables/layout from the DOCX may not preserve formatting)
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — 11-phase implementation strategy, candidate text export
- [`AGENT.md`](AGENT.md) — coding-agent project instructions
- [`docs/PROJECT_STATE.md`](docs/PROJECT_STATE.md) — verified status and next steps
- [`docs/agent/`](docs/agent/) — issue/ADR/handoff templates, backlog and test rules
- Component agent guidance: [`core/`](core/AGENT.md), [`build/`](build/AGENT.md), [`desktop/`](desktop/AGENT.md), [`ai/`](ai/AGENT.md), [`developer/`](developer/AGENT.md), [`app-store/`](app-store/AGENT.md), [`hardware/`](hardware/AGENT.md), [`installer/`](installer/AGENT.md)

## Initial architecture

Linux kernel + LFS/BLFS systemd userspace; Rust-first new system services; Wayland and Qt 6/QML desktop; QEMU-first system builds and hardware testing. Complex compatibility, gesture interaction and custom hardware remain staged research goals.

## Original downloadable artifacts

The original PDF/DOCX master documents and generated agent ZIP remain separate conversation attachments. Their source-readable document exports and 18 agent-guidance files are represented here as Markdown. **Binary PDFs, DOCX files, ZIP archives and design reference images have not yet been uploaded to this repository.** The component agent files have been organized for GitHub and may differ in wording from the previously generated ZIP; review against that package before treating them as exact copies.

## Engineering safety

Do not execute destructive host-disk or bootloader operations for LFS experiments. Use isolated virtual disks, signed/checksummed sources, privileged-service boundaries and verified tests. Never mark planned features as completed based on mockups alone.
