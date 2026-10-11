# P08 activation blocker resolution record — 2026-10-12

## Current conclusion

P08 remains open; the supported compiler-baseline decision is now the next gate.
The independently reviewed minimal comparison verifies Swift 6.4 as a remedy
candidate, and fresh actual native feasibility passes activation/opportunity/
quiescence plus intended callback-escape rejection. Its [independent review](compiler-native-join/final-review.md)
at `156f3fb4` passes the bounded pair and supports presenting the proposal. No
experimental owner or new compiler baseline has been adopted into maintained implementation. SPEC-015 remains implementing and its
plan active. The [baseline correction proposal](../../../../../docs/iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md)
at `ba9fc7ce` awaits explicit maintainer approval.

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

The [proposed baseline correction](../../../../../docs/iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md)
at `ba9fc7ce` awaits explicit maintainer approval; normative pins and maintained
sources remain unchanged. [Target artifact availability](compiler-comparison/target-availability.md)
identifies a published matching ARMv6 SDK and bundled Embedded module, without
claiming target compatibility, ABI or resources. SPEC-015's containment contract
remains intact. Historical failures, closed budgets and production guards remain
preserved; positive feasibility does not reopen prior allowances.

## Evidence required to actually unblock implementation

1. A reviewed realization that passes actual activation, opportunity and ordered
   quiescence while rejecting copy, callback escape and expired backing, including
   a constant-marker control. All supplying activation scopes must be covered.
2. Integration through the existing `SignalAnalyzerPresetHostInstance`, keeping
   validation pure and first coordinator/endpoint construction inside activation.
   Verify lifecycle refusal, repeated activation, failure containment, report
   invalidation and backing-last teardown.
3. Maintained regression fixtures and fresh applicable component receipts under
   the accepted compiler baseline, followed by independent Strong review.

Only then can the activation blocker be marked resolved. The finite counter,
four routes, early images, resources and complete P08 acceptance remain separate
work in the approved sequence. The prepared optional regression-checker patch
remains unapplied pending the baseline decision and complete maintained integration evidence.
