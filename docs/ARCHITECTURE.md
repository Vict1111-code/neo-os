# NEO-OS System Architecture — Draft v0.1
**Status:** Proposed for review; no working system has been verified. **Phase:** 0. **Scope:** FR-01–FR-15.

## Principles
1. Preserve upstream Linux kernel semantics; use LFS/BLFS to assemble the x86-64 GNU/Linux base.
2. Ship an ordinary, usable desktop even with AI, networking, gestures or 3D effects disabled.
3. Keep privileged code small and auditable; graphical UI, plugins and AI inference are unprivileged.
4. Version-pin upstream sources, document licenses, and test in QEMU before real hardware.
5. Treat native Linux applications, compatibility-layer apps, and remote-device apps as distinct execution classes.

## Layer map
```text
Applications / NEO Market / Developer IDEs / Browser
          |
NEO Desktop: Qt/QML shell, orbital dock, Matrix terminal, settings
          |
App/session stack: Wayland compositor, display/input, login/session, audio
          |
User services (unprivileged): neo-settingsd, neo-app-indexd,
neo-ai-gateway, neo-device-link, diagnostics
          |
Broker boundaries: authenticated D-Bus / Unix sockets;
neo-policy-broker (minimal root service, authorization checks)
          |
System services: systemd, networking, package/update services,
storage, security frameworks, logging
          |
LFS/BLFS userspace + Linux kernel + supported hardware
```

## Subsystems and ownership
| Subsystem | Prototype technology | Responsibilities | Privilege |
|---|---|---|---|
| NEO shell | Qt Quick/QML | Desktop, status UI, window presentation, orbital dock | User |
| Compositor | Existing Wayland compositor, evaluate later | Windows, input and output routing | User/session |
| Matrix CLI | Qt terminal frontend + a real PTY/shell | Working commands, fullscreen mode, recovery console documented separately | User |
| neo-settingsd | Rust, D-Bus | Read/write per-user preferences, theme, dock pins | User |
| neo-app-indexd | Rust, D-Bus | Discover .desktop launchers and supported app metadata | User |
| neo-ai-gateway | Separate user service | Model providers, tools, limits, context, audit requests | User |
| neo-policy-broker | Minimal Rust service + polkit-style policy | Independently verify high-impact requests | Restricted root |
| neo-packaged/updates | TBD pending ADR | Build, ownership, upgrades, signed metadata, recovery | Elevated, constrained |
| neo-device-link | User agent | Authenticated phone pairing, file transfer and revocation | User |
| NEO Guard | User UI + separate firewall broker | Read policy, request restricted changes | Split |

## IPC and trust boundaries
- D-Bus for well-defined local service APIs; filesystem/socket ACLs and peer credentials must be checked by the receiving service.
- A GUI click or AI output is never an authorization decision.
- The AI service cannot call arbitrary root commands. It sends structured requests to a policy broker; policy broker authenticates sender and may request independent user confirmation.
- Cross-origin application metadata, package manifests, model output, project files and device communications are all untrusted.
- Configuration: user settings under XDG paths; privileged policies under root-owned locations. No shared writable config accepted across trust boundaries.

## Desktop and graphical roadmap
- Stage A: test Qt/QML shell on host Linux with existing compositor, independent of custom LFS image.
- Stage B: Wayland and Qt installed through audited BLFS or source-based recipes in NEO Core image.
- Stage C: integrate login/session, dock app launching, notifications, file manager and terminal.
- Stage D: only consider a custom compositor after multi-monitor, input, accessibility, window tracking and GPU tests.

## Boot and release boundaries
Firmware/UEFI -> bootloader -> Linux kernel/initramfs as configured -> systemd userspace -> login/session manager -> Wayland session -> NEO shell.
Document and verify each transition in QEMU. Installer, signed update, rollback and recovery architecture is a release gate, not a decorative optional feature.

## Performance constraints
Reference development target: 8GB RAM x86-64; no mandatory large local model; reduced-effects UI must be available. 60 FPS is a target on capable tested GPU hardware, not an unverified guarantee.

## Explicitly deferred
Custom kernel scheduler, native macOS/iOS execution, arbitrary mobile device control, full custom Wayland compositor, camera-based gesture transfers and universal ARM hardware support.

## Acceptance gates
1. Every service has a contract, owner, failure mode and authorization boundary.
2. QEMU virtual-disk isolation is documented.
3. Qt desktop can launch a real app in an existing Wayland session.
4. When AI is disabled, common desktop functions continue operating.
5. No implementation or boot success is claimed until demonstrated.
