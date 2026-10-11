# P08 activation blocker resolution record — 2026-10-12

## Current conclusion

P08 is not unblocked. The original positive construction failure has a working
experimental realization, but no candidate has passed the required callback
containment control. No experimental owner has been adopted into maintained
implementation. SPEC-015 remains implementing, its plan active, and P08 open.

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
after callback return. The compiler accepts the tested owner forms. The backing
callback is a semantic retirement boundary, even when enclosing storage remains
allocated. Accepted negative executables were never run.

The investigation progressively removed possible explanations:

| Frozen control | Result and independent review |
| --- | --- |
| Callback-local token retained by lifetime annotation | Actual positive passes; reachable negative accepted. [Review](activation-fence/final-review.md). |
| Actual Span retained in both enum states | Direct Span negative rejects; wrapped owner negative accepted. [Review](activation-span/final-review.md). |
| Identical out-of-line callback and runtime marker | Actual owner and a minimal enum-only program still accept escape. [Review](activation-boundary/final-review.md). |
| Immutable Span field outside changing state | Minimal struct positive passes; negative accepted. [Review](activation-struct/final-review.md). |
| Optional extraction comparison | Direct Span still rejects with `take()`; wrapped owner still accepts without `take()`. Extraction alone does not explain the outcome. [Review](activation-extraction/final-review.md). |
| Remove explicit receiver lifetime update | Only the annotation on Boolean mutation changes; positive passes and negative still accepted. [Review](activation-receiver/final-review.md). |

These are exact tested outcomes, not proof that every Swift 6.3.2 representation
is impossible or an identification of a particular compiler implementation bug.
No further representation trial is authorized by the closed final control.

## Concrete remedy assessment

An [evidence-only compiler comparison](compiler-comparison/scope.md) is in
progress, using official Swift 6.3.3 and 6.4.0 packages extracted only beneath
`.toolchains/`. Package verification is pending; no alternate compiler result
is claimed. The fixed matrix preserves the frozen sources, target, SDK,
optimization and feature flags. A syntax or feature rejection is not a passing
containment check. Accepted architecture, supported compiler pins and maintained
source remain unchanged throughout the comparison.

If an alternative passes, it supplies a concrete candidate for an explicit
baseline decision; it does not authorize adoption. The affected authority starts
with ADR-036's initial compiler pin, SPEC-013's migration configuration and
SPEC-002's migration/measurement configuration, plus target-specific normative
pins in SPEC-003/004. Native minimal evidence cannot establish ARMv6 or Embedded
Swift compatibility, ABI or resource results. SPEC-015's containment requirement
must remain intact.

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
has not been applied because no activation candidate is verified yet.
