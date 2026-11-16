# NEO-OS PRD — Text export of the signed-off candidate document

> Source: `NEO-OS_Full_PRD_v1.0.docx`. This is a text extraction for review, not a claim of technical implementation.




NEO-OS
Master Product Requirements Document (PRD)
Version 1.0 candidate | Status: proposed, not approved | 16 November 2026

Scope: LFS-based Linux desktop, AI-native services, developer tooling, future hardware support.

This is an engineering plan, not evidence that the operating system or its features have been implemented.




                                                  NEO-OS • Draft for technical review | 16 November 2026 | 1


Document control
    Item                                                     Definition

    Working name                                             NEO-OS; final branding pending
    Document owner                                           Project engineering team (roles unassigned)
                                                             Linux From Scratch + Beyond Linux From Scratch,
    Base
                                                             systemd variant
                                                             Candidate requirements; design and architecture
    Status
                                                             review pending
                                                             Initial x86-64 virtual machine and selected desktop
    Targets
                                                             computers
                                                             Architecture, packaging, reference hardware, GUI
    Next decision gate
                                                             behavior, security threat model




1. Executive summary
NEO-OS is a proposed source-built GNU/Linux operating system that unifies an original classical-futuristic
desktop, AI-assisted workflows, software engineering, defensive security, embedded development, and everyday
productivity. The Linux kernel supplies foundational hardware and process capabilities; the project owns the
distribution integration, services, UX, software tooling, update policy, and release infrastructure.

The project deliberately separates a rapidly testable Qt/QML desktop prototype from a reproducible Linux From
Scratch (LFS) boot environment. The initial release is a developer preview rather than a production-safe general-
purpose distribution.


2. Vision, principles and constraints
     AI-native, not AI-dependent: ordinary computing must work offline and without an AI provider.
     Developer-first, not developer-only: users can browse, study, work with documents, and use accessibility
      features.
     Distinctive but usable: the orbital dock and 3D neon visual identity must have low-motion, high-contrast and
      conventional fallback modes.
     Secure by default: least-privileged services, user confirmation for consequential AI actions, auditable
      permissions and verified software.
     Hardware-aware and extensible: begin with x86-64; add selected ARM boards only after independent
      validation.
     Source-built and maintainable: pin inputs, record package ownership, manage upstream CVEs and test
      update/recovery workflows.


3. Target users and jobs-to-be-done
    Persona                                Primary jobs                         Critical expectation

                                           Edit, compile, test, debug,
    Developer                                                                   Reliable toolchains and terminal
                                           containerize, publish software
                                           Use remote/local models; build       Controlled model access and
    AI engineer
                                           agent workflows                      permissions
    Security practitioner                  Inspect systems and networks;        Isolation, logs and safe defaults

                                                      NEO-OS • Draft for technical review | 16 November 2026 | 2


                                        authorized testing
                                        Inspect USB/serial devices;            Explicit device permissions and
 Embedded engineer
                                        build/flash firmware                   board profiles
                                        Browse, files, assignments, media,     Easy UI; no technical setup
 Student / general user
                                        communication                          mandatory
                                                                               Measured GPU compatibility;
 Creator/gamer                          Design, media, selected games
                                                                               realistic claims




4. Product and subsystem scope
 Subsystem                              Owner of functionality                 Boundary

                                        Kernel configuration, LFS              Upstream Linux kernel rather than
 NEO Core
                                        userland, init, build recipes          own kernel
                                        Desktop surfaces, dock, panels,        Leverage mature compositor
 NEO Shell
                                        settings                               initially
                                        Functional terminal-oriented           Graphical mode distinct from real
 Matrix CLI
                                        environment                            tty
                                        Inference, context, orchestration,
 NEO AI                                                                        No arbitrary root commands
                                        permissioned tools
 NEO Dev                                Toolchain and workspace lifecycle      Optional profiles
 NEO Market                             Catalog, packages, publisher testing   Not universal binary execution
                                                                               Platform and user permission
 NEO Connect                            Phone/device pairing and sync
                                                                               restrictions
                                        Firewall profiles and network
 NEO Guard                                                                     No untraceability guarantee
                                        visibility
                                        USB/serial, cross-compile and
 NEO Hardware                                                                  Device-specific support required
                                        diagnostics




