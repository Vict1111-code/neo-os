# NEO-OS Implementation Roadmap — Text export

> Source: `NEO-OS_Implementation_Roadmap_v1.0.docx`. Layout and some tables may not survive extraction; consult the original document for formatting.




NEO-OS
Master Implementation Roadmap & Engineering Strategy
Version 1.0 candidate | Status: proposed, not approved | 16 November 2026

Scope: LFS-based Linux desktop, AI-native services, developer tooling, future hardware support.

This is an engineering plan, not evidence that the operating system or its features have been implemented.




                                                  NEO-OS • Draft for technical review | 16 November 2026 | 1


Document control
 Field                                                    Value

                                                          Candidate execution plan; not proof of
 Status
                                                          implementation
                                                          LFS systemd stable + BLFS; pin exact revisions at build
 Starting reference
                                                          kickoff
                                                          Two concurrent prototypes, then integration, then
 Delivery approach
                                                          ecosystem/release hardening
 Initial execution model                                  Solo-capable, role assignments deferred
                                                          Indicative durations; dependencies and evidence
 Calendar
                                                          govern advancement




1. Strategy and workstream model
Run Track A (NEO Desktop interactive prototype) on an existing Linux host while Track B (NEO Core bootable LFS
image) develops in an isolated build environment. Integrate only after both achieve independent exit gates.
Subsequent feature development must follow distribution, permissions and update dependencies.

 Track                                 Scope                                    First demonstration

                                       Qt/QML UI, orbital dock, Matrix          Working launcher and shell on
 A Desktop
                                       terminal, settings                       host Linux
 B Core                                LFS image, kernel, boot, systemd         QEMU boot and safe shutdown
                                       Build recipes, package metadata,         Repeatable install and package
 C Distribution
                                       updates, recovery                        ownership
 D Developer                           Toolchain profiles and workspaces        Build and debug reference project
                                       Model gateways, consent and              Read-only AI tools and denied-
 E AI
                                       capability broker                        action tests
 F Ecosystem                           Market, compatibility, phone link        Private publisher test install
                                       Serial/USB, cross-compile, selected
 G Hardware                                                                     Supported test board workflow
                                       board




2. Roadmap phases at a glance
 Phase                       Work package                 Illustrative effort             Gate evidence

                                                                                          Docs, ADRs, repo, CI,
 0                           Architecture & setup         2–4 weeks
                                                                                          hardware inventory
                                                                                          Orbital dock and Matrix
 1                           Interactive desktop POC      4–8 weeks
                                                                                          CLI on host Linux
                                                                                          Console boot inside
 2                           LFS core first boot          4–10 weeks
                                                                                          QEMU
                             Package/build                                                Package registry,
 3                                                        6–12 weeks
                             infrastructure                                               verification and recipes
 4                           Graphical integration        2–4 months                      NEO Desktop on NEO

                                                    NEO-OS • Draft for technical review | 16 November 2026 | 2


                                                                                         Core
                                                                                         Daily-use desktop and
    5                              Developer workstation       2–4 months
                                                                                         toolchains
                                                                                         Permissioned AI and
    6                              AI-native services          2–4 months
                                                                                         audit
                                                                                         Private
    7                              NEO Market                  3–6 months                publish/install/test
                                                                                         workflow
                                                                                         Device pairing, network
    8                              Phone, Guard, hardware      3–6 months
                                                                                         profiles, serial tools
                                   Installer, updates, beta                              Recovery-tested beta
    9                                                          4–8 months
                                   hardening                                             images
                                                                                         Custom compositor,
    10                             Advanced research           Ongoing
                                                                                         gestures, ARM64



Durations overlap where dependencies allow. They are estimates for planning, not deadlines or commitments;
overall development to a supported stable release can take multiple years.


3. Detailed work packages and acceptance gates

Phase 0 — Architecture and engineering foundation
Implementation: Create PRD, roadmap, threat model, 10 initial ADRs, service/API draft, module map,
source/license policy, design tokens, project repository, AGENT.md, baseline CI and hardware inventory.

Exit criteria:

        PRD and ADRs reviewed; decision statuses recorded
        Clean checkout passes lint/test bootstrap
        Host CPU/RAM/storage/virtualization measured
        Unresolved decisions tracked as issues


Phase 1 — NEO Desktop proof of concept
Implementation: Create reusable Qt/QML theme tokens, wallpaper component, top bar, workspace UI, orbital
launcher, simple applications API, persistence, Matrix-like functional terminal and accessibility defaults.

