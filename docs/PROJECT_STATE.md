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

## Phase 1 / Track A — Desktop Preview 0.2 source iteration (2026-11-16)
- Replaced the large decorative center rings with subtle low-contrast background accents and refined the orbital dock layout.
- Added a Qt icon image provider that reads icon names/paths from installed .desktop entries; UI falls back to initials when no image is found.
- Added search/filter, Open and Pin controls to the installed-app panel; preserved app launch and saved pins.
- Updated desktop README and source-contract tests to reflect new UI/backend.
- Verified the updated files exist in GitHub and inspected source for required QML/backend/test identifiers; these are **static source checks only**, not a compiled GUI run.
- **0.2 Qt compile: NOT RUN**; **0.2 UI launch/interaction: NOT VERIFIED**. Previous 0.1 preview successfully launched on user's Ubuntu desktop, per screenshot.

### Next validation
1. User runs `git pull --ff-only origin master`, CMake build and preview executable on Ubuntu.
2. Verify real icons, opening installed applications, pin/unpin persistence, searchable app list and dock expansion.
3. Collect compiler/QML errors or screenshot and fix if necessary.
4. Add genuine keyboard focus handling and proper terminal session integration after successful runtime validation.

## Engineering workflow governance (Issue #1)
- Proposed process: tracked GitHub issues, isolated branches, PRs, review/checks, merge and issue closure for every change; explain and teach every implementation.
- See `docs/agent/WORKFLOW.md` for the exact lifecycle and required learning handoff.
- This policy is documentation/governance only; it does not establish GUI 0.2 runtime verification or LFS boot success.

## Issue #3 — Keyboard interaction hardening (PR pending)
- Feature branch `feat/3-keyboard-orbital-dock` changes the Qt/QML UI to support Ctrl+Space (dock), Ctrl+K (app search) and Escape (dismiss), plus dock-center focus styling.
- CI Ubuntu package list and Python static source checks updated; docs and agent handoff included.
- **Build/CI/manual tests: NOT VERIFIED for this branch.** Source edits alone do not prove keyboard behavior.
- Next: review PR, inspect CI; run application locally and report focus/keyboard behavior before accepting/merging.

### User-provided visual validation — 2026-11-16 18:10
- Two screenshots show the NEO Desktop v0.2 preview running on Ubuntu, the revised real application icons, the installed-app panel with Search/Open/Pin, and a gold highlight around the focused orbital dock center.
- A separate Ubuntu terminal window is visible, and the preview reports "Matrix terminal launch requested"; execution of commands inside this terminal is not established from the screenshots.
- Screenshots provide evidence for window rendering, opened app panel and focus styling, **not** conclusive evidence that Ctrl+Space, Ctrl+K, Escape, app launch, pin persistence, or automated tests pass.
- The user also correctly explained QML reactive bindings: changing property state causes dependent UI properties to update automatically.
- **Outstanding before merge:** run and report the three shortcuts, dock center Enter/Space, a real app launch, pin persistence, and CI/build result (no recorded CI checks or PR reviews currently).

## Issue #3 — Final acceptance evidence (2026-11-16)
- **User-reported Ubuntu manual tests: 6/6 pass**: Ctrl+Space dock toggle; Ctrl+K app search focus; Escape dismiss; focused dock center Enter/Space; launch installed application; pinned app retained across restart.
- **GitHub Actions:** `NEO Desktop preview` run #14 (`43926266948`) concluded **success** for PR #4 head `6790733`, with source tests, Qt dependency installation, configure, compile, and binary upload steps all successful.
- **Independent review:** no reviewer submissions recorded at the time of this entry. A source inspection was performed in the assistant session; this is not independent approval.
- Functionality now has manual and CI evidence. No claim is made that this is a fully installed NEO-OS operating system or that broader accessibility testing is complete.
- Next: revalidate the final PR head after the documentation updates, merge if allowed by repository rules, verify Issue #3 closure, and begin a separately tracked next issue.

## Issue #5 — Embedded Matrix CLI PTY prototype (pending PR, 2026-11-16)
- Created Linux-only `MatrixPty` backend using `forkpty()`, `QSocketNotifier`, `waitpid`, bounded text output, and user-shell input; no privilege escalation.
- Added `MatrixTerminal.qml` overlay showing output, line input, Send, Ctrl+C, Stop/Start and external terminal fallback.
- Wired CMake, QML context and UI; documented limitations under ADR-011.
- Updated static source-contract checks and Ubuntu manual test instructions.
- **Status: source only. Qt compilation, runtime shell commands, PTY lifecycle and regression tests not yet verified.** Do not treat these as a completed Matrix CLI.
- Next: submit PR for CI and user manual tests, fix failures; evaluate maintained full terminal widget before production integration.