5. Functional requirements

FR-01 Base OS and sessions [P0]
Requirement: Boot/shutdown; users, groups and authentication; multi-process operation; kernel-supported
filesystems; networking; input, audio and display; logs; service supervision; emergency console.

Acceptance: Boot to login, run two concurrent processes, file read/write, network on supported VM hardware,
safe shutdown and restart.


FR-02 Desktop shell [P0]
Requirement: Graphical login/session, status panel, desktop shortcuts, workspace controls, settings, notifications,
app launch, theme/wallpaper selection and basic scaling.

Acceptance: Open multiple windows, switch workspaces, persist chosen theme and restore session safely.




                                                    NEO-OS • Draft for technical review | 16 November 2026 | 3


FR-03 Orbital taskbar [P0]
Requirement: Circular compact dock located by user preference (initially bottom-right or bottom-center);
expanding orbit; pinned icons; running badges; focus/switch actions; context menu; keyboard fallback; adjustable
animation.

Acceptance: Dock launches apps, identifies running app, supports focus and pin/unpin; low-motion mode remains
usable.


FR-04 Matrix CLI [P0]
Requirement: Matrix-style shell/TUI with real command execution, search/history, theme, optional telemetry
panes and GUI quick-switch. Preserve standard tty as recovery interface.

Acceptance: Execute actual shell commands; return to GUI; recovery tty works if graphical process crashes.


FR-05 NEO Control Center [P0]
Requirement: System status, app and device configuration, appearance, updates, permission settings, network
profiles and logs.

Acceptance: Settings changes persist; failures are reported with actionable diagnostics.


FR-06 AI platform [P1]
Requirement: Provider-neutral inference API, configurable remote/local models, session controls, search/context
connectors, read-only diagnostics, permissioned tools, audit trail and explicit approval for privileged actions.

Acceptance: AI offline/unavailable does not impact boot; denied tool call does not execute; confirmation logged.


FR-07 Developer suite [P0]
Requirement: Language toolchain profiles, code editors, Git, debugger, terminal, test runners, containers/VM
where available, local services, deploy hooks.

Acceptance: Create, build, test and debug sample code using isolated development profile.


FR-08 NEO Market [P1]
Requirement: Discover, publish, sign/verify, install, remove, test and update supported apps with release channels
and compatibility metadata. Private dev channel required before public store.

Acceptance: Private submission install works; corrupted artifact rejected; incompatible runtime clearly labelled.


FR-09 Compatibility integration [P2]
Requirement: Linux-native and web first; optional Wine/Proton for selected Windows binaries and Android
environment for supported devices; macOS/iOS only documented remote/limited approaches.

Acceptance: Each tested app has compatibility result; no promise of universal running.


FR-10 Device sync [P2]
Requirement: Pair/revoke authorized devices, transfer files, shared clipboard, supported notifications, optionally
phone calls/messages subject to mobile platform constraints.

Acceptance: Secure pairing, user-initiated transfers, revocation, and permissions tests pass.



                                                    NEO-OS • Draft for technical review | 16 November 2026 | 4


FR-11 NEO Guard [P1]
Requirement: Inbound firewall, policy visibility, restricted app connectivity, offline mode, VPN integration,
monitoring, accurate descriptions of privacy guarantees.

Acceptance: Profiles enforce expected traffic rules in lab tests; restricted mode not mislabelled as anonymity.


FR-12 Hardware toolkit [P2]
Requirement: USB/serial discovery, permissioned serial console, firmware flashing tools, cross-compilation
profiles, debugging and ARM board research.

Acceptance: Selected test board connects; user-approved flash flow records selected target and firmware hash.


FR-13 Gesture interactions [P3]
Requirement: Research-stage hand tracking for pinch-to-select, drag/drop and transfer to authorized paired
device; calibration and accessibility fallback.

Acceptance: Prototype meets defined false-trigger and confirmation thresholds before opt-in trials.


FR-14 Everyday computing [P1]
Requirement: Browser, files, audio/video, print where drivers support, office apps, educational tools, ordinary
account management.

