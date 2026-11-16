# NEO-OS Agent Test Policy

1. Never claim tests passed unless executed. Report `not run` precisely.
2. For source or build changes, run syntax, static checks, unit tests and appropriate integration tests.
3. For LFS changes, use isolated disposable disks and log checksums, build environment, QEMU boot command and shutdown evidence.
4. For desktop changes, exercise actual application launches, keyboard access, reduced-motion behavior, scaling and session safety.
5. For system services, test authenticated/unauthorized callers, invalid input, privilege boundaries and negative cases.
6. For AI tools, test denial, consent, prompt-injection resistance and failure isolation.
7. For installer/update changes, test VM install, interrupted update, and recovery before host hardware.
8. Record commands, exit codes, artifacts, and limitations in `docs/PROJECT_STATE.md`.