Exit criteria:

        Launch a real host application from orbit
        Pin and unpin app persists after restart
        Matrix CLI runs shell commands, recovers to GUI
        Reduced-motion mode and keyboard controls work


Phase 2 — LFS core
Implementation: Isolate build disk/VM; validate host packages; fetch pinned verified sources; cross-toolchain;
temporary tools; base LFS; configure systemd; kernel/GRUB; boot console in QEMU; document commands and
logs.

Exit criteria:


                                                         NEO-OS • Draft for technical review | 16 November 2026 | 3


   QEMU boots to login console
   Filesystem, processes, network (supported virtual NIC), shutdown pass
   Build logs and package version manifest archived
   Documented second build attempts same steps


Phase 3 — Distribution package foundation
Implementation: Research established backends, choose strategy with ADR; implement recipes/manifests; record
file ownership and dependencies; source verification; build sandboxing; package staging; conflict and unsafe
removal checks.

Exit criteria:

   Reinstall and uninstall selected package predictably
   Corrupt source/package rejected
   Package ownership can be queried
   Build artifact hashes and provenance stored


Phase 4 — Integrated graphical system
Implementation: Build BLFS dependencies; graphics/input/audio; choose compositor and session management; Qt
runtime and neo-shell launch; login, lock, wallpaper, window listing, workspace controls and settings persistence.

Exit criteria:

   Graphical session boots within QEMU/defined reference GPU
   Multiple programs open, focus, move and close
   Fallback tty survives shell failure
   Logout, login, suspend if supported, reboot work


Phase 5 — Developer workstation
Implementation: Browser, file manager and basic everyday apps; programming profiles; Git, build/test/debug
tools, container and VM options; configuration UI; system monitoring and diagnostics.

Exit criteria:

   Sample Go, Rust and web projects build/test
   GUI user can browse and manipulate files
   Developer profile install/remove verified
   Resource baseline reported on supported 8 GB test machine


Phase 6 — AI platform
Implementation: Provider adapters; optional local inference; context limits; AI desktop panel; read-only
diagnostic tools; permission broker; approval and audit; prompt injection and secret-handling test suite.

Exit criteria:

   AI optional; desktop works with provider offline
   Read-only diagnostics work
   Denied dangerous action cannot modify system
   Approved action has identity, scope and audit trace




                                                   NEO-OS • Draft for technical review | 16 November 2026 | 4


Phase 7 — Market and compatibility
Implementation: Catalog and metadata; package signing; publisher portal; private channels; app install
integration; tested Wine/Proton and selected Android runtime where feasible; compatibility labels.

Exit criteria:

   Private app upload/install/upgrade/remove passes
   Untrusted package rejected
   Compatibility cards truthfully show runtime constraints
   Publisher identity and release data recorded


Phase 8 — Devices, networking and hardware
Implementation: Android/other supported companion pairing; notification/file sync; firewall modes; network
monitor; USB/serial console; cross toolchains; device permissions; documented board tests.

Exit criteria:

   Revocation blocks future device access
   Offline/restricted network profile tests pass
   Authorized file transfer completes
   Selected USB/serial workflow demonstrated


Phase 9 — Beta release engineering
Implementation: Installer and image pipeline, signed repository and artifacts, update/recovery tests,
documentation, accessibility review, defined hardware compatibility suite, patch response process.

Exit criteria:

   Fresh VM install passes
   Power loss/interrupted update simulated and recovered
   No release-blocking security bugs
   Hardware matrix and known issues published


Phase 10 — Research
Implementation: Prototype compositor, 3D hand gestures, spatial file transfer, ARM64 images, local AI
acceleration; gate experimental integrations behind feature flags.

Exit criteria:

   Separate feasibility reports and measurable success criteria
   Experimental features cannot compromise stable boot
   Board/image support only after device-specific QA


4. Critical path and parallel scheduling
   Core sequence: Architecture → LFS boot → build/package provenance → graphical integration →
    update/recovery → supported release.
   Desktop proof of concept can start immediately and parallelize with LFS; production compositor integration
    waits for graphical stack validation.
   AI front-end can be mocked early; privileged tool interface must wait until service/policy model exists.
   NEO Market design may start early; actual public store deployment waits for install/signature/update
    architecture.

                                                    NEO-OS • Draft for technical review | 16 November 2026 | 5


        Hardware tools can integrate with desktop as apps; separate ARM64 OS support is a later cross-architecture
         build project.