Acceptance: Non-developer can complete defined basic workflows without AI or terminal.


FR-15 Install, update and recover [P1]
Requirement: Image creation, installer, package records, verified updates, failed-update recovery/rollback and
security advisories.

Acceptance: Cold install, upgrade, interrupted update and recovery scenarios pass release gate.


6. UX and design system
Design direction is classical-futuristic: deep navy/graphite surfaces, restrained cyan-blue as primary functional
accent, violet highlights, selective gold details, celestial/architectural wallpapers, subtle glassmorphism and
optional 3D depth. Do not reproduce the crowded concept artwork as the default everyday layout.

                                                                                Accessibility/performance
 Area                                    Default behavior
                                                                                fallback

                                         Status, workspaces, search,            High contrast, keyboard focus,
 Top bar
                                         notifications, connectivity            readable labels
                                         Clear workspace; optional project      Static background, scalable
 Desktop
                                         shortcuts and widgets                  typography
                                         Compact orbit; reveal apps on          Static linear launcher or accessible
 Orbital dock
                                         hover/click                            list
                                         Clear active borders and restrained
 Windows                                                                        Opaque window borders
                                         translucent surfaces
                                         Functional terminal with optional
 Matrix CLI                                                                     Plain terminal/TTY
                                         panels
 AI panel                                Contextual, closed by default          Full-screen accessible dialog


                                                    NEO-OS • Draft for technical review | 16 November 2026 | 5





7. Architecture and interface contracts
Services should prefer unprivileged processes and typed local IPC. Initial design choice: D-Bus for system/desktop
integration; Unix domain sockets and JSON-RPC or gRPC can be evaluated for specialized AI/dev interfaces.
Systemd may supervise core daemons. Privileged service APIs must authenticate the caller, authorize each
capability and log consequential operations.

    Service (proposed)                    API capabilities                        Access policy

                                          read/update theme, dock and
    neo-settingsd                                                                 User session scoped
                                          session settings
                                          resolve application desktop IDs,
    neo-launcherd                                                                 Desktop session only
                                          launch, focus requests
                                          models, prompts, approved tools         Unprivileged default; mediated
    neo-ai-gateway
                                          and audit records                       actions
                                          capability grants, requests and         Privileged broker with policy
    neo-permissiond
                                          revocations                             checks
                                          check, verify, stage update and
    neo-updated                                                                   Privileged; signed artifacts
                                          recover
                                          install and manage supported            Separated catalog vs installer
    neo-marketd
                                          packages                                privileges
    neo-connectd                          pair, transfer, revoke device           Authenticated per device
                                          read firewall state, request policy
    neo-guardd                                                                    Privileged and user-confirmed
                                          changes




8. Security, privacy and trust model
     Threat classes: malicious packages, supply-chain compromise, unsafe AI tool execution, local privilege
      escalation, malicious input/prompt injection, insecure paired devices, accidental destructive admin actions.
     Default-deny inbound traffic where feasible; never imply Private Mode provides anonymity.
     Sign update artifacts and authenticate repository metadata; publish provenance and package manifests.
     Keep secrets in credential stores; never place API keys or tokens in plaintext settings/logs.
     Run AI model inference and file indexing as unprivileged services; broker system changes.
     Treat third-party app repositories and compatibility tools as explicit trust boundaries.
     Release critical fixes through a documented patch and vulnerability intake process.


9. Nonfunctional requirements and target metrics
    Quality                                                   Initial target / gate

                                                              Record measured VM boot time; set release threshold
    Boot
                                                              only after baseline
                                                              Target smooth 60 FPS on defined accelerated
    Animation
                                                              reference hardware; degrade gracefully
                                                              8 GB host target for desktop and tools without
    Memory
                                                              mandatory local LLM


                                                      NEO-OS • Draft for technical review | 16 November 2026 | 6


                                                           AI service or marketplace crash must not bring down
    Failure isolation
                                                           desktop or prevent boot
                                                           Documented kernel console access, image backup and
    Recovery
                                                           update recovery
                                                           Keyboard navigation, contrast, zoom, reduced motion,
    Accessibility
                                                           label alternatives
                                                           Version-pinned sources and build records;
    Reproducibility
                                                           deterministic builds pursued and measured
                                                           Publish tested CPU/GPU/Wi-Fi, VM and peripheral
    Hardware
                                                           matrix; avoid universal claims




