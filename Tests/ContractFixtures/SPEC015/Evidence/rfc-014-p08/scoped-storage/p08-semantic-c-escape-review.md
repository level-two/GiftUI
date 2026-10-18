# Independent explicit-return escape harness review — 2026-10-18

**READY for the focused pair continuation.** Reviewed0533a592 after frozen result
ea83fb76. All1305 frozen inputs/four recipe hashes verify. Prior87 body availability,
checked-borrow positive/internal-access negative and prior70 privacy retain their
qualified scope; original escape exit0/unused-expression warning remains preserved.

That warning confirms the old callback discarded its view expression rather than
returning an escaping result. Both new fixtures differ from the frozen typed-factory
fixture only at this callback: positive explicitly returns UInt32/0, negative
explicitly returns SemanticRecordView<UInt32>/view. Explicit result annotation and
return prevent Void inference. The view is Copyable/~Escapable, so the intended
generic Result restriction is Escapable; there is no added noncopyable-store result,
missing lifetime declaration or raw backing setup. The shared legitimate factory,
borrowedStore and surrounding return/body remain exact. Actual isolation still
requires positive zero errors and exactly the pinned method Escapable diagnostic
for the negative; no compiler outcome is asserted in this read-only review.

The runner executes both controls, then fresh same42-source SIL only if both pass.
It requires the frozen87-body/two-passing-control result and preserves all successful
prerequisites without reselecting/rebuilding/repeating them. Consumer argv changes
only cache/output14/72; control argv only cache/fixture14/27. Fresh output is absent,
exclusive logs/no reuse and post-collection input verification remain intact.
Any failure blocks SIL and preserves evidence. Proceed under existing grouped
harness authorization; source f2325b85/ONE1/1/ZERO automatic repairs and historical
budgets remain unchanged. Review ran no compiler/test/decoder/runtime or source edit.
Actual C metadata/cost, full14-loan/Optional/lifetime/safety/strict cold/zero heap/P08
remain unqualified. No source allowance, lifetime relaxation or acceptance weakening;
protected external five/pycache remain unstaged.