5. Engineering backlog: first 12 issues
    ID                                     Epic/issue                            Acceptance or output

                                                                                 Clean clone; architecture map and
    NEO-001                                Project scaffold, README, AGENT
                                                                                 status
                                           Hardware discovery and risk           Record OS, CPU, RAM, free disk and
    NEO-002
                                           baseline                              virtualization
                                                                                 Decision, options, rationale, status,
    NEO-003                                ADR-001 through ADR-010
                                                                                 owner TBD
                                                                                 Dark/classical theme and reduced-
    NEO-004                                Qt/QML visual token package
                                                                                 motion toggle
                                                                                 Pin/launch/focus and keyboard
    NEO-005                                Orbital dock proof of concept
                                                                                 interaction
    NEO-006                                Matrix CLI functional prototype       Working PTY and GUI quick-switch
                                           LFS source acquisition and            Pinned source manifest with
    NEO-007
                                           verification                          checksums
                                           Isolated QEMU LFS build               Image, build logs, destroy/recreate
    NEO-008
                                           environment                           instructions
                                                                                 Console login,
    NEO-009                                First-boot smoke test
                                                                                 file/process/network/shutdown
                                                                                 ADR comparing established and
    NEO-010                                Package strategy evaluation
                                                                                 custom options
                                                                                 Permissioned D-Bus service
    NEO-011                                IPC/security API draft
                                                                                 contracts
                                                                                 Lint, unit tests, docs checks, build
    NEO-012                                CI smoke-test workflow
                                                                                 metadata




6. Architecture Decision Records (ADR) register
    ADR                                    Proposed decision                     Validation needed

    001                                    LFS + BLFS systemd base               Version and upstream patch policy
                                                                                 Reference CPU and firmware
    002                                    x86-64 first, ARM64 later
                                                                                 strategy
    003                                    Rust-first new system daemons         Qt/C++ boundary and FFI
                                           Qt/QML desktop on existing            Compositor performance and
    004
                                           Wayland compositor                    integrations
                                                                                 Auth, schemas and privilege
    005                                    D-Bus for local service IPC
                                                                                 boundaries
                                           Pinned sources and package
    006                                                                          Reproducibility test approach
                                           provenance
    007                                    Evaluate mature package backend       Repository and dependency model


                                                        NEO-OS • Draft for technical review | 16 November 2026 | 6


                                        first
                                        Signed updates and recovery
 008                                                                          Atomicity and snapshot feasibility
                                        required
                                        AI inference isolated from
 009                                                                          Tool-policy threat model
                                        privilege broker
 010                                    QEMU-first before physical install    GPU/VM test matrix




7. API/service contracts: initial outline
 Contract                               Methods / events (illustrative)       Required checks

                                        GetTheme, SetTheme, GetDock,          Session user and schema
 neo.settings.v1
                                        SetDock                               validation
                                                                              Desktop ID validation,
 neo.launcher.v1                        ListApps, LaunchApp, ActivateApp
                                                                              environment sanitation
 neo.ai.v1                              ListModels, Query, RequestTool        Rate limits, secret isolation
                                                                              Caller authorization, capability
 neo.permission.v1                      RequestGrant, RevokeGrant, Audit
                                                                              scoping
 neo.update.v1                          Check, Stage, Apply, Rollback         Signed metadata, privilege, consent
                                        Search, FetchMetadata,                Repository trust and signature
 neo.market.v1
                                        RequestInstall                        checks
 neo.connect.v1                         Pair, Revoke, SendFile                Mutual device authentication
                                                                              Policy authentication, audit,
 neo.guard.v1                           ReadPolicy, RequestChange
                                                                              rollback




8. Package/build/update architecture evaluation
A source-first distribution still needs package ownership and dependency management. Evaluate established
approaches before creating a novel package manager. For the prototype, use version-pinned LFS/BLFS build
manifests; only ship a public update mechanism after authentication, test and recovery gates.

1.   Define release manifest containing upstream package name/version, source URL, hashes, patches, license,
     build flags and dependencies.
2.   Build in controlled environments with logs and output file manifests; assess sandboxing and determinism.
3.   Select a package strategy after comparing integration complexity, security and rollback support.
4.   Separate trusted package sources from arbitrary external repositories; authenticate metadata and signatures.
5.   Stage updates in a tested environment, preserve known-good boot route, and simulate interrupted updates.
6.   Publish verified OS images, checksums, signed release metadata and known-issue notes.