### Embedded PTY Ubuntu runtime screenshot evidence — 2026-11-16 19:29
- User supplied a screenshot showing **Matrix CLI • Linux PTY preview** embedded within the NEO Desktop window on Ubuntu.
- In-panel command/output pairs are visible: `pwd` → `/home/admin/neo-os`; `echo NEO-OS` → `NEO-OS`; `whoami` → `admin`; `uname -s` → `Linux`. The prompt returns following each command. These establish basic line-oriented shell input/output on the user's Linux host.
- GitHub Actions run #43931939690 passed static tests, Qt configure/compile, and artifact upload; no independent GitHub PR review is recorded.
- **Still unverified:** Ctrl+C interrupting `sleep 20`, Stop/Start behavior, shell process cleanup, close/reopen, and dock regressions on this feature branch. Screenshot alone cannot establish these.
- **Decision:** PR #6 and Issue #5 remain open until the remaining acceptance tests are evidenced and reviewed. The panel remains a prototype, not a complete VT terminal emulator.

### User final interactive test report — 2026-11-16 19:45
The user reported **PASS** for each of four Ubuntu functional checks:
1. `sleep 20` interrupted by embedded Ctrl+C.
2. Stop, Start, then `echo restart` succeeded.
3. Closing and reopening the Matrix CLI kept the desktop responsive.
4. Orbital dock and application launch regressions passed.

These results are self-reported manual tests, not independent automated PTY lifecycle testing. An earlier screenshot verified commands `pwd`, `echo NEO-OS`, `whoami`, and `uname -s` with their expected outputs.

### Automated and review gate check
- Latest branch documentation commit `886a0e7` has successful GitHub Actions run #43940033625 (completed/success). Earlier source commit `843446c` passed run #43931939690.
- At the latest inspection, zero GitHub PR reviews were submitted.
- **Open process lifecycle risk:** `MatrixPty::stop()` sends SIGHUP/SIGKILL to the immediate Bash PID and reaps it, but does not explicitly enumerate or terminate all foreground process groups/descendants. The user test of Stop/Start is not sufficient evidence of no orphaned foreground processes.
- **Open PR #6 and Issue #5 until cleanup behavior is validated and review requirements are resolved.** Do not claim production-quality terminal emulation.

### Targeted background-process cleanup test — 2026-11-16 19:55
- User ran `sleep 90 & echo $!` in Matrix CLI, stopped the shell and checked the resulting PID **77343** from the Ubuntu host.
- Observed `ps -p 77343 -o pid,stat,cmd` output: only the header `PID STAT CMD`, with no matching process row.
- **Result: PASS for this particular background process** — it was not present at inspection time. This is user-reported observational evidence, not a comprehensive verification of child process groups or all workloads.
- GitHub Actions run #43942913609 succeeded on branch commit `dbc27a0`. No independent reviewer approval has been recorded.
- Keep the incomplete descendant/process-group cleanup guarantee as an explicit limitation; require further review before claiming comprehensive lifecycle safety or stable terminal-emulator readiness.

### PR #6 follow-up hardening — 2026-11-16
- Updated `MatrixPty::stop()` to send SIGHUP to the foreground PTY job group (when separate) and to the shell process group; improved `waitpid` handling for an already-reaped child.
- Added `MatrixPtySmoke.cpp`, a headless Qt Core + actual Linux PTY test of Bash output and Stop; registered it through CTest and GitHub Actions.
- The integration test requires a standalone output line to avoid mistaking shell command echo for successful execution.
- **Status:** New code and tests committed on PR #6 feature branch; new CI run and post-change Ubuntu runtime regression results are pending. Previously reported manual tests apply to the earlier implementation.
- **Residual risk:** detached/disowned jobs may outlive the terminal; no general descendant supervisor has been implemented. Independent review remains outstanding.

### Post-hardening Ubuntu regression result — 2026-11-16 20:25
- User reports the updated desktop and Matrix CLI are "working fine" following the latest process-group cleanup changes.
- This is **general user-reported success**, not an itemized retest transcript for each behavior; the earlier 4/4 interaction results apply to the pre-hardening version.
- GitHub Actions run #43945489673 completed successfully for commit `ae7314b`, including live PTY integration smoke test, source tests, Qt build and artifact upload.
- A targeted earlier background PID test passed. Detached descendant cleanup and full terminal emulation remain limitations.
- **Independent PR review not yet recorded**. Keep PR #6 open pending required review; do not misrepresent generic "working fine" as full formal approval.

