# P08 actual generic-host activation component — 2026-10-12

The maintained fixture joins the real Static runtime coordinator through the
existing SignalAnalyzerPresetHostInstance and MVPHostActivationController. It
passes48 positive assertions and four intended ownership/lifetime controls on
the approved Swift6.4 compiler. Independent review is pending; this is a bounded
component result, not P08 exit or complete host/application validation.

## Implementation and contract boundary

Three positive source files live in SPEC015/RuntimeDerived:
ActivationJoinOwner.swift, ActivationJoinReport.swift and ActivationJoinProbe.swift.
Compile them alongside the unchanged18 P07 RuntimeDerived files as RuntimeCycleProbe.
The entry point is package `p08ActivationJoin() -> Int`, currently returning48.
No production host/controller change or new host protocol was required.

The existing live-owner conformer retains supplied model/root/semantic/Canvas
scopes, geometry, interaction and scoped control without preconstructing the
pipeline, endpoint, binding or coordinator. Only constructRuntimeAndEndpoint,
called by host.activate, constructs those actual values. The retained Span comes
from callback-local InlineArray inside the innermost trusted supplying callback.
It survives the inert/active state transition; the retired state retains that
same fence after dropping scoped runtime values. Initializer overloads add no
stored state to P07 types and preserve their original signatures.

The report is a clearly named synthetic component sentinel using the actual
storage audit. It is not nine-stage validator evidence, a complete analyzer
assembly or a full validation-purity oracle. Non-runtime activation/teardown
adapters record controller ordering; the actual runtime opportunity, endpoint,
quiescence and storage-scope cleanup use real P07 implementations. The fixture
checks runtime release before the resetProfileStorage stage; actual supplied
backing remains owned by the surrounding callbacks and exits after the host.
This proves the component ordering, not platform-owner release implementations.

## Verification

Run1 compiled and executed successfully. Its48 checks cover initial valid/inert
state and opportunity refusal; single construction through activation; actual
accepted opportunity; repeat activation without construction; ordered teardown,
quiescence, report runtime-use invalidation and progress reset; idempotent second
teardown and post-teardown refusal. A second fresh profile fails immediately after
actual runtime construction, returns partial progress runtimeConstructed:true,
and verifies containment quiesces exactly once before ordinary idempotent teardown.

Run2 discovered a mechanical negative-oracle adaptation left from the raw owner:
quiesce is not a host method. All negatives now use host.teardown and explicitly
discard activation results. This was diagnostic narrowing, not a lifetime pass.
Run3 callback negative rejects the actual P08ActivationHost escaping all relevant
supplying callbacks, including explicit activationBacking lifetime. Run4 copy
negative reports owner consumed more than once (alongside callback errors).
Run5 identical callback test with constant marker[1] rejects the same escape.
Run6 local-profile return rejects both callbacks and, explicitly, the scoped access
to local profile at the return. Each negative has a reachable main; none executed.
The immortal return annotation in that negative is a deliberately rejected proof
obligation, never an unchecked extension used by positive implementation.

All6 commands, complete diagnostics, source snapshots and raw results are frozen.
The positive prints `P08 actual host activation assertions: 48` after the full
accepted opportunity trace. dependencies.json revalidates compiler/source/artifact
hashes of the fresh6.4 compiler-native-join graph; no6.3.2 module/object is reused.
The original macro executable remains a recorded separate host process. The graph
preserves Dynamic-profile flags while using the actual Static coordinator; no
Static-profile or target result is inferred.

The standard formatter completed; its pre-existing evidence-path issue briefly
formatted23 frozen snapshot files, which were restored byte-for-byte immediately.
Parent fixed that selector separately. Maintained new fixtures were explicitly
formatted with the approved6.4 formatter. No historical evidence change is part
of this step.

## Closure and remaining work

Closed at6/12 calls, one mechanical oracle repair, zero consecutive unproductive
failures. No source/production forwarding repair was needed. Parent owns checker
integration, normative/design links and broader fresh regression; independent
Strong review must precede blocker closure. Generic host containment is now
exercised, but full validation purity, application stages, finite counter,
four-profile/target routes, resource costs and P08 exit remain open.
