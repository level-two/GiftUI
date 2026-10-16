# P08 donor metadata — collected failures and final correction approach

**Approach for independent review; no correction2 source applied.** Input `b65da0d9`,
compiled source `3a1d1d32`. Correction1/2 was productive (compile/layout); the final
correction2/2 remains available. Historical closed allowances remain closed.
This groups the now-collected Native failure with the target's evidenced shared
stack homes; it introduces no limit, workload, capacity, ownership or slot change.

## Collected Native boundary

[Exact receipts, commands, logs, input and binary hashes](fixture-metadata-initial-native/result.json)
are preserved in the adjacent `receipts-and-logs.tar.xz`. Both collections used
the profile-matched host/runtime recipes from the [original handoff](p08-fixture-metadata-initial-screen-result.md).

| Profile / build suffix | Passed | Failed | Blocked | Not run |
| --- | ---: | ---: | ---: | ---: |
| Dynamic / `a8kx72gx` | 27 | 1 | 14 | 384 |
| Static / `y3rzuti1` | 27 | 1 | 14 | 384 |

Each main `execute` exits -5; its last output is the route's
`so06-reuse-…-raw-namespace-collision`. All five Native exclusivity checks and both
projection compiler controls pass independently. The summary and thirteen reuse
observations are blocked, not validated. Both receipts have fresh_focused=true,
focused_passed=false, collection_complete=false and passed=false. No full384
coverage or successful route continuation is claimed. These runs add no new
reported compiler or exclusivity failure. Their precise trap PC is unknown:
the logs are consistent with the already-proved ordinal defect, but no Native
backtrace was collected and this report does not equate that inference with proof.

The nRF [prior packet](p08-fixture-metadata-initial-screen-result.md) independently
proves the first sensitivity match before the invalid ordinal, its UDF/pruned
continuation, the shared case31776 frame, a5241-byte baseline memcpy, match7904,
and cold prepare17456→outer-init10352. Its counted required65712 subset plus
backing138880 exceeds RAM196608; omitted ancestors/IRQ remain additional unknowns.
The Native failures do not invalidate that earlier, pre-trap target path proof.

## One final cause-grouped correction

Keep implementation in `RuntimeDerived/CounterScopedStorage.swift`, plus new exact
applicability/freeze evidence and the driver's qualification pin. Existing types'
stored fields are accessible there; no core protocol, `CounterHostState`, public
API, semantic codec, backend or component implementation needs alteration. If an
actual access restriction requires another fixture seam, stop and state that
specific need rather than silently expanding the file set. Every source-qualified
receipt must be checked against its actual argv before reuse; changed counter
inputs always rebuild fresh.

### 1. Valid complete-key sensitivity

Replace all four invalid fixedChild31 constructions with the same finite lawful
recipe: construct complete root+fixedChild4; if it equals the original optional
key, construct root+fixedChild3 instead. Both append operations must succeed under
the actual ordinal<5 codec, and the chosen complete value must differ from the
original. Assign it, require rejection by the same frozen baseline, restore the
exact original before the next probe. Keep all64 recording perturbations, all
four full key comparisons, backend perturbations and the final positive match.
Do not replace a full key test with a raw ordinal, checksum or fabricated nil.

### 2. Finite case leaves, no shared aggregate execution home

`p08RunMetadataCase` becomes only a switch over owned case facts and the existing
typed descriptor. It returns the owned Int from one concrete `@inline(never)`
leaf. It must not initialize banks, construct an outer view, own role transcripts,
copy inventory or execute host logic before selecting that leaf.

| New concrete operation | Original branch and exact behavior retained |
| --- | --- |
| `p08RunMetadataGraph` | initialize actual owner; construct borrowed outer view; original graph checks |
| `p08RunMetadataHost` | host/early/candidate selector; same scenario flags, early1…5, candidate0…10 and original host call |
| `p08RunMetadataTwoHosts` | original inventory once; first host; empty/retired checks; same-address outer reconstruction and foreign reset; second host; same inventory; retained observations end; release/destruction/three labels |
| `p08RunMetadataExchange` | surplus0/64 checks; local role transcript; actual owner's withStorage; same session cleanup/exercise, role checks, release and destruction |
| `p08RunMetadataInvalid` | invalidReservation; all14 nil original inventory checks; no activation |
| `p08RunMetadataFault` | exact id/completed/after fault and original14-id verifier; no successful host activation |
| prefix branch | return1 without activation; existing partial metadata cleanup remains in custody |

Concrete leaves project only their necessary pointers from the existing borrowed
descriptor. Within each operation, actual owner and outer objects enter concrete
`inout` formal operations through `&pointer.pointee`; no value parameter containing
the owner and no new consuming phase carrier is introduced. For example:

```swift
@inline(never)
func p08RunMetadataTwoHosts(owner: inout P08TypedBackingOwner,
    outer: inout P08EmbeddedOuter, before: inout P08ReuseFingerprint,
    original: inout InlineArray<14, P08InitializedEntry?>,
    transcript: inout P08HostReuseTranscript, /* existing foreign objects/facts */) -> Int
```

