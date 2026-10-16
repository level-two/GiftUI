---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 structured construction and observation operations
status: draft
authors: [codex]
created: 2026-10-16
updated: 2026-10-16
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# P08 structured construction and observation operations

**Combined initial source frozen after independent DESIGN PASS; SOURCE review pending.**
The [source freeze](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-structured-operations-initial-source.md)
pins the candidate and compiler-free checks; compilation/runtime/fit remain unproved.
The [bounded independent review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-structured-operations-independent-design-review.md)
confirms readiness for the authorized combined initial source package.
The [new authorized activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-structured-operations-activity.md)
permits one initial implementation and at most two grouped corrections after
design review. Prior2/2 remains closed. The [current independently reviewed result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-fixture-metadata-final-independent-review.md)
has passing Native behavior but required stack66104. This must fall by at least
**38456** to meet main27648, plus room for the omitted live ancestors/IRQ. Removing
only the8376 total-RAM excess would not satisfy the main-stack contract.

## Contract and scope

Realize active P08 under [ADR-039](../adrs/adr-039-scoped-storage-ownership.md),
[SPEC-015 S15.1](../specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement),
[SPEC-013](../specs/spec-013-runtime-profiles.md) physical/zero-heap/stack accounting,
and [SPEC-011's](../specs/spec-011-interaction.md) original five-bank transaction/access requirements. Preserve the
original model/root/semantic/values/control, geometry+five banks, mandatory
inert/active/retired state and all lifetime unions. No core type/protocol,
capacity/workload, flags/toolchain, main27648/RAM196608 or four34720 slots change.
The caller custody, complete surplus range/donor map, all48/2266 selections and
eight metadata prefixes remain. No scoped host/session is put into donor memory.

One grouped source package changes four concrete fixtures:
`CounterScopedStorage.swift`, `CounterPipelineOwner.swift`, `CounterNativeRaster.swift`
and `CounterTiledRaster.swift`; exact qualification/driver pins and affected
compiler-free inventory tests are supporting changes. No maintained core sink
setter, arbitrary callback/protocol, public accessor or unchecked lifetime is added.
All original384/202 compiler controls,5 Native exclusivity controls,2 projection
controls and26 reuse labels remain. Actual changed compiled inputs always rebuild.

## A. One per-host operation, then cold construction separated from use

Current two-host leaf3354 contains two inlined `runP08StaticHost` bodies and reserves
21968; ordinary one-host leaf reserves8336. Its view/inventory/reconstruction work
shares a frame with both sets of host-construction temporaries. Introduce one
concrete noninline `p08RunOneMetadataHost(owner:inout…, outer:inout…, …)->Int`.
It constructs the same checked outer view and invokes the existing root/semantic/
canvas/original owner.withStorage chain once. Two-host orchestration calls that
same operation twice; it never constructs the view or captures a host body itself.
Its cold init/inventory/reconstruction/retirement checks become short concrete
actual-object operations, returning before either host call. Keep the exact
first-host→empty/retired→same-address reconstruct/foreign reset→second-host→same
inventory→end retained observations→release/destruction/labels order. No new loan
or consuming owner is introduced. Each per-host frame remains a charged live cost.

The12664 session frame currently owns session, supplied, owner, host and join facts
while executing reuse. Split its **construction return boundary**, not another
nest of consuming execution stages. A private concrete cold constructor follows
the identical transfer chain and returns only the existing Optional host:

```swift
// Sketch: aliases are the existing concrete Static or Dynamic types.
@_lifetime(copy session, copy semantic, copy values, copy models, copy root,
           borrow control, copy activationSpan)
fileprivate func p08ConstructStaticHost(
  session: consuming P08StorageSession, semantic: consuming SemanticRecordStore<CounterPayload>,
  values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>,
  activationSpan: Span<UInt8>, models: borrowing ObservableModelScope<…>,
  root: borrowing ObservableStateRootScope<…>, control: borrowing UnsafeMutablePointer<CounterControl>,
  /* unchanged foreign validation scopes, audit/assembly/flags */
  facts: inout P08HostConstructionFacts
) -> P08StaticHost?
```

`facts` contains only owned `joinChecks:Int` and `completed:P08BodyResult?`, never a
capability, host or pointer. Session early1 resets; supplied early2 consumes inert
retirement/reset; owner early3 runs all eight original hooks **before joins**.
Each sets the same completed result and returns nil. Ordinary construction does
the same foreign/rejected binding checks, then directly returns the existing
profile factory's Optional host, consuming its one original owner. Nil without a
completed early result remains an invariant failure, equivalent to the old `!`.
Foreign validation scopes are never retained; if lifetime inference conservatively
requires their dependence, retain it inside the already enclosing foreign scope.

The live runner has one local `var host = p08ConstructStaticHost(…)`. It never
extracts `guard var host = …`, force-unwraps the Optional payload, consumes it after
a defer capture, or initializes a second owner/host local. Concrete fileprivate
mutating operations on `SignalAnalyzerPresetHostInstance` are invoked through
**mutating Optional chaining** on that original local payload:

```swift
var facts = P08HostConstructionFacts()
var host = p08ConstructStaticHost(/* original inputs */, facts: &facts)
defer { host?.p08FinishOriginalHost() } // teardown, then owned step==8 check
if let result = host?.p08UseOriginalHost(/* flags and facts.joinChecks */) {
  let noEarlyCompletion = facts.completed == nil; precondition(noEarlyCompletion)
  return result
}
guard let result = facts.completed else { preconditionFailure("original factory invariant") }
return result
```

`p08UseOriginalHost` checks early4 **before activation**, otherwise calls the
existing host-phase operation with `&self`. Early5, candidate failures, reuse and
all normal host operations remain exact. It returns only owned P08BodyResult.
`p08FinishOriginalHost` calls the existing host teardown and observes owned step8;
no borrowed self enters an assertion/autoclosure. Extensions explicitly retain
Owner's `~Copyable/~Escapable` bounds and self lifetime. Dynamic mirrors Static.
The defer finishes before `p08CompleteBody` retires the producer origin and before
the actual owner factory releases backing, as today.

The activation byte remains in `runP08ScopedBody`; every original lender remains
live. The cold constructor returns *inside that same session body*, not from
withStorage, root, semantic or canvas callbacks: their result stays owned Int.
Its return dependence carries consumed session geometry/Interaction, semantic,
values, original model/root/control and activation span. This is no exposed
scoped factory result or capability getter. Source review must verify the complete
union rather than suppressing a diagnostic. If that union cannot be expressed,
report the exact language/contract obstruction before selecting another storage.

This removes explicit retained construction locals from the live runner, but the
ABI can still allocate a return buffer or Optional payload home. **Disproof:**
actual construction-frame BL nesting into live reuse, duplicate host/owner copies
at Optional chaining, or a large runner home remaining through the callback.
Cold construction's own maximum also remains mandatory. There is no zero-copy claim.

## B. Sensitivity performs mutation, full rejection, exact restore, full match

The9208 sensitivity frame now contains all valid key construction/restoration
temporaries. The already frozen baseline independently holds each original key
and all64 original accepted records. Reuse those facts as the restoration source;
do not keep another original-key/current-array aggregate live through comparison.

Add finite operation-only probe methods to the baseline's original field owners:
install altered root/action/candidateRoot/candidateAction; restore that exact field;
install/restore accepted glyph at index0…63. The key installer creates complete
root+fixedChild4/fallback3, checks both appends and full inequality against the
captured original, writes the actual control field, then returns owned Void/Bool.
The installer may have ordinary complete-key temporaries, but its frame returns
before comparison. Restore reads the exact saved Optional, including nil, from
the baseline; it writes no baseline field. Recording restores its original saved
entry; a missing original is perturbed using the same guaranteed glyph0 probe.
All original backend scalar probes remain; their small original scalar locals may
stay in individual finite operations.

Each coordinator iteration is strictly:

```swift
before.installProbe(kind, control: control)   // inner field loan ends on return
let rejected = !before.matches(control); precondition(rejected) // mutation still installed
before.restoreProbe(kind, control: control)  // ends before next full baseline loan
let restored = before.matches(control); precondition(restored)
```

Never restore before the false comparison. Initial/final full positives remain;
per-restoration positives are additive and their logical check totals must be
recorded honestly. The initial full match proves current original facts equal the
saved restoration facts. No refresh/capture, checksum, truncated key, hidden current
snapshot or new storage is allowed. No borrowed field loan overlaps reentry into
the whole baseline comparator. These diagnostic methods return no key/bank/endpoint
capability and execute no host/producer callback while a mutation is installed.

## C. Inner comparison operands use original formal fields

Outer inout was insufficient: current field3626 memcpy8-copies2652 before borrowed
runtime-slot match; recording3634 copies1148 operands before its borrowed match.
Change the *inner operation interface*, not the logical observations or stored types:

- `CounterRuntimeSlotBaseline` gets a concrete inout-self read-only match operation;
  all backend/phase/owner/serial/endpoint-presence/four full keys remain exact.
  Capture still freezes once. Preserve old owned observation/Equatable controls.
- `CounterRecordingObservation` exposes same-file concrete operations taking
  `expected:inout CounterRecordingObservation`, plus either the existing Control
  pointer for accepted lastFrame or actual `endpoint:inout CounterEndpoint`.
  They compare the private saved value's complete scalar/header/point/stroke facts
  and all64 exact Optional glyph records against named actual stored expressions.
  No full current Sink/recording is passed or returned as a value argument.
- Both concrete CounterEndpoints add inout-self observation operations lending
  `baseline:inout CounterEndpointBaseline`; ordinary fields/keys are not replaced
  by generic wrappers. The original endpoint is reached by mutating Optional
  chaining on its original Control field. Endpoints remain in their one installed
  runtime slot; these operations do not install, clear, offer, mutate or claim it.

`OneShotRasterBackendEndpoint.sink` is **private(set)**. Do not pretend it permits
`&actual.sink` or add a core setter/unsafe pointer. The concrete comparisons read
only named scalar/element expressions such as `actual.sink.recording.glyphRecords[i]`.
Small owned fields/elements may copy; no whole sink local or current aggregate is
created. Whether a generic stored-property getter still materializes a temporary
is a measured outcome, not a compiler-elision assumption.

The loan map is finite: backend/phase/key reads occur outside endpoint field loans;
endpoint scalar prefix operation returns Bool, ending its field loan; the original
pure health observation is obtained outside that loan at the original comparison
position; suffix/recording comparison then lends the original endpoint field again
and returns before any host effect. Native reservation/glyph header and Tiled writer/
target configuration fields remain in that suffix. This avoids a whole Control
inout over an aliasing backend read, health delegate or callback. No offer/producer/
admission/wake operation runs inside any observation loan. Apply the same map to
once-only capture: prefix, owned pure health, suffix, then freeze; every original
field/presence fact is captured once, in the same synchronous stable state.

Split full-match scheduler copies into their own concrete stage operations after
the same preceding guards. Preserve the initial boundary overflow check and the
original now-test then deadline-test order/short-circuit. The copies' begin calls
still operate only on copies and return owned outcomes; no original scheduler is
mutated. Pure copy construction need not remain live through unrelated field
matches. Checked model frame/pin/read/end remains behind ordinary if, exactly
skipped on fingerprint mismatch. All new predicates use owned Boolean assertions.

## Measurement and acceptance boundary

The targeted current path homes are21968+12664+9208+2672+4360=50872, leaving15232
of its counted66104 outside those homes. **50872 is not an achievable saving**:
the one host, construction return buffers, probe keys and comparisons still cost
memory, and omitted lenders/IRQ add more. The design must reduce the full required
path by at least38456 plus omissions, not merely pass totalRAM. It selects real
source lifetime/calling-convention changes whose effect is directly falsifiable.

All baseline fields stay stored once in the existing donor pack; no eighth object,
second baseline, raw uninitialized aggregate or additional retained region is added.
The160 strict roots must remeasure actual final types and unchanged slot spacing;
any unexpected metadata growth/bounds/alignment failure rejects the candidate.
Complete cold/live/cleanup/current/stale paths and all ancestors must be charged.

After design PASS: one grouped source freeze, source review, then the existing fresh
nRF recipe with `--collect-failures --fresh-focused --select-family so07-layout-facts`
and the exact existing runtime/host paths from the prior freeze. Inspect construction
return/use, per-host caller, sensitivity, field getter/copy and cleanup instructions
before full202/image. Collect profile-matched Native Dynamic/Static runtime,
all5 exclusivity and2 projection controls as one failure batch. Retain384/202
omissions truthfully. New source parity covers all fields/loops/probe ordering,
early1–5/joins/defer/eight hooks, custody and all labels; no weaker matching or test
selection is authorized. Only a viable complete current stack plan proceeds to
current full required coverage/image and linked RAM/flash/ABI/allocator/IRQ proof.

No new compiler experiment is needed for this design review. These signatures
have not been compiled and no fit is guaranteed. A genuine inability to preserve
the lifetime union or private-set observation boundary is the precise upstream
decision point; it must not be hidden behind a raw pointer, generic escapable
wrapper, extra owner, reduced corpus or resource exception.
