# P08 activation blocker resolution record — 2026-10-12

## Current conclusion

**Resolved: P08's activation-time construction and lifetime-containment blocker.**
The maintainer approved Swift6.4 at `267616c9`; its pins and matching ARMv6 SDK
are applied. The actual generic host constructs its coordinator/endpoint only
through activate, executes real runtime work and quiescence, and rejects copy,
callback escape, constant-marker escape and expired backing. The tested6.3.2
configuration could not meet these controls;6.4 meets them without relaxing the
contract or adding an unchecked lifetime extension.

[Independent final audit](activation-integration/baseline-final-review.md)
`0555805f` passes the maintained component and the required fresh compiler
compatibility packet. Both native P08 gates pass368 assertions/37 checks; the
new macro, four-profile core/runtime/Foundation gates, matched resource pairs,
target ABI and isolated native latency all pass. All steps are committed and
historical failures remain preserved. The actual activation fixture uses the
Static coordinator under separate native Dynamic/Static compilation profiles;
it is not four-route application acceptance or target execution.

Full P08 remains open: continue finite counter/application integration and the
four-route application/early-image gates, then the existing P10–P12 obligations.
Synthetic component reports and application-stage traces do not establish full
validator/application conformance. SPEC-015 remains implementing and its plan active.

The maintainer authorized resolution, bounded delegation and a commit for each
step. Strong Astra 6 Medium owns mechanism investigation and separate review;
Standard Sol 6.1 Medium owns supporting tooling and checkpoint reconciliation.
Closed investigation budgets and historical production repair guards remain
preserved; unused calls do not reopen those assignments.

## What changed in the diagnosis

The [first resolution bench](activation-resolution/result.md) isolated four
unlocated noncopyable-copy errors to the supplied-storage representation. A
generic supplied-storage value and scoped-control initializer overloads allowed
the actual coordinator to be constructed inside activation. Later positives
executed an actual opportunity and quiescence inside the supplying scopes. This
is mechanism evidence, not a complete host-construction or application gate.

The blocking result is now lifetime containment. A reachable negative program
stores the scoped owner outside the backing activation callback and reads it
after callback return. Swift 6.3.2 accepts the tested owner forms. The backing
callback is a semantic retirement boundary, even when enclosing storage remains
allocated. Accepted negative executables were never run.

The investigation progressively removed possible explanations:

| Frozen control | Result and independent review |
| --- | --- |
| Declared dependence on a callback-local token | Actual positive passes; reachable negative accepted. [Review](activation-fence/final-review.md). |
| Actual Span retained in both enum states | Direct Span negative rejects; wrapped owner negative accepted. [Review](activation-span/final-review.md). |
| Identical out-of-line callback and runtime marker | Actual owner and a minimal enum-only program still accept escape. [Review](activation-boundary/final-review.md). |
| Immutable Span field outside changing state | Minimal struct positive passes; negative accepted. [Review](activation-struct/final-review.md). |
| Optional extraction comparison | Direct Span still rejects with `take()`; wrapped owner still accepts without `take()`. Extraction alone does not explain the outcome. [Review](activation-extraction/final-review.md). |
| Remove explicit receiver lifetime update | Only the annotation on Boolean mutation changes; positive passes and negative still accepted. [Review](activation-receiver/final-review.md). |

These are exact tested outcomes, not proof that every Swift 6.3.2 representation
is impossible or an identification of a particular compiler implementation bug.
No further representation trial is authorized by the closed final control.

## Concrete remedy assessment

The [fixed minimal compiler comparison](compiler-comparison/result.md) is closed
at six of six calls and [independently reviewed](compiler-comparison/final-review.md)
at `80161faa`. Both official packages were extracted project-locally; their signatures and
notarization were verified before alternate compiler executables ran. Swift 6.3.3 executes the positive but
accepts wrapped-owner escape, matching the frozen 6.3.2 controls. Swift 6.4
executes the unchanged positive and rejects both the unchanged wrapped-owner
negative and direct Span.take negative for the intended marker-lifetime condition.
The comparison did not rerun 6.3.2 or establish an upstream fix attribution.

[Fresh actual native feasibility](compiler-native-join/result.md), frozen at
`ceaed326` with `6a0fb348` reconciliation, successfully rebuilds 25 dependencies,
executes the actual activation/opportunity/quiescence positive and rejects its
reachable callback negative. [Independent review](compiler-native-join/final-review.md)
at `156f3fb4` passes this bounded pair. The fixture uses
an actual Static coordinator under its preserved Dynamic-profile flags; this is
not full profile coverage. The existing macro executable remains a separately
executed host plugin, so complete macro/compiler compatibility is also unproved.
No old GiftUI module/object was reused with the candidate compiler.

The [baseline correction](../../../../../docs/iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md)
is now approved and applied. [Target setup](activation-integration/pin-step/result.md)
records compiler/SDK identities and metadata checks; fresh target compatibility,
ABI and resource evidence must be assessed separately. Historical failures,
closed budgets and production guards remain preserved.

## Verified closure evidence

1. [Maintained actual generic-host join](activation-integration/result.md) and
   [independent semantic review](activation-integration/final-review.md):48
   lifecycle assertions, all four ownership negatives, construction through the
   existing host/controller, failure containment, ordered/idempotent teardown,
   report invalidation and backing-last component ordering.
2. [Maintained native component gate](activation-integration/component-regression/result.md):
   both native profiles pass368 assertions and37 checks, using fresh6.4 dependencies.
3. [Baseline/core/runtime](activation-integration/baseline-regression/results.md)
   and [Foundation](activation-integration/foundation-regression/result.md):
   four-profile compatibility, fresh macro, unchanged semantic/layout/allocation
   boundaries and linked section evidence.
4. [Matched resource pairs/ABI](activation-integration/resource-regression/result.md)
   and [isolated native latency](activation-integration/resource-regression/isolated-latency/result.md):
   unchanged ceilings and repeated linked measurements; cross evidence is
   build/inspection only. ARMv6 code headroom is700 bytes, not a future waiver.
5. [Consolidated independent audit](activation-integration/baseline-final-review.md)
   at `0555805f` accepts closure of this component blocker. No full P08, P11 or
   feature lifecycle completion is inferred.
