# NEO-OS Local Service Contracts — Draft v0.1
**Status:** Proposed only. Interfaces below are design identifiers, not implemented or stable APIs.

## Naming and versioning
D-Bus namespace: `org.neoos.*`; major interface version suffix `.v1` until schema rules are approved. Contract changes require ADR and consumer tests. Prefer typed requests and bounded responses. Never log secrets, tokens or private file content.

| Service / interface | Proposed methods | Caller | Privilege / consent |
|---|---|---|---|
| `org.neoos.Settings.v1` | `Get(key)`, `Set(key,value)`, `Subscribe()` | Current user shell/settings | Own user only; validate keys and values |
| `org.neoos.AppIndex.v1` | `List()`, `Search(query)`, `Launch(app_id)` | Current user | Launch only recognized installed desktop entries; no arbitrary command string |
| `org.neoos.Diagnostics.v1` | `GetResourceSummary()`, `GetServiceStatus(id)` | Current user | Read-only, redact data from other users |
| `org.neoos.AIGateway.v1` | `Ask(request)`, `ProposeAction(action)`, `Cancel(id)` | Local AI UI | No privilege; structured action proposals |
| `org.neoos.PolicyBroker.v1` | `Authorize(action,scope,nonce)`, `ExecuteApproved(id)` | Authenticated user service | Root-scoped broker; independent authentication and policy |
| `org.neoos.DeviceLink.v1` | `ListPaired()`, `Pair(request)`, `TransferFile(id,target)`, `Revoke(id)` | Current user | Explicit pairing and transfer approval |
| `org.neoos.Update.v1` | `Check()`, `Stage(target)`, `Apply(approved_id)`, `Status()` | Current user + restricted updater | Signed metadata; rollback gate |

## Request requirements
- Every modifying request has an explicit actor, action, scope, timestamp, unique id, and controlled expiration.
- Broker must derive peer identity from OS credentials, not self-reported message fields.
- Network, filesystem, device and package scopes are restrictive allowlists.
- Apply idempotency or deduplication to irreversible actions.
- Denials, timeouts, cancellations and service crashes must fail closed.
- Surface concise user-facing explanations for denied requests.

## Example conceptual authorization
```json
{
  "request_id": "example-only",
  "actor": "current-session-user",
  "action": "network.set_profile",
  "scope": {"profile": "restricted"},
  "requires_confirmation": true
}
```

No root access is delegated to the model. A tool proposal is not a privileged command. Network privacy profiles cannot claim anonymity.

## Validation tests to implement
1. Reject cross-user requests, malformed parameters and unrecognized action identifiers.
2. Reject replayed or expired tokens; require independent user authorization.
3. Deny AI filesystem writes or network changes without approved scope.
4. Service failure does not break the graphical session.
5. Verify model-provider errors, offline mode, rate limits and safe cancellation.