9. GUI engineering plan
 Component                              First implementation                  Later expansion

                                                                              3D scenes, seasonal and dynamic
 Background                             Static wallpaper, color overlays
                                                                              themes
 Dock                                   Qt floating application with          Integrated shell and advanced


                                                   NEO-OS • Draft for technical review | 16 November 2026 | 7


                                          launcher integration                    animation
                                                                                  System tray and accessibility
 Top bar                                  Workspaces + status + clock
                                                                                  integrations
                                                                                  Custom rules and possibly
 Windows                                  Host compositor lifecycle APIs
                                                                                  compositor
                                                                                  TUI dashboard, natural-language
 Matrix CLI                               Real PTY inside themed terminal
                                                                                  command bridge
                                          Theme, dock position, reduced
 Settings                                                                         Full control center
                                          motion
                                          UI stub + unprivileged query            Policy tool broker and context
 NEO AI
                                          service                                 permissions




10. Testing and QA matrix
 Test class                               Examples                                Owner/automation

                                          Dock layout math, settings schema,
 Unit                                                                             CI per module
                                          package metadata
                                          Launch app via D-Bus, update
 Integration                                                                      CI + VM
                                          staging, permission brokerage
                                          VM console login, display login,
 Boot                                                                             QEMU smoke tests
                                          reboot/shutdown
                                          Package tamper, tool denial, secret
 Security                                                                         Security regression suite
                                          leakage, device revocation
                                          Idle RAM/CPU, frame pacing, app-
 Performance                                                                      Baseline profiling
                                          launch latency
                                          Keyboard focus, reduced motion,
 Accessibility                                                                    Automated + manual
                                          high contrast, scaling
                                          Graphics, Wi-Fi, audio, USB on          Physical QA before supported
 Hardware
                                          reference machines                      release
                                          Interrupted update, broken
 Recovery                                                                         VM fault simulation
                                          graphical session, backup restore




11. Engineering workflow and repository structure
Proposed monorepo: docs/{PRD,ROADMAP,ARCHITECTURE,DESIGN_SYSTEM,SECURITY,ADR};
build/{lfs,blfs,recipes,manifests}; kernel/{configs,patches}; core/{services,permissions,updates};
desktop/{shell,orbital-dock,matrix-cli,control-center,assets}; ai/; developer/; hardware/; app-store/; installer/; tests/;
.github/workflows/.

Branch and review: main protected by CI; feature branches by subsystem; each PR includes requirement/issue ID,
architecture impact, tests and docs update. AGENT.md is a living handoff with last verified build, blockers,
commands and next tasks. Do not mark completed from implementation claims alone.




                                                      NEO-OS • Draft for technical review | 16 November 2026 | 8


12. Roles, capacity and planning assumptions
No team members or responsibilities have been assigned. For a solo implementation, prioritize one core engineer
and separate issue owners only when additional contributors are confirmed. Engineering estimates depend on
weekly time, host machine, access to test hardware, and external collaborators; do not treat them as committed
delivery dates.


13. Release policy and quality gates
     Developer Preview: VM demonstration and documented limits; not recommended for daily critical use.
     Alpha: reproducible build pipeline and core desktop workflows; expected defects documented.
     Beta: installer, authenticated update and recovery tests, privacy/legal review, issue intake.
     Release Candidate: no unresolved release-blocking safety/security defects; supported hardware matrix and
      rollback plan.
     Stable: sustained maintenance capacity, patch response, installation/update recovery evidence and user
      support plan.


14. Immediate next actions
7.    Confirm host operating system, CPU, memory, available storage and virtualization hardware capability.
8.    Create the monorepo and add PRD, roadmap, security baseline, design tokens and AGENT.md.
9.    Draft ADR-001 to ADR-010 as proposed decisions, record open trade-offs.
10. Produce functional Qt/QML orbital launcher and Matrix terminal proof of concept on existing Linux.
11. In parallel, establish isolated QEMU storage and verify LFS host toolchain requirements.
12. Complete first LFS console boot and save logs, commands and image hashes.
13. Evaluate package strategy and define package manifests before graphical system integration.


15. Risks, dependencies and decision gates
    Dependency / risk                                         Gate / response

                                                              Measure actual host; adjust VM and compiler
    Insufficient disk or RAM
                                                              concurrency
                                                              Pin LFS 13.1 candidate or validated release at actual
    LFS stable version may change
                                                              kickoff
                                                              Define execution runtime per app and supported
    App-store compatibility complexity
                                                              matrix
    Qt graphics capability                                    Use low-effects mode and defined GPU test targets
                                                              No privileged execution before policy API and test
    AI tool overreach
                                                              suite
                                                              No public install until verified recovery
    Update safety
                                                              demonstration




                                                      NEO-OS • Draft for technical review | 16 November 2026 | 9