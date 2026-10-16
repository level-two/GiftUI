# P08 idle-slot metadata proposal — independent design and authority review

**DESIGN BLOCKED by two local realization gaps at `5b382914`; no contract
amendment is currently required.** The temporal-role approach can satisfy existing
authority, but the present donor rule is invalid for a required case and the
prebinding custody check needs a concrete source seam. Correct these together in
the authorized design assessment, then focused reassessment precedes the proposed
31-root diagnostic. No source or compiler allowance is created by this review.

## Authority disposition

The feature remains implementing. This bounded P08 work serves ITERATION-003's
reference-counter/stack validation while preserving closed ITERATION-001 obligations.
[Accepted ADR-039:56–85](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md)
requires one actual geometry/five-bank owner, common actual-owner typed borrowing,
independent immutable provenance, no aliases/reentry and prefix/backing-last cleanup.
Its exclusion at 152–156 concerns rebinding **live initialized** storage, not a
permanent type assignment to every uninitialized caller byte across separate cases.
[S13.1:307–346,356–360 and S13.2:364–369](../../../../../../docs/specs/spec-013-runtime-profiles.md)
require the same owner/inventory/session plus every metadata object's real lifetime,
accounting and cleanup. [S15.1:362–367](../../../../../../docs/specs/spec-015-host-configuration.md)
requires disjoint final bank/geometry regions, no coexisting old owner over those
bytes, and actual offsets/fit before source work. None requires four concurrently
initialized profile instances or forbids a fully deinitialized idle interval's
subsequent private metadata role.

That interpretation does not approve an ordinary escaping lease. The actual typed
owner pointee must still be the exclusively borrowed lvalue passed to withP08Storage;
its token and complete carrier dependence must remain unchanged. Relocating that
owner object's home must preserve the original active-region identity and serial,
not substitute donor address as bank provenance. Seven metadata objects need their
own parent/prefix ledger, separate from the unchanged original 14-object bank/geometry
destruction inventory. Every old scoped user/descriptor must end before a role
change; complete deinitialization and rebinding precede new incompatible typed access.
The author's [accepted Swift SE-0107 reference](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0107-unsaferawpointer.md#binding-memory-to-a-type)
supports explicit binding and the invalidation of old typed pointers on rebinding;
it does not permit overwriting live incompatible values. Compiler lifetime acceptance
and cold initialize(to:) temporaries still require later evidence.

## Grouped blocking findings

**B01 — adjacent donor overlaps the existing surplus case.**
[Design lines 53–56](../../../../../../docs/implementation-designs/spec-015-p08-fixture-metadata-scratch.md)
choose `(active + 1) % 4`. Actual CounterScopedStorage.swift:2492–2497 supplies
`[0 ..< 2*34720)` for the required r1-surplus exchange, selected at 2594–2595.
The extra 64 retained r1 bytes move downstream control/used regions past the first
slot boundary (cursor 34,777; rounded extent 34,784). Donor slot 1 therefore overlaps
live active objects, even ignoring the larger supplied reservation view. A rejection
would drop this existing below/equal/above retained-capacity case. Replace the fixed
adjacent rule with a finite case/range map choosing a whole donor outside the complete
active reservation, including surplus, and retain all four slots and original case
semantics. Show graph, ordinary scenarios, two-host reconstruction, faults, invalid
extent, early 1–5 and surplus routes through this same checked selection seam.

**B02 — the asserted prebinding idle check lacks a custody implementation.**
Design lines 53–57,153–177 say idle phases are checked before binding and the private
scope excludes reentry, but do not locate the already-initialized state that proves
those facts. Neither fresh raw bytes nor a formerly bound/deinitialized donor object
may be read as that state. The current selection accepts one copyable raw slice
(CounterScopedStorage.swift:1895–1901); direct fault/exchange helpers at 2502–2530
also bypass it. Name the finite caller-scope custody/entry seam, its phase storage,
and how every route shares it without exposing descriptors or creating another
bank/transaction owner. State how same-span nesting/callback reentry is excluded and
how fault prefixes release both roles only after all pointee loans/descriptors end.
A concrete private call-topology proof is acceptable where it truly excludes entry;
no new global, general allocator or public lease is demanded. Explain reserved-owner
versus successfully initialized-bank cleanup so metadata-prefix failure cannot call
finishReservation on an owner still in its reserved phase. These are implementation
design details under current authority, not a request for an upstream architecture
change.

## Conditions already sound and next boundary

The proposed separate owner/outer/baseline/inventory/transcript/foreign-root/foreign-
control formal loans avoid whole-scratch reentry in principle. Foreign root/model
callbacks must end before its reset/deinit; active host defer/retirement and transcript
nil-before-release remain. One frozen before-baseline with all complete identities,
independent lastFrame, actual backend facts and all 64 recording entries can be
compared by synchronous streaming without constructing another current snapshot.
No refresh, digest, sampled field, dropped positive twin or reordered 26-label/eight-
cleanup corpus is allowed. Native Static/Dynamic must use equivalent complete
observations with truthful own storage/allocation/exclusivity costs.

After B01/B02 are concretely resolved, the proposed one exact-module diagnostic is
appropriate to determine whether seven existing type extents fit the selected idle
interval at alignment <=8. Its 31 named scalar roots stay diagnostic-only and prove
neither final modified baseline/phase layout nor live/cold stack fit. Any added phase
or trace bytes also need final accounting. Source requires the actual measured
layout, a new recorded bounded implementation allowance and independent source
review; closed prior budgets are not reused. No lower resource limit, heap, capacity,
workload or ownership amendment is proposed. P08 and all nine SO criteria remain open.

Review used current source/authority and the cited primary language proposal only.
No maintained source change, diagnostic compilation, test, build, runtime, image,
new agent or new measurement was performed.
