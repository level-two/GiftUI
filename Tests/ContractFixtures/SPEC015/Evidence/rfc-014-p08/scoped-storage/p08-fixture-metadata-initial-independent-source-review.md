# P08 idle-donor metadata — initial independent source review

**SOURCE BLOCKED at `c277403a`: one grouped local compiler-safety finding.**
The [source freeze](p08-fixture-metadata-initial-source-freeze.md) is a substantive
within-contract realization; no architecture, capacity or resource decision is
identified. Initial corrections remain **0/2**; this review consumes none. Correct
B01 within the recorded grouped activity, refresh exact pins, then focused source
reassessment precedes the first compiler screen. No per-file approval is needed.

## B01 — borrowed inventory parameters still enter an assertion autoclosure

CounterScopedStorage.swift:1527–1528 changes both inventory arrays to borrowing
parameters, but directly evaluates `current[index] == original[index]` inside
`precondition`. The assertion closure therefore captures those borrowed inputs.
This reinstates the source form rejected by the same pinned compiler in the
preserved typed-stage initial diagnostic (`p08-counter-x5t271zt/counter-model.log`,
borrowed `before` captured inside precondition). No current compilation was run;
this is a blocking source assessment based on that explicit borrowed-capture form.

Minimal correction: evaluate each original element equality into an owned Bool
before passing only that Bool to precondition. Preserve all 14 indices, complete
entry equality, original single inventory and borrowing signatures. Do not copy
whole arrays or remove the assertion. Audit new borrowed-helper assertion/RHS
sites in the same bounded correction; the other inspected new match helpers
already use owned Bool locals. Independent reassessment must close this site.

## Remaining source assessment

The finite Embedded dispatcher uses one initialized caller custody before binding,
keeps all 2,266 original selections and adds eight metadata-prefix controls. Normal
and complete surplus reservations are disjoint from the donor; two-host reconstruction
retains its pair. Seven separately bound pointees are initialized by a cold helper
that returns before operation execution. The actual owner.pointee lvalue is lent
through the original session chain. Raw selection/fault/surplus bypasses are removed;
no new arbitrary callback, scoped result, heap/global or owner/provenance substitute
was found. Descriptors are consumed only after operation loans and reverse cleanup.

Reserved/acquired0 metadata cleanup directly deinitializes the owner; idle follows
its actual finish/release path, released is not destroyed twice, and active cleanup
poisons/traps rather than permits rebind. The original bank prefix, host defer/eight
hooks, retirement/reset, transcript nil-before-release and outer-last destruction
remain. Foreign root/control callbacks end before reconstruction/deinitialization.
Current cleanup follows the real private lifecycle, not a competing owner ledger.

The noncopyable baseline captures once and matches the same complete original
field set: actual slot/backend/endpoint facts, four full keys, all 64 endpoint and
accepted-lastFrame recording entries, joins/context/admission/semantic/scheduler
facts and all original scalars. Matching constructs no current full fingerprint,
endpoint observation or recording snapshot. The added mutation controls restore
actual fields against the same frozen baseline; their runtime sensitivity is still
unproved. Native Static/Dynamic retain typed reservations and lexical baseline
loans, original stale/current ordering, 26 labels and existing positive controls.

Final metadata packing and 31 roots share the actual changed-type derivation;
active 129 roots/25 regions and full four-slot 138,880 reservation remain. The
extractor independently checks metadata extents/alignment/padding; SO08 compares
both ledgers and requires all 160 roots in the map. The byte/tail proof grammar and
image freshness guards are not relaxed. No old 15,704 diagnostic pack is accepted
as the final layout. Current compilation, strict materialization, Native lifetimes,
runtime/exclusivity and cold/live/IRQ resource acceptance remain unknown.

All 11 maintained file hashes and exact per-file patch blocks verify. Seven actual
component receipt hashes, actual compiler-argv fingerprints and exclusions for all
ten candidate paths verify; no changed counter input is qualified. Current metadata
revisions and driver pin match. The author's 878-source/765-artifact verification
is recorded without repeating all unchanged artifacts. Changed Python ASTs and
31 exact metadata export names verify. The author's 33 layout/source and 29 collector
test passes are source-stage evidence, not rerun or compiler/runtime acceptance.

This review changed documentation only. No source fix, compiler, test suite, build,
runtime, image, hardware or new agent ran. Preserve the frozen source; only after
corrected source PASS may the manifest's registered fresh focused so07 command run.
P08 and all nine SO criteria stay open; historical budgets remain closed.
