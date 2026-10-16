# P08 idle-slot metadata — focused B01/B02 reassessment

**DESIGN PASS at `cb273c6f`; B01/B02 closed at design scope.** The revised
[proposal](../../../../../../docs/implementation-designs/spec-015-p08-fixture-metadata-scratch.md)
is concrete enough for its single existing-module 31-root size diagnostic.
The [initial review](p08-fixture-metadata-independent-design-review.md) remains
historical. No contract amendment is required by this correction; neither source
implementation allowance nor fit acceptance is created.

**B01:** The complete reservation map now puts ordinary active S0/S1/S2 on donor
S3, ordinary active S3 on donor S2, and the surplus active **[0,69440)** on donor
**[104160,138880)**. It never borrows an active reservation's unused tail. Independent
arithmetic verifies all 48 groups, slot masks, half-open bounds, eight-byte alignment,
disjointness and prefix counts in the [range matrix](fixture-metadata-design-range-map.json).
Its 2,266 selections match the current source: graph1 + host scenarios9 + two-host1
+ exchanges2 + invalid extent1 + ID faults28 + byte-prefix faults2208 + early5
+ candidate failures11. Source CounterScopedStorage.swift:2155–2195 and 2492–2613
supports that map. Both-host reconstruction retains the same reserved pair, original
addresses/IDs and namespaces until all cleanup completes.

**B02:** The proposed initialized caller-stack custody now precedes any binding,
contains the finite phase/busy/prefix/owner-progress fields, and is threaded once
through the Embedded graph/scoped/host corpus. Finite owned case plans replace
raw-slice supplier and direct fault/exchange/invalid-extent entry bypasses. The
mutating run borrow encloses the operation; concrete helpers receive disjoint
typed objects and separate progress loans, not a custody/raw-span callback. This
is source-plausible with the existing noncopyable actual owner. The accepted
actual-owner session/token/lifetime chain is retained, not replaced by custody.

The closed installed writer topology is specific: counter_main.c retains the
function-local backing and supplies spi_tft_write_rgb565, whose interface/body
has no counter-root/backing route. Separate direct probes still require exclusive
input and a completed previous call. This does not claim safety for forged C
aliases. Source review must verify the proposed removed bypasses and continued
runtime exclusivity rather than trusting a raw pointer's address alone.

Cleanup now matches actual source states: owner initialization failures unwind
through destroyPrefix to lifecycle reserved/acquired0 (CounterScopedStorage:495–507).
That owner is directly deinitialized without finishReservation; initialized-idle
uses finish/release, released is verified without duplicate destruction, and active
or incomplete reset poisons custody instead of enabling rebind. Both role masks
stay reserved until scoped users, typed descriptor loans, retained transcript
observations and reverse metadata/outer destruction end. The original 14-object
inventory and separate seven-object metadata prefix remain distinct.

The previous authority assessment stands without broad re-review. One frozen full
before-baseline, every complete key and all 64 records, independent lastFrame,
positive twins/order, all capacities/physical IDs/four retained slots and original
lifetimes remain required. Native/Dynamic counterparts and cold construction/
destruction frames still need truthful later evidence.

Proceed next only with the design's one diagnostic of seven **existing** types:
21 size/stride/alignment values, seven offsets and cursor/alignment/extent = 31
separate named scalar roots. Preserve exact module/toolchain/semantic flags and
original sources except the appended scratch copy; strictly decode, no link/runtime,
no retries, no maintained source changes. This answers only donor footprint <=34,720
and alignment <=8. Final changed baseline/custody/prefix bytes, typed borrowing,
actual stack and full-resource behavior need subsequent source/evidence review and
a separately recorded implementation allowance. All previous budgets remain
closed; P08 and the nine SO criteria remain open.

This reassessment performed existing-source and finite range arithmetic checks
only; no compiler, source edit, tests, build, runtime, image or new agent ran.
