# SO-04→06 independent Strong SOURCE review — 2026-10-14

**Disposition: source-readiness FAIL; package remains frozen.** Review covers
`9f832f6f..0bb4d9ca12ac83ed5c46bbc315a1c82baab33e83`, including SO-04
`fd879ad0`, SO-05 `825603a2`, SO-06 `0bb4d9ca`, and the approved
CounterAdmission conformance-clause addition. Independent reviewer: Sol 6.1
High, no subagents. The working tree was clean at review entry. No source
correction, compiler, formatter, build, harness/executable, debugger, IR, image,
target or hardware invocation occurred. Findings below are source inspection,
not observed compiler diagnostics or runtime failures.

Authority is accepted [ADR-039](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md)
and approved S11.1–4 / S13.1–2 / S15.1–2 in SPEC-011/013/015; the
[physical design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
and [source authorization](so04-source-execution-proposal.md) derive the
implementation boundary. SPECs remain implementing, plans active. ITERATION-003
I3-04/I3-05 requires this finite four-profile composition; ITERATION-001's
analyzer and stack regression obligations persist. Full delivery remains I4-07.
The repository conformance-reviewer rules are applied to this source slice,
without replacing the owner conformance reports or waiving their wider gates.

## Blocking source findings

1. **P1 — Embedded outer initializer assigns to its parameter.**
   [CounterScopedStorage.swift](../../../RuntimeDerived/CounterScopedStorage.swift):1287
   uses `limits = counterEmbeddedField(...)`. The `limits` parameter at 1278 is
   an immutable `RuntimeProfileLimits`, shadowing the stored pointer property.
   This assigns a pointer to the parameter and leaves `self.limits`
   uninitialized before 1298 uses it. The Embedded positive cannot be accepted
   as compilable source. Minimum correction: qualify that single assignment
   with `self.`; no layout constant or contract change. Compiler rejection is
   inferred from the declaration, not measured.

2. **P1 — Inert early-return cleanup asserts active-runtime effects.**
   [CounterScopedStorage.swift](../../../RuntimeDerived/CounterScopedStorage.swift):1624–1637
   marks every owner/host stage `constructed`, then requires
   `control.unavailable`. Early returns 3 and 4 at 1657/1660 have not activated
   a coordinator. Static [CounterHostOwner.swift](../../../RuntimeDerived/CounterHostOwner.swift):224
   and Dynamic [CounterDynamicHostOwner.swift](../../../RuntimeDerived/CounterDynamicHostOwner.swift):191
   preserve inert state during quiesce. Inert retirement/reset does not set
   unavailable; its default is false. Therefore both profiles' early 3/4
   positives reach the failing 1637 assertion if the source compiles. Minimum
   correction: distinguish acquired inert cleanup from activated cleanup and
   check only acquired obligations; retain consuming inert retirement, reset
   order and teardown/report invalidation. Do not fabricate pipeline teardown
   effects or weaken active cleanup checks.

3. **P1 — Surplus native reservation retains an overlapping slot access.**
   [CounterScopedStorage.swift](../../../RuntimeDerived/CounterScopedStorage.swift):1201
   and 1244 open an exclusive `&r1Reservation.pointee.slot` access for the
   entire owner callback. With `surplus == true`, 1203/1246 select
   `.padded(r1Reservation)`, whose range check/install/destroy/borrow at
   60/68/75/83 independently access the same slot through the enclosing
   pointer while that nested access remains live. The closed source thus
   keeps two paths to the same mutable slot and uses the parent path across
   the nested borrow, contrary to the selected typed-exclusive/no-alias
   construction. Whether Swift diagnoses or traps this unsafe-pointer overlap
   is unvalidated; absence of a trap would not establish the invariant.
   Minimum correction: select the padded/native path before opening the
   nested slot access; padded uses one enclosing borrow, native one derived
   slot borrow. Preserve full surplus charging and final object addresses.

4. **P1 — The registered lifetime matrix omits actual active/retired escapes.**
   [check-spec-015-counter.py](../../../../../../scripts/contracts/check-spec-015-counter.py):159–169
   constructs Interaction→supplied→inert host owner and changes an explicit
   function annotation. It neither constructs the active pipeline/coordinator
   nor consumes the quiesced Optional into retirement. The replacement
   `counter-host-backing` at 173 and `counter-dynamic-host-backing` at 190–191
   both escape only `P08StorageSession`; the previous actual Static/Dynamic
   host escape bodies have been removed. They cannot prove independent
   host/model/root/semantic/value/control/activation escape rejection across
   the actual chain. Optional/tuple/generic/closure controls at 179–182 likewise
   cover a session or owned input, rather than the promised direct/generic
   carrier matrix. A passing annotation test is useful, but insufficient for
   HC-SO-001/RP-SO-003. Minimum correction: retain these header controls and add
   finite positive/negative actual Static/Dynamic carrier pairs, including
   consumed coordinator Optional and retired carrier, with each shorter-lived
   origin independently exposed. Freeze exact labels and intended causes
   before any invocation; a renamed common-session negative is not specialized
   Dynamic host coverage.

5. **P1 — Repeated sessions bypass the host/control reset obligation.**
   [CounterScopedStorage.swift](../../../RuntimeDerived/CounterScopedStorage.swift):1986–1991
   and 2078–2081 repeat only `P08SessionOnlyCleanup.exerciseTransactions`.
   Host cases at 2085–2086 construct fresh outer storage and a fresh owner
   each time. They never reuse one physical owner/control after actual host
   teardown. The selected teardown leaves control unavailable and retains
   wake/scheduler objects; the next pipeline initializer calls
   [initializeCounterWake](../../../RuntimeDerived/CounterWakeIntegration.swift):9–10,
   which requires both nil. No selected session-acquisition path resets that
   control, so same-outer host reuse would fail before a fresh activation.
   This also leaves stale input/source/admission and generation behavior
   untested across the full chain. Minimum correction: establish the required
   reset of session-local control after all prior users end, preserving backing
   ownership and existing monotonic identity/generation rules, then add two
   actual host sessions on the same initialized physical inventory for both
   profiles. Assert fresh control/roles and stale-action rejection rather than
   substituting fresh outer allocations. If this needs a currently unlisted
   source path, propose that exact addition first.

## Physical accounting and remaining validation

The source establishes a separate original inventory, successful-prefix reverse
destruction dispatch, checked reservation disjointness/alignment, complete typed
R/H descriptor exchange, and owned physical bank facts. Static/Embedded 14 and
Dynamic 9 acquisition positions, Embedded byte prefixes, unequal retained R1
extents and six unequal-count exchanges have source-present controls. These
are not executed destruction/address/byte-ledger evidence. Native Optional
projection may use temporaries; equality assertions do not prove address
stability. Partial Embedded byte faults form a full-count unsafe MutableSpan
in `P08ByteSlot.withBorrow` (155–156; facts at 159–161) although only the prefix is initialized;
the bridge must establish that it does not treat uninitialized cells as live
elements. This is a trusted-borrow proof obligation, not a demonstrated read.

The disclosed surplus slice multiplication at
[CounterScopedStorage.swift](../../../RuntimeDerived/CounterScopedStorage.swift):2026
is unchecked. The fixed `30176 * 2` is representable on the pinned targets,
so this review does not assert present arithmetic overflow. It still needs
the chosen checked extent/bounds seam before claiming checked arithmetic.
Other new measurement sums/subtractions, including dynamic payload sums and
family totals in [CounterStorageMeasurement.swift](../../../RuntimeDerived/CounterStorageMeasurement.swift):170–186,
also require explicit bounded arithmetic justification; final UInt32 conversion
does not protect earlier arithmetic.

The 26-family reconciliation compares formulas and rows derived from shared
facts. It is not an independent complete live-storage ledger. The selected audit
charges original bank/geometry extents, outer storage, owner, view and a concrete
coordinator; it does not enumerate the live `P08BodyStage`/cleanup, host-state
tag, host controller/owner/application/assembly fields, Embedded outer descriptor
or construction/retirement temporaries and helper frames. Exact numerical
attribution belongs to SO-07/08 and must include these paths without double
charging nested carriers. No target-constant ELF table/C-symbol reconciliation,
allocation reachability, ABI, Native/Pi/Embedded exclusivity enforcement,
Dynamic peak, complete stack/IRQ path or image fit is proved. Those later gates
remain required, not a reason to silently expand this source pass. The historic
58,648 versus 27,648 stack failure is unchanged.

Complete G/C/R/H suppressions, supplied/pipeline constructor unions, private
geometry/Interaction fields, consuming retirement, cache release before quiesce,
one consumed coordinator Optional, and semantic→geometry→Interaction reset order
are present. Owned-only returnWorkspaces remains constrained. The approved
CounterAdmission diff changes only its conformance requirements. Shared runtime
coordinator source and target/firmware/CMake/image recipes are unchanged. Existing
action/semantic/pixel/graph/join/wake controls remain source-present. SPEC-011/013
and scoped-host registrations merely hash the private fixture; only the counter
driver compiles it. New negative causes, twins and Native exclusivity execution
remain unvalidated; the driver checks diagnostic substrings, not exact location
or exclusive cause. No owned compatibility pass is inferred.

## Criteria disposition and next bounded decision

| Criterion | Source-slice disposition; full criterion remains unmet |
| --- | --- |
| IN-SO-001 | Blocked: declarations precede this diff; complete current-profile compiler evidence and actual lifetime matrix still required (finding 4). |
| IN-SO-002 | Blocked: descriptor/transaction controls present; surplus borrow, address/destruction and transactional execution unproved (3). |
| IN-SO-003 | Blocked: owned constraints/facts present; current caller inventory and compatibility evidence incomplete. |
| RP-SO-001 | Blocked: physical source present; Embedded initializer and surplus borrow defects (1/3); numeric accounting/unwind evidence open. |
| RP-SO-002 | Fail at source boundary: inert returns and actual host-session reset/coverage defects (2/5); active cleanup execution open. |
| RP-SO-003 | Blocked: incomplete actual carrier oracle (4), four-profile/exclusivity/resource gates open. |
| HC-SO-001 | Blocked: full-union declarations present; actual active/retired independent escape matrix absent (4). |
| HC-SO-002 | Fail at source boundary: Embedded/inert/reuse defects (1/2/5); backing-last/old-new-site runtime evidence open. |
| HC-SO-003 | Blocked: driver registration present; fresh source/caller/target/ABI/allocator/stack/image evidence absent. |

**Proposed only:** one explicitly approved corrective source pass confined to
`CounterScopedStorage.swift` and `check-spec-015-counter.py`, plus corresponding
fixture/label/receipt documentation, implementing findings 1–5 and the checked
surplus slice. Freeze that exact diff and finite oracle list, then independent
Strong source review again. Add no unlisted source path implicitly. The partial
byte-span invariant and symbolic live-storage/accounting inventory must have
explicit dispositions at that freeze. No compiler/formatter/run is included in
this proposal. Only after a passing source review may the already proposed
14-cell SO-07 sequence be considered with refreshed exact inputs and labels;
SO-08 remains separately gated. No invocation or retry allowance is granted here.

Review completes this documentation boundary and identifies productive source
findings; it does not accept SO-04–06, fit, P08/R07/T8.1, I4-07/P09–P12 or any
lifecycle transition. Initial source pass is exhausted; post-freeze corrective
passes remain zero. Historical counters, budgets and cumulative stop guard
survive unchanged. Required correctness findings cannot be deferred to FW-037
or a new exploration; no out-of-scope idea was introduced.

Permitted checks pass: `git diff --check`, governance (198 nodes, 2,019 edges;
existing task evidence manifests), and 358 local Markdown file links across
this review plus current receipt/plan/context, zero missing. Only this review
and four current navigation/receipt documents change; frozen source and
initial-pass evidence remain untouched.
