# NEO-OS Build, Packaging, Updates and Recovery Strategy — Draft
**Status:** Proposed, not an operational package manager.

## Stage 1: LFS learning/reference build
Use version-pinned LFS systemd and BLFS references and check errata at build kickoff. Record host info, compiler/tool versions, upstream source URLs, hashes, patches, licenses, environment, build logs and kernel config. Isolate build on disposable virtual disk; never modify host boot sectors or partitions. First gate: repeatable console boot in QEMU.

## Stage 2: Reproducible package system research
LFS does not provide binary package management. Evaluate a mature package manager (e.g. pacman, xbps, or another appropriately licensed and maintainable backend) against implementing custom metadata tooling. Decide after a prototype. Test file ownership, dependencies, transaction safety, signature verification, upgrades and removal before committing.

Minimal proposed package metadata: `id`, `version`, `release`, `arch`, `source_url`, `sha256`, `license`, `build_dependencies`, `run_dependencies`, `install_manifest`, `provides`, `conflicts`, `signature`.

## Stage 3: Update model
- Publish signed repository metadata and package artifacts; protect private signing keys outside CI logs.
- Stage system changes, verify checksums/signatures and perform transactional operations where supported.
- Maintain a recovery boot path and test rollback for failed updates.
- Choose filesystem and snapshot/atomic-update strategy through an ADR; do not promise snapshots on unsupported filesystems.
- Define response plan for upstream kernel, package, and security advisories.

## Stage 4: Release engineering
- Build traceability: source revision, tool versions, hashes, reproducibility evidence, SBOM, build logs.
- CI validates manifests, recipe syntax, checksums, dependency edges, static tests and VM smoke tests.
- Release artifacts include exact hardware compatibility claims, tested install/update paths, risks and known limitations.
- Keep developer preview separate from supported stable builds.

## Critical acceptance tests
1. A clean, isolated build can reconstruct specified package versions.
2. Package owner is queryable for installed files.
3. Corrupt or unsigned artifacts are rejected.
4. Interrupted update can be recovered on a disposable VM.
5. No unreviewed destructive disk changes or in-place host modifications.
6. A security-update process exists before any public supported release.

## Open decisions
Package manager, bootloader, filesystem, snapshot architecture, image generator, package signing key management, vulnerability tracking and update channels remain open ADRs.
