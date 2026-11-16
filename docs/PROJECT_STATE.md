# NEO-OS — Project State

Updated: 2026-11-16

## Verified GitHub documentation
- PRD and roadmap candidate exports: `docs/PRD.md`, `docs/ROADMAP.md`.
- System architecture, service contracts, build/update strategy, security and GUI design system drafts.
- Ten proposed ADRs and agent instructions.

## Current implementation milestone
**Phase 1 / Track A — Native Desktop Proof of Concept initiated.**

### Committed source (GUI launch now confirmed by user screenshot)
- `desktop/shell/CMakeLists.txt` — Qt 6 Quick/QML build target.
- `desktop/shell/main.cpp` — installed .desktop entry enumeration; Gio-backed app launch; QSettings pin persistence; terminal launch.
- `desktop/shell/Main.qml` — native desktop preview with classical-neon visual treatment, left rail, app list, motion toggle and expandable orbital dock.
- `desktop/shell/README.md` — Linux setup, build/run and manual acceptance tests.
- `tests/test_desktop_source.py` — basic source-contract checks.
- `.github/workflows/desktop-preview.yml` — proposed GitHub Actions compile/test workflow.

### Evidence
- GitHub contents verified for all six files.
- Simple read-only source/string inspection checks passed (presence of Qt module, QML path, dock data, pin persistence and Gio launcher).
- **CMake/Qt compile: USER-REPORTED PASS** on Ubuntu 24.04 (CMake 3.28.3, Ninja 1.11.1, GCC 13.3.0), `[18/18] Linking CXX executable neo-desktop`. The assistant has not independently reproduced the build.
- **GitHub Actions result: NOT VERIFIED**. Workflow was committed but no passing run is established.
- **GUI launch: USER-SUPPLIED SCREENSHOT CONFIRMS SUCCESS** on 2026-11-16. Native NEO Desktop preview window visibly renders header, side rail, orbital dock with five app entries, NEO control panel and notification text `Terminal opened`. Runtime launch and QML resource loading are verified by visual evidence. Actual terminal window/commands, app launch, pin persistence, keyboard accessibility, reduced-motion behavior and CI remain **NOT TESTED**. The displayed window is an application within Ubuntu, not a NEO-OS boot.
- No source was installed as the host shell or as NEO-OS.

## Not yet verified
- Bootable NEO-OS LFS/QEMU console or GUI.
- Runtime QML launch verified once by user screenshot; full interaction correctness and reliability not verified.
- Package manager, updater, installer, AI daemon, app store, or system integration.
- Host hardware/virtualization inventory and ADR approvals.

## Next work
1. Test click orbital dock center (expand), launch a known app, pin/unpin and restart to check persistence; test Matrix CLI executes commands.
2. Fix runtime interaction issues; verify keyboard access, reduced motion, scaling, QML warnings, and CI compile result.
3. Replace placeholder icons with theme-aware app icons; add keyboard access, focus handling, and real active-window indicators where permitted.
4. Validate host hardware and begin isolated LFS build.
5. Review/approve architecture decision records and source docs.

## Safety
Prototype runs as a normal application window. It must never silently replace host desktop services or modify bootloaders or physical partitions.

## Handoff requirements
Every next milestone must record actual tests, warnings, changed paths, branch/commits and remaining tasks; never claim a UI works solely from source code.