10. Prioritization and release definitions
    Release                             Required functionality                 Explicitly excluded

                                        QEMU bootable LFS, basic Qt shell,
                                                                               Public production install, universal
    v0.1 Developer Preview              orbital dock, Matrix CLI, dev
                                                                               compatibility
                                        toolchain, logs
                                        Integrated sessions and settings,
    v0.2 Developer Alpha                improved package tracking, test        Advanced gestures
                                        workflows
                                        AI permission broker, signed
    v0.5 Beta                           updates prototype, installer tests,    Unverified hardware families
                                        private Market, device pairing pilot
                                        Install/upgrade/recovery gates,
    v0.9 RC                             security, accessibility, defined       Unrestricted AI root access
                                        compatibility matrix
                                        Supported install/update/recovery
    v1.0 Stable                         and core daily/developer               All third-party apps and hardware
                                        workflows




11. Dependencies and non-goals
     LFS does not provide a ready-maintained distribution; NEO-OS owns long-term packaging, release
      engineering and security update obligations.
     The Linux kernel remains upstream-based; a new kernel is not part of v1.0.
     Custom Wayland compositor is optional until the existing compositor proves inadequate.
     No guarantee of executing arbitrary Windows, macOS, iOS or Android binaries.
     No guarantee of anonymity, physical gesture accuracy or device compatibility across all hardware.
     No unsupervised system-changing AI actions by default.


12. Major risks and mitigations
    Risk                                Impact                                 Mitigation

                                        High security and maintenance          Freeze inputs; package registry;
    Maintaining LFS packages
                                        overhead                               CVE intake; incremental patch


                                                     NEO-OS • Draft for technical review | 16 November 2026 | 7


                                                                                 pipeline
                                                                                 Begin QEMU + defined Intel/AMD
    Graphical driver variety                 Black screen/poor performance
                                                                                 reference devices
                                                                                 Evaluate established solutions;
    Custom package manager too
                                             Schedule and security risk          start with manifests and controlled
    early
                                                                                 recipes
                                                                                 Separate model and broker; least
    AI authority escalation                  Potential destructive actions
                                                                                 privilege; explicit confirmations
                                             Performance and accessibility       Reduced-motion mode;
    Complex animated interface
                                             failure                             measurements; optional effects
                                                                                 Per-app compatibility status, tested
    Compatibility marketing                  User trust and support burden
                                                                                 runtime matrix




13. Definition of done and product acceptance
1.    A traceable requirement exists for each release-blocking feature.
2.    A reproducible development procedure and build logs exist.
3.    Functional tests, security checks and manual usability tests pass on supported targets.
4.    Documentation and AGENT.md reflect the tested implementation.
5.    Critical bugs, vulnerability findings and known incompatibilities are documented.
6.    Release artifacts include manifests, hashes, provenance, installer/recovery instructions and known
      limitations.


14. Open decisions
     Final product and component naming; user-facing icon/logo usage.
     Reference desktop hardware and available disk/virtualization capabilities (not yet verified).
     Package backend and update/rollback architecture; ADR pending.
     Choice of existing compositor, session manager, secure credential store and primary login manager.
     NEO Market publisher trust, moderation and revenue policies (deferred).
     AI data retention, offline defaults, account requirements and remote-provider consent.
     Exact desktop motion behavior, dock position and graphical style tokens.


15. Official background references
     Linux From Scratch stable systemd book: https://www.linuxfromscratch.org/lfs/view/stable-systemd/
     Beyond Linux From Scratch stable systemd: https://www.linuxfromscratch.org/blfs/view/stable-systemd/
     Linux kernel documentation: https://docs.kernel.org/
     Qt documentation: https://doc.qt.io/
     Wayland project: https://wayland.freedesktop.org/
     OSDev Wiki (background, not authoritative distribution recipe): https://wiki.osdev.org/




                                                        NEO-OS • Draft for technical review | 16 November 2026 | 8