# Terminal result — proceed to implementation preparation

**F1–F3 supported within the registered scope. Architectural experimentation
ends here.** No architecture/Spec approval or production feasibility is implied.
[Registration](../../../docs/spikes/spike-074-final-access-ownership.md),
[ledger](ledger.json), [machine-readable result](result.json).

48/48 compiler/link/execute invocations, one/two repair rounds, 69.633 seconds
from first to last invocation (45-minute ceiling). No unexpected compiler failure;
the repair corrected one fixed-case coverage detail, not the design. Initial and
final Driver sources and all diagnostics are preserved in hashed snapshots.
The terminal marker refuses further trials; no successor allowance exists.

## F1 — typed module boundary

Six modules compile separately on native Dynamic/Static selections, ARMv6 Linux
and nRF Embedded: GiftUI contract, unchanged selected SignalAnalyzerDomain values,
ApplicationSchema, PortablePresentation, HostBridge, Driver. Native executables
link those objects. PortablePresentation imports GiftUI, Domain and schema only;
it has no Runtime or HostBridge import or target record layout.

CounterRoot, AnalyzerRoot and AnalyzerChild have compiler-inferred Body through
`some View<D>`; there is no explicit custom Body alias or method-generic read
parameter. Recursive render witnesses actually invoke the custom bodies and
nested child. A counter conditional and opaque helper exercise composition.
AnalyzerRead binds owner/generation once; CaptureRead performs checked indexing
and returns the actual Domain SignalTransition. Canvas holds only a typed key
and index and performs deferred reads under a fresh scoped context.

The eight negative builds reject only the intended diagnostic families: storing
FrameRead in an escaping struct, and mutating Owner before the last read through
its context. This is two controls on four configurations, not a universal proof
of safe Swift/application source lowering.

## F2 — guarded three-bank ownership

Both final native executions report **47 checks, zero failures**:
[Dynamic](43-macos-dynamic-run.log), [Static](46-macos-static-run.log).
These profile selections run the same bounded bridge, not the real Runtime
implementations. Assertions 0–46 in Driver's evaluation order cover:

| Assertions | Evidence |
| --- | --- |
| 0–1 | Counter inferred body, branch/helper composition, owned output after later mutation. |
| 2–4 | Metadata exhaustion; empty installed analyzer retains bank entitlement; candidate population refuses without changes. |
| 5–10 | Nested analyzer body, typed capture Canvas, replacement/write refusal during frame, indexed bounds and wrong-owner errors. |
| 11–14 | Independently retained old owner blocks replacement; old identity/attachment/data/dirty state and canaries survive. |
| 15–18 | Attach-time report failure preserves the old model and rolls back the fixture transaction. |
| 19–22 | Attach-time attempt to acquire another owner is refused under reservation. |
| 23–26 | Attach-time reentrant mutation is refused without modifying old bytes. |
| 27–32 | Successful transfer retires A, installs empty B, preserves old physical bytes but rejects stale A keys; later draw failure keeps B. |
| 33–38 | B fills all 404 records; old owned geometry remains stable; metadata slot reuse advances generation; source/admission canaries survive. |
| 39–40 | Oversized capture fails before data/dirty-state modification. |
| 41–44 | Attachment-generation refusal preserves old state and canaries. |
| 45–46 | Actual record stride is 16; counter scalar slot stride is 1. |

The one repair moved the candidate-population attempt before initial A
population, so assertions 2–4 test the **empty installed-model** entitlement.
There is still one model bank, with independent source/admission banks. The
fixture uses the unchanged production packed-record and capture-region source.
Successful transfer consumes the explicitly represented last old owner;
independent ownership is never revoked to make room.

This is a transaction model using real backing, not actual reconciler/observer
callback integration. Attach faults are explicit injections; production detach
hooks, invariant handling and complete ownership audits remain implementation
conformance obligations. Synthetic record timestamps test typed access/reuse,
not the acquisition horizon or snapshot-replay algorithm.

## F3 — concrete incremental storage

Target values come from emitted layout constants, not host-size extrapolation:
[ARMv6](pi-armv6-layouts.ll.txt), [nRF](nrf-embedded-layouts.ll.txt).
The unchanged layout-return function in Driver was emitted before the test-order
repair; its Trace type and all schema/bridge/layout declarations are identical
in the final build. Bridge IR uses the final, unchanged Bridge source. Input
hashes and the original Driver snapshot remain in trials 37–40.

| Live fixture storage | Native arm64 | ARMv6 / nRF |
| --- | ---: | ---: |
| Three capture banks, 3 × 404 × 16 | 19,392 | 19,392 |
| One analyzer descriptor, including bounded acquisition diagnostic and buffer descriptor | 136 | 124 |
| Two analyzer descriptors | 272 | 248 |
| Owner control, including backing descriptors and transaction counters | 72 | 44 |
| Two model keys | 24 | 24 |
| One staged Canvas key/index | 24 | 16 |
| **Descriptors + owner + two keys + one Canvas** | **392** | **332** |
| Counter scalar slot (independent of analyzer) | 1 | 1 |

The mechanism does not require another 6,464-byte bank. The target 292-byte
model/owner subtotal and 332-byte subtotal with keys/Canvas do not exhaust the
RFC's earlier proposed 1,024-byte model/control allowance, but that allowance is
not an approved new limit and still must cover real registrations/host tickets.
Keys and Canvas must be charged to their eventual actual pools, not counted
again here in a whole-image sum. Stack read facades, returned scalar values,
body trees, driver checks, alignment, compiler support and existing graph /
registration / framebuffer storage are not included in this subtotal.

[Object sizes](nrf-embedded-size.txt) are pre-link module observations, not an
additive firmware size or live RAM cost. Weak runtime support can be duplicated
between objects. [Undefined symbols](nrf-embedded-undefined.txt) include
`posix_memalign` and `free`; **zero heap is not established**. Inspection does not
prove whether a final production root retains these paths. Production linking,
allocation reachability and stack bounds are mandatory acceptance work.
[ABI evidence](nrf-embedded-abi.txt) confirms Cortex-M4/v7E-M/Thumb-2 and VFP
argument convention; [ARMv6 evidence](pi-armv6-abi.txt) preserves the Linux target.
No target was linked, executed or flashed.

## Disposition and limits

Proceed to RFC finalization and implementation preparation. The selected
interface/transaction has no failed assumption within this finite package.
Complete source transformation, production ownership integration and full-image
resource proof belong to the [implementation handoff](../../../docs/iterations/iteration-003-review/rfc-014-implementation-handoff.md).
A future concrete contradiction must still be brought back for a decision; this
result is not permission to weaken ownership, capacity or accepted zero-heap
requirements. No automatic successor investigation is authorized.
