# P03 implementation progress — 2026-10-10

Input: `0516f9d0` (P02 declaration exit passed). Owner: SPEC-010 T10.1;
criteria: OS-RD-001–004 and unchanged OS regression requirements. P03 is in progress.

## Step 1 — identities and failure vocabulary

The host-owned owner namespace and each store's allocation namespace are
noncopyable checked UInt32 cursors. Both start at zero, issue UInt32.max once,
and remain exhausted without wrapping. They are independent of structural
registration/target generations. Production construction has no seeded reset;
internal fixture constructors exercise the final boundary. Host assembly must
retain its namespace across replacement assemblies.

ObservableStateError preserves raw values 0–11 and appends the six approved
cases at 12–17. AccessFailure mapping preserves invalid phase, stale identity
and indexed bounds distinctions. The focused failure bitset grows from UInt16
to UInt32 so all 18 cases participate. Existing Runtime/application normalizers
now cover those cases and select discovery versus replacement capacity scope.
Those integrated normalizers still await the P03/P07 consumer build.

Focused native validation:

```text
scripts/contracts/check-spec-010-model-identities.py --giftui-build .build/contracts/spec-006-rfc-014/bbb06b42e2159475-9yjt1mg6/macos-static
```

The command checks pinned compiler, P02 GiftUI source and artifact hashes before
reusing that core module. It compiles the current production identity/error
files, FailureCore and the focused ObservableState failure adapter, then runs
227 assertions: exact raw values/size, access mapping, independent issuance,
maximum/exhaustion, every pair in the 18-case precedence order and the new
condition/origin/scope/containment mappings. Result: zero failures. Commands and
logs are under `.build/rfc014-p03/identity/`.

This increment is not a backing lifetime, State binding, replacement, whole-module
or four-profile exit. Those P03 checks remain open. Formatting, governance and
`git diff --check` pass. No broad P10 gate or connected operation was run.

## Step 2 — bounded ownership and concrete backing

The existing Dynamic/Static model-storage files now own fixed typed model buffers
and the bounded ownership ledger. A shared scoped adapter in GiftUIObservableState
borrows those actual buffers throughout activation; no new target or migration
conditional is introduced. Tickets are noncopyable and nonescapable; keys remain
nonowning. The [design note](../../../../../docs/implementation-designs/spec-010-stable-model-ownership.md)
records the storage proof, independent claim/registration/pin lifetimes and the
remaining callback work.

The ledger adds 46 native assertions for bounded claims, registered versus
independently retained models, installed-empty capture entitlement, two-slot/four-
claim limits, shared frame pins, discovery exclusion, stale model/claim reuse,
replacement reservation guards, refusal, discard and commit. Native stride is
188 bytes; this is metadata, not complete profile memory or a linked RAM claim.
Fifteen additional assertions exercise both real backing factories with a
noncopyable model, actual destruction counts, detached retention, scoped reads,
reassembly-stale keys, Dynamic activation reentry, and the target probe on native.

The component driver passed with each recorded P02 core input:

- macOS Static: `.build/contracts/spec-006-rfc-014/bbb06b42e2159475-9yjt1mg6/macos-static`
- macOS Dynamic: `.build/contracts/spec-006-rfc-014/bbb06b42e2159475-6qul9t82/macos-dynamic`
- ARMv6 Dynamic: `.build/raspberry-pi/contracts/spec-006-rfc-014/bbb06b42e2159475-qu406pys/raspberry-pi-armv6`
- nRF Embedded Static: `.build/nrf52840/contracts/spec-006-rfc-014/bbb06b42e2159475-qqr5z94s/nrf52840-embedded`

Invoke `scripts/contracts/check-spec-010-model-identities.py --giftui-build <path>`.
The driver verifies unchanged core sources/artifacts and compiler bytes, then
reuses the exact target/SDK/feature/optimization recipe from that core receipt.
Current component logs/commands are under `.build/rfc014-p03/ownership/<profile>`
(native), `.build/raspberry-pi/rfc014-p03/ownership/<profile>` and
`.build/nrf52840/rfc014-p03/ownership/<profile>`.
Native results: 227 identity/error + 46 ledger + 15 actual-backing assertions,
zero failures. Cross profiles compile a concrete lifetime/retain/read/release
entry point and verify CPU/VFP attributes; no target execution is claimed.
All four reject escaping a ticket and overlapping access to Static backing.

This remains a component increment. The old State/reconciler/root-adapter callers
still require migration to these stores. Real attach/detach/report callbacks,
checked mutation, candidate publication, full guarded capture replacement and
teardown remain P03 work; neither full profile modules nor the P03 exit pass
is claimed from the selected-file component build.
