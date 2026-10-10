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
