# SO-04→06 bounded corrective source freeze — 2026-10-14

**Current independent review: source-readiness FAIL at `369906ab`.** The
[bounded Strong rereview](so04-06-corrective-independent-review.md) confirms
findings 1–4 corrected as source and the local surplus/prefix dispositions;
finding 5 full-host repeat-session realization remains absent. Physical-inventory
reuse is compatible with fresh terminal-safe logical hosts under the existing
contract. The three-file old-owner reactivation suggestion below is historical,
not an established minimum patch. Runtime-local cursor continuity across a
genuinely fresh runtime is not a blanket contract requirement; exact stale-value/
admission namespace isolation still needs a concrete derived handoff. Prepare
that documentation autonomously before presenting an exact next source whitelist.
The correction is **1/1 consumed**, zero further automatic repairs, no allowance
or historical guard reset. All criteria/fit/P08 remain open; no execution claim.

Approved input `03f3393b`, following the independent review at `0e047ee4`
of initial source `0bb4d9ca`. One expressly authorized corrective source pass
has produced this checkpoint. Source is frozen for a new independent Strong
SOURCE review; zero automatic follow-up repairs. This checkpoint does not
complete SO-04–06: finding 5 remains a potential scope/lifecycle incompatibility
requiring independent classification.

Only `CounterScopedStorage.swift` and `check-spec-015-counter.py` change as
source. Original typed physical owner, common session, consuming transfers,
quiesced Optional retirement and reset order remain selected. No contract,
runtime coordinator, target/firmware/CMake recipe or unlisted source changes.

| Reviewed item | Corrective source / explicit disposition |
| --- | --- |
| 1 Embedded initializer | Qualify the pointer property assignment as `self.limits`. |
| 2 Inert cleanup | Cleanup records whether activation was attempted. Constructed inert paths retain eight-step teardown/report invalidation and require absent wake/scheduler, zero active teardown/application acquisitions, stopped input, empty admissions/routing and balanced observations. Activated paths still require unavailable plus all prior active cleanup obligations. No pipeline effects are fabricated for inert returns. |
| 3 Surplus native borrow | Closed `withP08R1Reservation` selects padded versus native before the nested slot borrow. Padded invokes the body with the enclosing reservation descriptor only; native derives the slot and passes only that descriptor. Full retained surplus and original pointee checks remain. |
| 4 Actual carrier corpus | Retain inert header controls; add actual activated preset-host bodies and actual supplied→pipeline→coordinator→quiesce→consume Optional once→retired host-state bodies, both profiles/direct and generic. Each of twelve return-origin omissions has its complete-union positive. Optional/tuple/generic/closure controls now additionally accept these actual carrier specializations. Static and Dynamic backing negatives move the corresponding activated host out of the physical-owner callback; positives teardown inside it. These are source-present, unvalidated oracle intentions, not diagnostic evidence. |
| 5 Same-inventory actual host reuse | Unresolved, affected work stopped. No reset/repeated-host claim is made. Existing three transaction-only sessions remain; fresh-outer host cases do not establish actual repeated-host coverage. Exact additional-source decision below. |
| Surplus extent | Replace raw two-slot multiplication/slice with checked multiplication, positive extent, supplied-buffer bound and nonnil base before slicing. C reservations/limits unchanged. |
| Partial-byte bridge | `P08ByteSlot.facts` forwards initializedCount to the Embedded borrow. Its MutableSpan covers exactly the initialized prefix; full reservation remains charged separately. Normal session borrows cover the full count only after successful initialization. Source invariant is explicit; execution/address stability remain unproved. |

## Exact oracle registration

