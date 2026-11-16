# NEO-OS Security Architecture — Initial Threat Model
**Status:** Proposed. Not a security audit or proof of protection.

## Assets
User documents, credentials, SSH keys, AI provider keys, developer project source, application packages, boot/system integrity, paired-device contents and network settings.

## Trust boundaries
1. Remote package publishers and arbitrary download content.
2. Third-party applications and untrusted developer project scripts.
3. AI model output, prompts, retrieved files and network content.
4. User graphical/session services versus root-owned services.
5. Paired device traffic and local network peers.
6. Installer/update tooling versus physical disks and boot environment.

## Controls
- Least privilege; narrow D-Bus APIs, OS peer identity checks, explicit authorization and denial tests.
- No direct AI root shell. Treat model/tool output as untrusted.
- Verify downloads and repository metadata; maintain vulnerability advisories and patch response.
- Sandboxing for untrusted apps and workloads where supported; desktop permission broker designed before public access.
- Never store API keys in the repository or logs; use appropriate secret storage.
- Firewall profiles default to deny unsolicited inbound connectivity where technically supported. Private Mode is not guaranteed anonymity; offline must genuinely disable network connections under tested conditions.
- Device pairing requires mutually authenticated consent and revocable trust.
- Build/update/installer operations initially confined to disposable VM disks; signed and tested recovery before real-device use.

## Required reviews
Threat model for AI agent execution, package/publisher supply chain, network policy profiles, local IPC, installer and signing infrastructure. Record abuse cases, exploit mitigations, residual risks and owner prior to feature approval.

## Test plan
Unprivileged access denied, replayed requests rejected, malicious package refused, poisoned AI prompt cannot gain more capabilities, lost update is recoverable, device pairing revocable, restricted/offline profiles verified.