This is a signature sketch, not a new generic callback API. Root/semantic/canvas/
session lenders and original activation/model identities remain unchanged. The
view contains the same loans and lives only within that case operation. Never
hold a whole Control inout loan across host callbacks or acquire a second owner.
Custody's busy/active/donor phases and complete reservation ranges continue to
cover every leaf. No new raw loan or escape is added.

### 3. Cold per-object initialization and destruction boundaries

Keep `p08PrepareMetadata` as the ordered prefix coordinator, but put each complete
object initializer in its own concrete noninline operation. The owner initializer
takes the existing outer object through an inout formal and initializes the same
donor owner address. The outer and foreign-Control constructors are not inlined
into a shared coordinator frame. Advance prefix only after each initializer
returns. All seven operations still use normal fully typed initialization; a
constructor may materialize a complete temporary in its own cold frame. There is
no claim of zero temporaries, and its full nested stack must be measured.

Likewise isolate the large outer/foreign-Control deinitializations in concrete
noninline cold operations. Keep the current prefix7→1 order, vacancy check,
`finishMetadataReservation` distinction (reserved/acquired0 vs idle/released),
poison-on-incomplete behavior, all bank cleanup hooks and backing-last. A cold
operation returns before the next phase; none of its frames is left live across
the host operation. Donor descriptors and typed objects still end before custody
marks the pair idle or rebinds it. The 48 groups/2266 selections, prefix0…7,
surplus full[0,69440)→S3 and activeS3→donorS2 map remain exact.

### 4. Actual baseline formal and field operations

Current section3729 explicitly copies5241 bytes from the baseline pointee to a
stack argument before calling sensitivity. Replace that source seam, rather than
assuming a borrowing getter is free: `p08ReuseRejectOldOrigins` and sensitivity,
stale action/input/admission/source and match wrappers receive the existing
baseline as `inout P08ReuseFingerprint`, forwarding `&before` formal-to-formal.
The pointer-to-formal entry is a single actual `&baseline.pointee` loan. Native
passes its original lexical baseline lvalue through that same operation seam.
Only the existing once-only capture writes facts; subsequent operations read them.
The type stays noncopyable, frozen once and never returned or refreshed.

Avoid whole Optional aggregate equality witnesses in the heavy match path. Add
finite concrete baseline field operations in this same file: compare joins to
the exact fourteen fields used by `counterJoinSnapshot` (including the existing
Embedded endpoint convention); compare semantic scalarCount/texts/disabledMask/
disabledCount/origin plus all22 scalars and4 lengths; compare admission's exact
eight scalar/action facts plus both2 pointer arrays and both34 state arrays.
Use direct stored-field/formal loans and owned scalar comparisons; no current
full join/semantic/admission aggregate is returned. Preserve nil/presence facts
of the frozen fields and all equality operands, including the complete captured
action identity. Keep the existing pure actual runtime/backend observations,
all64 accepted recording entries and independent lastFrame checks. Other match
facts and scheduler test copies remain unchanged, or are separated into concrete
noninline field operations without changing their order/effects. No hashing or
new retained baseline storage is authorized.

Every new borrowed helper evaluates owned Boolean operands before assert/
precondition/short-circuit autoclosures. Preserve the cycle1 ordinary-if rule:
checked model frame/pin/read/end occurs only after a successful fingerprint
comparison, exactly as before. The baseline loan may remain live through host
effects because it is in the disjoint donor/local object, not active Control;
no baseline field loan overlaps a write to that same baseline.

## Resource rationale, limits and validation

The change targets observed source causes, not speculative annotations: every
current branch pays the shared31776 home, cold coordination includes several
constructors, and borrowed pointee evaluation demonstrably emits a5241 memcpy.
Selecting independent typed leaves before heavy execution and using original
inout formals removes those source-level combinations. Concrete noninline
boundaries prevent reinlining those same combinations; they do not guarantee
the optimizer's calling convention or frame size. A case leaf remains live
through its host call and must be charged. Mandatory session12664, host1528,
reuse2688, root/lender callbacks, field comparison frames, cold constructors,
cleanup and IRQ are not declared free. Additional required paths pruned by the
old invalid ordinal become measurable only after the correction. No arithmetic
subtraction from65712 is a new bound or fit prediction.

After one coherent source freeze, independent review checks every branch against
the original switch, full comparison operand map, actual typed loans/prefixes,
valid full-key mutations and component-input qualification. Then collect one
fresh nRF160-root screen and both profile-matched Native focused runtime,
exclusivity and projection collections from the original handoff. Collect all
independent failures even if another selected check fails; do not claim blocked
observations or omitted384 controls pass. Re-measure final metadata, cold and
live paths (including now-reachable stale/current continuation). No nRF202/image
until current resource evidence is plausible. No third automatic source variant
after correction2; a further failure is a truthful boundary requiring disposition.

This analysis executed no compiler, runtime, image, debugger or source variant.
P08 remains blocked on runtime correctness and complete current resource proof.
