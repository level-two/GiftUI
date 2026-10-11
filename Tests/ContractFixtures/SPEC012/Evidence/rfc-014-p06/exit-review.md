# RFC-014 P06 independent Strong exit review — 2026-10-11

**Recommendation: BLOCKED. One high-priority implementation finding, P06-R1.**
This is the finite package recommendation; parent package disposition remains
separate. No Specification or task is marked complete. Counter remains **0/2**:
this review reproduced a new defect and made no repair attempt.

## Frozen boundary and authority

- Review dispatch `d03c7026`; clean input `5a24a271`; reviewed change
  `a17724b2..5a24a271`, implementation ending at
  `909a7dab8581368aa776c5d93f7f2b0e33d68ec2`.
- Strong independent review, `gpt-6-astra` / `high`, C3/R3, sequential after
  implementation and its evidence work. Production files are unchanged.
- SPEC-012 is **implementing**, its plan **active**, T10.1 open. Current authority
  is its approved RFC-014 amendment, accepted ADR-035/036/037, retained
  ADR-029/030/031 geometry/failure semantics and the exact scoped-source
  amendment approved in `e6f10f67`. The latter permits the Source suppressions;
  it does not relax binding or failure order.
- P03/P04 and sequential P05 dependency exits are already passed. Their bounded
  ownership, two semantic banks, exact identity and borrowed consumer contracts
  are prerequisites, not proof of complete coordinator/application adoption.
- This is ITERATION-003 runtime migration for the analyzer and finite counter.
  ITERATION-001's required waveform drawing and four-stack semantics supply the
  regression baseline; this review does not reopen that closed iteration.

## P06-R1 — high / blocker: bind the staged model before authored drawing

**Locations at reviewed implementation:**

- `Sources/GiftUIMacros/FiniteSourceLowering.swift:296` and `:303`: the generated
  witness directly emits the rewritten authored body without a binding prologue.
- `Sources/GiftUIMacros/FiniteSourceLowering.swift:627`–`:638`: model binding is
  introduced only at the location of a model-member expression.
- `Sources/GiftUIMacros/CanvasWitnessLowering.swift:50`–`:58`: dispatch validates
  the case/payload ID then calls the witness, without model-key prebinding.
- `Sources/GiftUIRuntimeCore/ObservableCanvasInvocationSource.swift:34`–`:37`:
  `withRead` establishes the owner read phase, then dispatches the value. The
  P03 `ObservableModelScope.withRead` constructs scoped slots; it does not bind
  the particular Canvas key.

SPEC-012 lines 118–120 require the invocation bridge to receive a freshly
validated read for the exact staged owner/model/generation. Lines 177–178 place
model-key binding immediately before occurrence invocation, after identity/order
checks. ADR-037 also requires fresh exact-selected-model binding per invocation.

