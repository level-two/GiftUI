# P08 stack materialization — independent Strong design review

**PASS: candidate A is safe to attempt as an internal realization under a new
bounded source/validation activity.** Independent Sol 6.1 High review of
`af6b5aab` and `0c86e063`, the [implementation note](../../../../../../docs/implementation-designs/spec-015-p08-stack-materialization.md),
[activity](p08-resource-design-activity.md) and [packet](resource-design/README.md).
No ownership, capacity, required workload, architecture or resource-limit decision
is required before this attempt. Code-generation effect is unknown; baseline
27,648, failed fit and all P08 acceptance gates remain unchanged.

| Evidence | Independent assessment |
| --- | --- |
| Provenance | Actual ELF SHA-256 remains 66ca1113d997c6424aedb258c1477692ce4bf5b42ed77f42bb1d5cba66339da9. Fifteen source/header and fourteen payload/compressed/decompressed identities verify. Actual ELF symbols match all eight attributed functions; raw bytes independently verify seven prologues and both nested BL targets. |
| Simultaneous path | The live nonnull repeated-host transcript reaches the body and run method. Body retains deferred finish; run reinserts its consumed host after reuse. BL at 0x1f1b0 reaches 0x1d45c; BL at 0x1d502 reaches 0x1a8fc. Their allocated frames coexist: **71,808 + 38,672 + 102,640 = 213,120 bytes**, before outer/nested/IRQ costs. Separate construction, finish and wake frames are correctly excluded. This is a feasible lower bound, not an upper bound or board execution. |
| Materialization | Exact getter symbol follows the 4,200-byte stack copy; outlined helpers around the 3,889-byte transfer identify CounterHostState and its active coordinator/ticket/span payload. All 6 / 138 explicit-length windows check with no intervening BL or r2 overwrite. Counts are static sites, not simultaneous bytes or semantic duplication of noncopyable authority. counterCheckHostFrame already borrows its control. |
| Budget/MPU | Actual main/ISR objects are 27,712 / 2,112. Configuration/Zephyr headers support eight-byte SP alignment and 64-byte kernel guard/object rounding, with userspace disabled. Historical 6d82a31d and its connected record support 24,576→27,648; startup/idle data is not current worst-case proof. RAM forecasts check: 132,032 other bytes, 36,864 headroom, zero-margin usable main maximum 64,512. A 30 KiB stack predicts RAM 162,816 but cannot cover this path; the 213,120 lower bound alone predicts RAM 345,216, exceeding 196,608 by 148,608. No new number, guard or IRQ relaxation is justified. |

The five maintained Swift files form a coherent candidate: selected non-inlining
boundaries around existing carrier/state/cleanup/full-snapshot operations and
direct original nested-runtime reads at synchronous observation sites. Preserve
state cases, consuming take/switch/reinsertion, every lifetime union, activation
lenders, deferred finish, exclusivity and backing-last order. Keep full snapshots,
producer-origin guards, actual mutating-path correlation, semantic/pixel/wake
oracles and all corpus labels. Direct observation must not hold an inout borrow
across application callbacks or replace a full fingerprint with a partial one.
No heap box, duplicated owner, raw enum projection, region or workload reduction
is selected. Existing large cleanup helpers already have out-of-line bodies;
annotations alone are not a proven fix and added callees overlap live callers.

Freeze the concrete symbols/diff and obtain independent Strong source review.
Refresh exact noncompiled applicability and its driver pin when CounterScopedStorage
changes; the seven component receipts require their original hash/argv/exclusion
proofs. That evidence glue accompanies the five Swift files without new behavior.

The existing fresh nRF so07-layout-facts invocation is a sound early **rejection
screen**. Current preparation/module/object facts rebuild; 202 controls remain
not-run and coverage partial. Attribute ET_REL functions by section plus symbol,
not shared zero offsets; inspect actual SP changes and feasible nesting. A retained
over-limit lower bound rejects expensive follow-up. Finding none is not fit.
The image's complete-receipt guard remains intact: current complete nRF coverage
must precede the supported image; its actual ELF still needs full layout/C/ABI,
allocation, resource and IRQ proof. Native/Pi focused diagnostics retain successful
twins and explicit omitted coverage, without promoting old changed-source results.

Use the parent's clarified bound: **one grouped candidate A, independent source
review and one fresh registered nRF screen, zero automatic repair variants**.
Record the new execution boundary under current user direction before dispatch;
no fresh per-file approval or stack-limit decision is implied here. Historical
2/2 allowances remain closed, without reset. A failed screen preserves its exact
result before any further proposal. Actual contract/ownership/workload/limit
changes require the upstream decision; none is needed for candidate A as bounded.

Recommendation: proceed with that bounded attempt. P08 fit, all nine criteria,
P08/R07/T8.1/HC-RD-003, full allocator/IRQ/Dynamic proof and independent final exit
remain open. No P09–P12 or hardware work follows. No new deferred item arose.
Verification was documentary/byte/source comparison; governance (200 nodes /
2,026 edges), 551 local links and whitespace pass; no source change, compiler, test, build, runtime, image, debugger
or subagent was used. Existing __pycache__ remains untouched.