The [initial label ledger](so06-source-freeze.md#exact-newly-registered-labels)
remains provenance. Its header and primitive labels remain; the two
`counter-host-backing` and non-Embedded `counter-dynamic-host-backing` pairs now
use the corresponding actual activated host body, replacing the common-session
escape body. No label is renamed to imply specialized coverage without code.

Added labels, in driver order:

* `so06-carrier-{route}-{mode}-{phase}-{origin}-{polarity}`: route `static`,
  then `dynamic` (omitted Embedded); mode `direct`, then `generic`; phase
  `active-host`, then `retired-optional`; origin `geometry`,
  `candidateRecords`, `candidateHitRegions`, `candidateCommittedRecords`,
  `committedRecords`, `committedHitRegions`, `models`, `root`, `semantic`,
  `values`, `control`, `activationSpan`; polarity `positive`, then `negative`.
  Adds 192 non-Embedded / 96 Embedded compiler labels.
* After each phase's origin pairs:
  `so06-erasure-{route}-{mode}-{phase}-{kind}-{polarity}`, same route/mode/phase;
  kind `optional`, `tuple`, `generic`, `closure`; polarity `positive`, then
  `negative`. Adds 64 non-Embedded / 32 Embedded compiler labels.

Current scoped compiler-label totals: 384 per non-Embedded route, 202 Embedded.
The five Native exclusivity labels remain unchanged. Complete expanded labels
and applicability are in [the source-only label inventory](so04-06-corrective-labels.tsv).
Negative intended causes are omitted origin `lifetime` plus origin name;
carrier erasure `Escapable`, escaping closure `escaping`; actual backing escape
`lifetime` plus `escaped`. Exact diagnostics/locations/causes are unvalidated.
The new lifetime controls test independent origin omissions at the actual
carrier return boundary; they do not claim twelve executed nested-short-scope
experiments. Positives precede negatives. No invocation allowance is granted.

## Finding 5: minimum known additional-source decision

Historical freeze assessment; see the independent classification above before
using any proposed seam as the next source boundary.

Resetting the whole CounterControl would reset monotonic input/action identities
and cannot be treated as a fix. Its retained wake/scheduler must be released
only after prior hosts, callbacks, bindings, sessions and outer scoped users
end. Current source prevents a complete correction within the two allowed files:

* `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift`:
  the pipeline initializes cycle/semantic/candidate/presentation/action
  allocators afresh. The host owner's private state prevents trusted code from
  transferring active allocator cursors. Minimum known seam is retained owned
  allocator state in caller-owned control, loaded at construction and returned
  at completed quiescence, including exhaustion; no identifier reset/reuse.
* `Sources/GiftUIHostConfiguration/HostNormalizedInputGate.swift`:
  its sequence allocator is private, quiesce is terminal and no restart/cursor
  API exists. Minimum known seam for a normal new host session is a guarded
  reactivation that retains the exact sequence allocator/exhaustion and clears
  only retired physical presentation/active sequence state; preserve runtime
  consumer sequence state. Do not guess a cursor from observed events.
* `Sources/GiftUIObservableState/ObservableStateRootScope.swift`:
  shutdown sets private root storage `retired`; checkOperation then refuses
  it, and adapters keep registration private. Minimum known normal-session seam
  must reestablish an empty valid registration session while retaining exact
  nextGeneration/exhaustion, after all old scopes/sinks end. This cannot reopen
  a terminal failed model activation: `ObservableModelScope.swift` explicitly
  says terminal activation cannot be reopened. That invariant remains binding.

These are known obstacles to retaining the same logical outer owners, not an
approved three-file patch or permission to reopen them. A different realization
may create new logical model/root/source owners while reusing the same initialized
physical inventory/control; that option must preserve monotonic action/input/
registration identities or establish distinct valid namespaces so old captures
cannot match new targets. It has not been selected or silently implemented.
Review must classify the actual reuse contract and decide whether normal-session reactivation is already
required by the approved SO contract and compatible with root/input terminal
rules, or whether the authority needs clarification. Any resurrection of
terminal ownership would be a contract change and is not proposed as a shortcut.
Adapter/model bodies were inspected read-only to identify the predictable root
obstacle; full error-path/API design is unassessed. No unlisted file is edited.
After the exact decision, same physical owner/control/inventory must enclose
two actual Static and Dynamic hosts; assert fresh roles/control, retained
monotonic identities/exhaustion and rejection of the old captured action/input/
source/admission. That required source coverage is currently absent.

## Symbolic live-storage and arithmetic disposition

| Simultaneously live storage | Accounting boundary for SO-07/08 |
| --- | --- |
| Caller reservation / outer storage | Original B/G/C/R/H extents plus Optional/padded tails; model/root/semantic/canvas arrays/control/used/limits and Embedded outer descriptors, alignment holes and unused supplied tail. Count each physical extent once. |
| Physical owner / inventory | Slot enums, identity/lifecycle/serial/capacities and inventory/destruction transcripts. Dynamic retained payloads are separate from owner metadata and original slot headers. |
| Borrow / session layer | Native outer pointer closures, original pointee borrows, descriptors/common token, scoped G/C/R/H and Interaction keys/session; simultaneous helper frames need actual target attribution. |
| Body / supplied / host | P08BodyCleanup and Optional P08BodyStage tag, stage's contained carrier, owner/controller/report/assembly/application fields and activation-span backing. Stage alternatives overlap; do not sum mutually exclusive carriers or charge nested copies twice. |
| Active coordinator / opportunity | Binding, admission, pipeline/endpoint, tickets/cache, all allocators, wake/scheduler; active host/state embeds these. Existing concrete coordinator charge alone is not the complete live-host total. |
| Retirement / construction | Consumed coordinator Optional, extracted pipeline/retired carrier, cleanup/switch temporaries, reset helpers and enclosing construction plus feasible IRQ overlap. Physical originals survive until every dependent user ends. |
| Test instrumentation | Role/destruction traces and test-only Native exclusivity owner slot/variant are attributed to their actual route; normal/target source excludes the exclusivity define. Corpus helpers still affect those routes that compile them. |

The 26-family reconciliation is still a shared-facts formula check, not an
independent full live-storage ledger. Numeric target facts, emitted ELF table,
C-symbol reconciliation, Native Optional projection stability, allocation,
ABI, Dynamic peak and complete stack/IRQ fit remain required later gates.
Unchecked measurement sums/subtractions outside the allowed source remain
unproved. Their fixed configured counts and ABI extents require explicit
per-profile bounded arithmetic evidence before a numeric acceptance claim;
final UInt32 conversion is insufficient. No silent overflow justification or
unlisted arithmetic edit is supplied here. The checked surplus slice and
initialized-prefix bridge resolve only their local source obligations.

Permitted checks pass: driver Python grammar inspection without executing driver
code, `git diff --check`, `scripts/validate-governance.rb` (198 nodes, 2,019
edges and existing task evidence manifests), and 353 local Markdown file links
across this receipt/current navigation records, zero missing.

No compiler/build/formatter/harness/executable/debugger/IR/image/target/hardware
invocation. Permitted source grammar/whitespace and documentation checks only.
All SO criteria, fit, historic 58,648 versus 27,648 stack failure,
P08/R07/T8.1/I4-07/P09–P12 and lifecycle statuses remain open/unchanged.
The one approved corrective source pass is frozen, with zero automatic
post-freeze follow-up repairs and no historic budget/guard reset. New independent
Strong SOURCE review is required before any further source/validation decision.