The supported authored source can place `withPath` before its first model read.
The independent reproduction moves CounterTrace's existing `let value =
model.value` into its existing scoped path closure. No new source construct is
introduced. The pinned production lowerer accepts it. A real P03 Static owner,
live frame/pin, bounded Static staged store, generated Counter table and actual
ObservableCanvasInvocationSource invoke that Canvas with a stale generation.
The path allocator deliberately returns `capacityExhausted`.

Expected: `invalidModelAccess`, zero `beginPath` calls, one staged-value release.
Actual, from [the native log](exit-review-binding/3.log):

```text
stale-key draw: beginPathCalls=1 invalidModelAccess=false capacityExhausted=true releases=1
```

Thus authored drawing starts before key validation and path failure masks the
required binding failure. The existing passing stale-key fixture reads the
model on its first draw statement, so it does not distinguish these orders.
The reproduction does not demonstrate freed-memory access: backing and cleanup
remain live and bounded. The blocker is the approved binding/failure ordering.

Reproduce from repository root:

```text
python3 Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/exit-review-binding/reproduce.py
```

[Exact commands](exit-review-binding/commands.txt),
[authored input](exit-review-binding/CounterCanvas.swift),
[actual-owner driver](exit-review-binding/Main.swift) and
[source/compiler/object/executable hashes](exit-review-binding/result.json)
preserve the narrow proof. The script checks the observed defect; it is review
evidence, not a success oracle to adopt into the contract suite. It reuses the
verified native component objects and replaces only the generated CounterCanvas
object. No four-profile or broad repository route was rerun.

**Required repair boundary:** ensure the finite staged model identity is checked
before any authored draw work, preserving existing identity/order precedence,
scoped exact owner/backing access and closed error mapping. Add a binding-before-
path/client-failure control to the registered owner route. This is an
implementation correction under the approved contract; no broader suppression,
capacity change, new generic frontend work or successor package is authorized.
The parent confirmed this routing. A subsequent independent review must verify
the repaired delta and applicable evidence before recommending P06 pass.

## Other inspected obligations

These observations do not override P06-R1 or complete DR-RD criteria.

| Area / criteria | Finite review result |
| --- | --- |
| Compiled Canvas and finite witnesses; DR-001/002/010, DR-RD-001 | Canvas alone receives Never/default primitive traversal; ordinary Body is inferred. The generated typed union/switch is exhaustive over its finite inventory, IDs are per concrete type, exact type projection is guarded, unknown payloads fail closed, and ID/payload mismatch rejects. Source/read/context copy/escape/effect negatives pass. Full application witness inventory/link adoption is P08/P09/P12. |
| Actual backing lifetime; DR-009, DR-RD-002/003 | The concrete source is noncopyable/nonescapable and stores the actual borrowed P03 scope and staged scope with lifetime dependence on both. Each factory encloses real storage borrows and has an Escapable-result callback. Private descriptor construction is lexically inside these borrows, rather than treated as the backing proof by itself. Both staged profile lenders preserve that boundary. Reads end on normal and throwing returns before release; P06-R1 concerns key validation order within that safe interval. |
| Occurrences/order/local dimensions; DR-002/003, DR-RD-002 | Bounded stage rejects duplicate identities/excess; invoked state prevents a second call. Producer validates identities and strictly increasing Layout ordinals before drawing; the bridge makes zero-origin checked Rect bounds. A/B/A selection, repeated types, zero occurrences/dimensions and local size/order have matching native evidence. No current-root lookup or retained Canvas closure fallback is present in these selected paths. |
| Transfer/publication; DR-003/009, DR-RD-003 | Expansion holds pending concrete payloads; candidate borrow and publication reject pending values. Transfer moves values to the staged owner and leaves nil Canvas markers. Partial transfer failure discards the staged prefix and candidate, preserving prior publication. Both profile semantic/staged stores exercise success/failure/retry. These component tests do not establish coordinator offer integration. |
| Cleanup/error mapping; DR-003/007/009, DR-RD-003 | Producer leaves pre-acquisition cleanup to the caller; lender `defer` also discards remaining entries. Acquired validation/invocation failure releases the suffix and resets/discards workspace; successful invocation releases immediately; seal failure follows release. Partial transfer cleans both sides. Closed five-case access mapping, raw production value 9, one-byte error and owner failure fields are evidenced. P06-R1 remains a precedence violation despite correct mapping functions. |
| Geometry/raster; DR-004/006 | Production Path/stroke algorithms and independent vector/oracle inputs are unchanged. Saved native runs contain 17 production geometry assertions and 3,624 raster assertions over all 17 literal vectors, two encodings and full/tiled damage, with separate Q160 oracle pass. The generator translates coordinates/clips consistently and retains literal expected masks/bytes. |

## Independent evidence and resource reconciliation

[Verification script](verify-exit-evidence.py) and
[verification result](exit-review-evidence-verification.json) independently match
all four copied/original receipts and core receipts, compiler identities,
**602 input hashes**, **812 output hashes/sizes**, all 13 named negative
diagnostics per profile, native/ABI logs and seven unchanged baseline controls.
There are no mismatches. Verification includes core GiftUI/macro source inputs
and output identities; component provenance is not inferred from a commit label.

Both native profiles retain the reported 3,944 assertions: 266 staged/semantic,
13 mapping, 24 finite table, 17 geometry and 3,624 raster. Static and nRF accurately
say dirty at `d7589023`; every recorded input matches final implementation files.
Dynamic and ARMv6 were collected clean at `909a7dab`. The independent defect proof
does not invalidate these saved results; it exposes a missing ordering case.

All **196 reserved payload slots**, including unused/non-Canvas slots, are
charged: baseline 6,272 bytes; Counter 7,056 bytes (+784) on all profiles;
Analyzer 7,840 native (+1,568) and 7,056 on 32-bit targets (+784). Counter's
two complete semantic banks total 30,616 bytes including the unchanged
record/path/scalar extents. Three Counter staged slots plus metadata cost
112 bytes; five Analyzer slots plus metadata cost 244 native/184 target.
Invocation source stride is 64 native/32 target. These are selected physical
representations, not permission to increase configured limits.

ARMv6/nRF objects and layouts are target compile/ABI evidence, including VFP
calling convention. They are not board execution. The nRF allocation result
only inspects direct calls in 11 emitted staged/invocation bodies; it does not
prove transitive linked zero heap, complete stack/IRQ overlap or application RAM.
Both staged stores execute natively, but the actual model owner used there is
Static; Dynamic coordinator/model-owner integration remains P07 onward.

## Disposition and remaining gates

P06 remains blocked on P06-R1. No other blocker was established in this bounded
review. Existing P07–P12 obligations remain: actual coordinators, accepted/refused
offer and committed-replacement integration, complete application/host adoption,
four-profile integrated functional checks, full linked resource/stack/allocator
and authorized workload evidence, production cutover and human implemented
transition. T10.1 and all DR-RD acceptance checkboxes remain open.

No new optional idea or deferred decision was discovered. The ordering defect
is required correctness and cannot be deferred. This review changes only
evidence and its plan/conformance links. Final record validation passed
`scripts/validate-governance.rb` and `git diff --check`; no maintained Swift source
or production contract was edited.