## Issue #9 — Celestial Desktop visual refinement (stacked PR, 2026-11-16)
- Reference: user-provided futuristic classical-fantasy NEO-OS screenshots, newest showing workspace bar, left rail, glowing planetary/castle backdrop, central orbital launcher, AI/store/device/status glass cards and bottom dock.
- On `feat/9-celestial-desktop-refinement`, rewrote `Main.qml` with glass UI composition, center orbit, bottom pinned dock, preview-only widgets, generated celestial Canvas fallback and persistent local-image wallpaper selection.
- C++ `DesktopBackend` now persists a verified local readable wallpaper URL and cyan/violet accent choice via QSettings.
- Existing real installed app enumeration, icon provider, launches and pin persistence are preserved, as is experimental embedded Matrix CLI from underlying PR #6.
- **Do not misrepresent** visual-only services (AI, app market, devices, workspaces, telemetry) as actually integrated; they are clearly labeled previews.
- **Validation pending**: CI build/QML parsing, live Ubuntu side-by-side screenshots, wallpaper persistence, 1024×640 responsiveness, keyboard/Matrix regression and independent PR review.
- This is a **stacked** branch/PR over unmerged PR #6. Need PR #6 merged first, then retarget this change to master and rerun CI before merge.

### Issue #9 — Wallpaper asset pack & visual refinement
- Four user-selected wallpapers have been packaged for local download as `NEO-OS_Celestial_Wallpapers_v0.3.zip`. The zip is generated in conversation files, **not stored in GitHub**; user must extract and run the checked-in installer script.
- The new `desktop/shell/install-wallpapers.sh` installs image assets to `$XDG_DATA_HOME/neo-os/wallpapers` or `$HOME/.local/share/neo-os/wallpapers` without elevated privileges.
- C++ scans installed local image assets; first sorted image becomes default if no valid saved wallpaper exists; saves wallpaper selection, neon accent and dim strength.
- QML Settings now presents actual thumbnails, adjustable wallpaper dim/contrast and theme controls; orbital ring glow and bottom dock are refined.
- **Pending:** CI verification on latest commit, user Ubuntu screenshots, image pack installation, responsive comparison and independently reviewed PR #10. PR #10 remains stacked on open Matrix PR #6.

## Issue #9 — Native file chooser and gallery correction (2026-11-17)
- User supplied Ubuntu screenshots showing a functioning native UI but **no installed wallpaper thumbnails** and requested an open-and-select image picker rather than path typing.
- Root cause: the generated ZIP was a separate conversation artifact and had not been installed to the XDG wallpaper directory. The repository does not contain those binary images.
- Proposed fix on `feat/9-celestial-desktop-refinement`: `QtQuick.Dialogs FileDialog` for selecting local images; C++ `importWallpaper` validates and copies the file to the private XDG wallpaper gallery; `refreshWallpapers` and `wallpaperThemesChanged` refresh thumbnails dynamically. An empty-state explanation is shown when no gallery assets exist.
- Qt 6 QML dialog module added to CI dependencies, plus new source-regression assertions and usage instructions.
- **Status:** source committed; current CI and Ubuntu user testing pending. Independent PR review pending. Full visual reference fidelity remains unverified.
- Visual refinement is mostly possible on the Ubuntu preview; an independent LFS image is required for true boot, compositor, login/session and OS service integration, not for graphical styling or wallpaper selection.

## Issue #9 — Second Ubuntu wallpaper failure and remediation (2026-11-17)
- User screenshot: native Choose image button now visible, but choosing an image does not change wallpaper and gallery still has no entries.
- Identified gaps in source: no bundled default gallery images; silent boolean failure on QImageReader checks and no clear WebP plugin dependency. These are plausible explanations; precise local failure awaits visible runtime diagnostics.
- Implemented four procedurally generated `QPainter` PNG presets seeded in XDG user wallpaper library on first launch. They are distinct from four photoreal wallpapers the user generated earlier (those are in a separate ZIP not committed as assets).
- Updated import to validate reader errors, bound image size and convert selected image into PNG in NEO gallery; error displayed in Appearance and logged. Added `qt6-image-formats-plugins` to GitHub Actions dependencies, and docs for Ubuntu install.
- **Status:** source committed, CI and Ubuntu functional testing pending. Do not mark issue #9 accepted without actual image import/gallery screenshots. PR #10 still stacked on unmerged PR #6 and requires review.
