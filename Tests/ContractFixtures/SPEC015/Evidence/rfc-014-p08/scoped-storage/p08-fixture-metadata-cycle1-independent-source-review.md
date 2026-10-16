# P08 metadata correction 1 — focused independent source review

**SOURCE BLOCKED at `db7cc7b6`; inventory B01 closed.** One same-cause correction
remains at the two borrowed-host conditions. Complete it inside correction **1/2**
before execution; it consumes no second optimization cycle and needs no user input.
The broader candidate remains covered by the [initial review](p08-fixture-metadata-initial-independent-source-review.md).

The inventory helper now evaluates each of the original 14 complete entry equalities
into owned Bool before precondition. Both borrowing signatures and all entries are
preserved, with no array copy or lender change. This closes the reported B01 site.
The two additional host conditions also remove borrowed values from Boolean RHS
closures, but evaluate model observation unconditionally.

**Remaining B02 — preserve skipped model observation on fingerprint mismatch.**
CounterScopedStorage.swift:1817–1819 and 1823–1825 formerly skipped
p08ReuseModelValue when the preceding full fingerprint comparison was false.
The revised code always observes the model before asserting the conjunction.
That observation is not a total side-effect-free scalar load: CounterPipelineOwner
363–377 calls checked beginFrame, pin, withRead and endFrame, and can trap; the
host state's observeModelValue also requires active state. Eager evaluation can
therefore perform additional phase/pin work or replace the original failed
fingerprint assertion on a failing path. Valid-state-only equivalence is insufficient
for the requested exact oracle effects/failure precedence.

Minimal same-cycle correction: keep the fingerprint result in its owned Bool;
perform model observation only inside an ordinary `if fingerprintUnchanged` branch;
combine/assert only owned Bools. Apply exactly at prepare and delivery. Preserve
original observation order, full fingerprint/model comparisons, prepared/delivered
assertions, counts and action-stale label. No copy, callback or baseline refresh is
needed. The assertion and short-circuit closures must not read the borrowed host.

Independent inverse substitution verifies these are exactly three Swift rewrites
and reconstructs the previous entire Swift file. Three source/glue/test hashes,
exact patch, new qualification hash/pin and seven predecessor receipt/input/exclusion
proofs verify. Only the scoped-storage candidate hash changed. The pinned unchanged
765-artifact proof is not repeated. Python ASTs pass; the author's 34 compiler-free
passes remain source-stage evidence, not rerun or target acceptance.

All 160 active/metadata facts, four-slot 138,880 backing, original capacities,
physical IDs, complete baseline/64 records/keys, lender/cleanup semantics and
384/202 controls remain unchanged by this narrow diff. No current compiler,
runtime, stack or fit acceptance is claimed. Correct the two conditions, freeze
exact pins and narrowly reassess before the initial fresh focused nRF screen.
No source fix, compiler, test, build, runtime or image was performed by this review.
P08 remains open; every historical budget remains closed.
