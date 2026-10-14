# SO-04→06 corrective independent Strong SOURCE review — 2026-10-14

**Disposition: source-readiness FAIL; finding 5 remains open.** Independent
Sol 6.1 High review, without subagents, of the one authorized corrective pass
`03f3393b3ee1c2f6fe4efa8e00463bdd3249004f..369906abf54f6341b0f0287e09d3dfeec28ab005`.
The working tree was clean at review entry. This is a bounded rereview of the
[five prior findings](so04-06-independent-source-review.md),
[corrective receipt](so04-06-corrective-source-freeze.md) and
[planned label inventory](so04-06-corrective-labels.tsv), not a new historical
audit. Only CounterScopedStorage.swift and check-spec-015-counter.py changed
as source in this pass. No source correction, compiler, formatter, build,
harness/executable, debugger, IR, image, target or hardware invocation occurred.
All conclusions below are source inspection, not measured diagnostics or behavior.

Authority remains accepted [ADR-039](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
approved S11/S13/S15 in SPEC-011/013/015, and existing SPEC-009/010 identity and
terminal-lifecycle contracts. The
[physical design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
is derived, not authority to amend them. SPECs remain implementing; plans active.
ITERATION-003 I3-04/05 requires the finite four-profile composition and accounting;
ITERATION-001's analyzer and stack regression duties persist. Full RFC delivery
remains ITERATION-004 I4-07. Conformance-reviewer and deferred-work-curator rules
are applied to this slice; no full criterion is accepted or deferred.

## Corrections and oracle review

| Prior finding | Independent source disposition |
| --- | --- |
| 1 — Embedded shadow assignment | Corrected at CounterScopedStorage.swift:1298: `self.limits` receives the pointer. The parameter remains the immutable configured limits. Compilation remains unproved. |
| 2 — Inert cleanup assertion | Corrected at 1535, 1596 and 1650–1657. The body records activation attempted only when entering the actual host run path. Owner/host construction-only returns still perform ordered consuming inert teardown/reset and report invalidation; they require unavailable input, absent wake/scheduler and zero active teardown/application acquisitions, rather than active-runtime effects. Activated cases retain `unavailable` and shared empty/balanced cleanup checks. Execution of early returns 3/4 and every activation failure remains required. |
| 3 — Surplus slot overlap | Corrected at 1172–1180, 1212 and 1255. Padded selection precedes the nested slot borrow and returns only the padded descriptor; native selection opens the derived slot borrow and returns only that descriptor. The owner no longer chooses an enclosing reservation descriptor while the nested slot access is open. Optional projection address stability and actual exclusivity enforcement remain unproved. |
| 4 — Actual carrier corpus absent | Corrected as a source corpus at check-spec-015-counter.py:174–249. Active bodies construct and activate the actual Static/Dynamic preset host. Retired bodies construct supplied→pipeline→coordinator, quiesce, consume the extracted Optional once, retire its pipeline and return the actual retired host-state carrier. Direct/generic origin omissions and actual carrier erasure controls have positives; backing negatives move the corresponding actual activated host beyond its physical-owner callback. Intended diagnostics, locations and independent causes remain unvalidated. |
| 5 — Full repeated-host reuse absent | Still a source blocker: only transaction-only sessions repeat on one physical owner; actual hosts still get fresh outer/owner allocations. No full-chain same-inventory reuse, stale-value boundary or fresh control/host proof was added. Its correct classification is detailed below. |

The new matrix preserves all twelve explicit origins: geometry, five bank inputs,
models, root, semantic, values, control and activationSpan. Each negative drops
one return dependency from its otherwise identical positive. This is an
appropriate finite test of complete-union propagation through actual carrier
construction and mutating activation/quiescence. It does not execute independent
nested shorter-scope experiments. The retired body explicitly exercises the
coordinator Optional transfer; the active body separately exercises host activation.
No header-only test is represented as that full body.

Optional positives retain the actual carrier dependency, generic positives
suppress Escapable, closure positives remain nonescaping, and tuple positives
return owned observations. Their negatives attempt the corresponding erasure.
Static/Dynamic backing controls now differ by their real supplied/owner/preset
types. The source-only TSV matches this registration structure: 384 compiler
labels per non-Embedded profile, 202 Embedded, with the five Native exclusivity
labels separate. Positives precede negatives. None is an invocation receipt.

The runner still classifies negatives by nonzero exit and diagnostic substrings;
that alone cannot establish exact location or exclusive intended cause. A later
authorized result review must inspect each failed diagnostic against its positive,
not accept an unrelated common trusted-source error. No new compiler allowance
is granted by approving this source corpus.

The checked surplus multiplication/bounds guard at 1982–1988 addresses its local
extent obligation. The byte facts bridge at 148–163 now lends only initialized
Embedded cells, including the zero/prefix paths, while retaining the full reserved
extent separately. The source no longer forms a full-count live span over the
uninitialized suffix for partial-acquisition facts. Prefix/address/zero-count
behavior still requires later execution evidence. The symbolic ledger now names
body/stage, host/controller/application, Embedded outer descriptor and retirement/
construction/helper-frame costs. It remains an inventory of accounting duties,
not an independent numerical live-storage ledger; external unchecked sums retain
their explicit bounded-arithmetic proof obligation.

## Finding 5 — approved realization missing, not a demonstrated contract conflict

The prior finding's phrase “required reset of session-local control” must not be
interpreted as permission to reactivate terminal logical owners. Three separate
lifetimes matter:

1. S13.1 permits the initialized typed physical bank/geometry owner to return to
   idle after complete logical cleanup and every old access/callback scope ends.
   It can lend a new session without initializing those physical objects again.
2. [S15 operational lifecycle](../../../../../../docs/specs/spec-015-host-configuration.md#operational-state-and-teardown)
   makes failed/quiescent instances terminal and requires a fresh complete host;
   it expressly forbids reactivating the old runtime. The root's shutdown at
   ObservableStateRootScope.swift:581–597 sets its storage retired and ordinary
   operations reject it. ObservableModelScope.swift:85–94 expressly preserves
   terminal activation. Retaining the same physical region does not require
   retaining or reopening these logical instances.
3. Identity issuance follows its actual namespace. SPEC-010's model owner-instance
   namespace must outlive reassembly; ObservableModelIdentity.swift:11–31 implements
   the existing noncopyable checked issuer. A newly issued model owner can have a
   new private allocation cursor. SPEC-009:339–352 scopes cycle, semantic, candidate,
   presentation and action namespaces to one assembled runtime, starting at zero;
   SPEC-010:619–626 scopes registration generations to that runtime. SPEC-009's
   pointer sequences likewise start at zero per source/runtime lifetime and
   exhaustion requires runtime reassembly. These contracts do not require every
   raw counter to increase across every genuinely distinct assembled runtime.

These rules admit a contract-preserving realization with new logical outer
model/root/runtime/input owners on the same initialized G/C/R/H inventory and
physical control reservation, after old users end. This is confirmation of the
existing contract's permitted realization, not selection or approval of a new
namespace/guard mechanism. No upstream RFC/ADR/Spec incompatibility has been
demonstrated merely by the current private APIs preventing old-owner restart.
Adding root/model reactivation instead would require a contract change; it is
neither necessary for this classification nor approved.

The corrective receipt's proposed three-file reactivation seams are therefore
not established as the minimum correction. Reconstructing fresh logical owners
may avoid any root adapter/root scope API change. Its suggestion that all runtime
allocator cursors and registration counters must continue across a fresh runtime
is stronger than the namespace-local contract. Conversely, resetting those values
in a continuing namespace, or asserting that a new model owner ID isolates all
other identities, would be unjustified.

**The precise unresolved proof question:** how does this finite host boundary
prevent an owned value or adapter from the old assembly from becoming admissible
to a fresh assembly that reuses the same control address and may start its
runtime-local counters at zero? Current SemanticCompleteIdentity is only a
semantic path; CapturedAction checks action identity/generation and current target
generation, not model owner ID. Normalized input carries source, presentation,
sequence and ordinal. CounterAdmission at 127–160 is a copyable raw-control adapter
that synchronizes through the current pointee. Merely clearing control, issuing a
new model/semantic owner, or observing increasing events does not establish this
boundary. Existing drained callbacks and ended scoped bindings help, but the
required stale-action/input/source/admission corpus and namespace provenance are
still absent. This is a proof/realization gap, not evidence that an invented epoch
or universal monotonic cursor is already approved.

## Smallest next handoff

Prepare a bounded derived source-only handoff under the existing authority,
without a new permission gate for documentation. Its only unresolved design
boundary is the repeated full-host session and the identity/admission proof above.
It must concretely name:

* Which physical inventory/control reservation survives, which terminal logical
  owners end, and where fresh complete model/root/runtime/input owners are
  constructed after all old users end. Preserve initialize-once bank/geometry
  duties; reconstruction of an outer logical owner must not overwrite a live owner.
* The lifetime of each model owner, registration, action, presentation and input
  namespace; the exact existing issuance/exhaustion or distinct-namespace boundary;
  and the actual guard/drain/retirement that rejects every old capture, normalized
  input/source and admission adapter. No guessed cursor or unproved reset claim.
* Two actual Static and Dynamic host sessions over one initialized physical
  owner, original address/inventory preservation, fresh initial roles/control,
  terminal-old-host rejection, stale-value tests and exact planned labels.
* The smallest demonstrated source whitelist. Start by checking the two currently
  allowed files; include another path only for a named unavoidable seam. A root
  restart API or the previously suggested three-file patch is not preselected.

That handoff makes the next source decision concrete. A proposed allowance should
be **one source-only pass over that exact whitelist, freeze/commit, independent
Strong SOURCE review, zero automatic follow-up repairs**, with no compiler/runtime/
image/target allowance. No such pass is authorized here. If a chosen realization
actually needs to reopen terminal ownership or change a namespace contract, name
the specific conflict and route only that choice upstream before relying on it.
If the existing contract and two files suffice, the next decision is a new bounded
source allowance, not architectural approval or implicit scope expansion.

## Criteria, validation and stop accounting

| Criterion | Bounded source disposition; full criterion remains unmet |
| --- | --- |
| IN-SO-001 | Matrix source corrected (4); all current-profile diagnostic evidence open. |
| IN-SO-002 | Local surplus/prefix source obligations corrected; exchange/address/destruction and transaction execution open. |
| IN-SO-003 | Owned compatibility/caller inventory and accepted I4-07 residual remain open. |
| RP-SO-001 | Initializer/borrow source defects corrected (1/3); physical/numeric/unwind evidence open. |
| RP-SO-002 | Inert source defect corrected (2); full repeated-host realization still fails source readiness (5), all cleanup execution open. |
| RP-SO-003 | Actual carrier source expanded (4); four-profile exclusivity/resource/target proof open. |
| HC-SO-001 | Actual carrier oracle source corrected (4); classified diagnostic evidence open. |
| HC-SO-002 | Inert/Embedded source defects corrected (1/2); actual host repeat-session/stale-boundary gap remains (5), execution/backing-last proof open. |
| HC-SO-003 | Labels/source registration present; fresh caller/ABI/allocator/stack/image/fit proof open. |

One approved corrective source pass is **1/1 consumed**; further automatic repairs
remain zero. No source repair or validation allowance is reopened by this review.
All historical counters/budgets and cumulative stop guard survive. SO-07–09, the
historic 58,648 versus 27,648 stack failure, full fit/P08/R07/T8.1,
I4-07/P09–P12 and lifecycle transitions remain open. Finding 5 is current required
correctness and cannot be moved to FW-037 or a new Exploration. No out-of-scope
idea was introduced. Permitted checks pass: `git diff --check`, governance
(198 nodes, 2,019 edges and existing task evidence manifests), 363 local Markdown
file links across this review/current receipt/navigation with zero missing, and
the planned TSV's unique label counts (384 native, 384 Pi, 202 Embedded plus five
separate Native exclusivity labels). The driver was not executed. These checks
do not strengthen source inspection into compiler or runtime evidence. Only this
review and five current receipt/navigation documents change; frozen source and
initial-pass evidence remain untouched.
