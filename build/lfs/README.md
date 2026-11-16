# NEO Core — First LFS host inventory

This folder begins the **NEO Core** workstream. The inventory script is **read-only**. It does not install programs, create images, modify partitions, load kernel modules or require root access.

## Run on your Ubuntu development computer

From the NEO-OS repository:

```bash
git fetch origin
git switch -c build/7-lfs-host-readiness --track origin/build/7-lfs-host-readiness
bash -n build/lfs/host-audit.sh
bash build/lfs/host-audit.sh "$HOME"
```

Use `git switch build/7-lfs-host-readiness` if the branch is already checked out. Never overwrite your uncommitted work.

Pass the **existing directory** you intend to build in (e.g. `"$HOME"`) as the first argument. The report includes the filesystem's available space, not a guarantee that it is adequate for the LFS build.

### What the audit checks
- OS release, kernel and processor architecture
- Logical CPU count and available/total RAM display
- Current disk free space at the selected directory
- Presence of build tools (not whether their exact version satisfies LFS)
- Select tool versions
- QEMU tools and /dev/kvm access

### What it does NOT check
- Full LFS host prerequisites, version minimums, symbolic link correctness, compiler capabilities or filesystem semantics
- Build safety of any target filesystem or enough RAM/disk for actual compilation
- Secure Boot, firmware, GPU compatibility, bootloader or driver readiness
- Quality of the physical hardware or availability of LFS packages

Check the precise requirements and errata in the **version-pinned official Linux From Scratch book** before performing any build. This is a preliminary inspection, not a readiness certification.

### Next safe milestone
Review the output, check LFS host validation requirements, decide on QEMU virtual disk and build location, and make an ADR for the isolation strategy. No partition, mount or bootloader commands should be run against the main computer without a separate explicit, reviewed plan.
