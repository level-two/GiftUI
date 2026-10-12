# Remaining P08 R02 — pre-edit finding for independent review

2026-10-12, entry `d2df7dcc0e0292ee656b1ce7723a2a2fa471ea6c`, Strong
gpt-6.1-sol/high, sequential. **R02 not implemented or validated.** This is a
read-only source/contract finding, not a new architecture decision or a claim
that human approval is necessarily required. Parent requested freeze/review
before implementation. R03–R05 have not started. Historical2/2 and B031/1 closed.

## Existing identity inputs and concrete missing rejection

SPEC-015 `Opportunity and pacing` (spec lines1184–1195) requires typed
consumer-owned wake binding with exact runtime/profile identity and valid
backing, independently of graph validation. The counter's two binding
initializers currently accept models/root/control/audit, but guard only
`root.belongs(to:models)`:

- CounterAdmission.swift:85–103, `CounterExecutionBinding.init(control:audit:)`.
- CounterHostOwner.swift:108–119, scoped-control overload.
- CounterHostOwner.swift:140–148 and CounterDynamicHostOwner.swift:91–99,
  actual `CounterHostState.activate` / `CounterDynamicHostState.activate`.

The current positive construction passes the **same** supplied models/root,
control pointer and audit to pipeline/binding/admission. It does not test or
reject a foreign control paired with an otherwise valid root/model pair.
A mismatched audit likewise has no guard in either binding initializer. This
is established by source inspection; no misuse executable was run.

| Existing input | What it proves and what it cannot establish alone |
| --- | --- |
| models + root | `ObservableStateRootScope.belongs` (155–159) calls `ObservableModelScope.sharesOwner` (55–62): actual ownership/model backing pointers plus schema match. Correct and stronger than numeric identity, but neither includes the separate control pointer or runtime profile. |
| `CounterHostControl` | HostOwner:13–21 retains compiler-dependent borrowed pointer and can produce a borrowed copy. It has no independent model/profile association to compare. Lifetime proof does not itself establish identity association. |
| `CounterControl` | PipelineOwner:24 onward contains admission/wake/scheduler/runtime/backing. It has no expected model scope or profile identifier. Inspecting its initialized/not-initialized fields cannot identify which root it belongs to. |
| audit | `RuntimeStorageAudit` is copied configuration/measurement, not storage-owner identity. Equal layout/profile values may describe separate live allocations. A profile check is useful but cannot identify a control instance. |
| report | `HostAssemblyReport` (HostConfigurationResults:40–54) contains kind/profile/audit/configuration, not an actual control address. Scheduler.begin:71–83 rejects unequal reports before pacing/runtime entry. That is a useful existing negative seam but not a unique control-owner proof. |
| profile owner identity | Static/Dynamic profile constructors (ProfileStorage:266–270/341–345) receive checked `ObservableModelOwnerIdentity` and install it in root storage. It is absent from control and binding input projections. The identity type (ObservableModelIdentity:2–8) stores only UInt32; each separately created namespace starts0 (14–20), so merely adding raw identity equality would not prove actual backing association across namespaces. Existing `sharesOwner` explicitly excludes that shortcut. |

The important available anchor is the **existing actual supplied composition**,
not a missing new global identity service. CounterHostSuppliedStorage already
retains the actual model/root scopes, control and audit together (HostOwner:32–78;
DynamicHostOwner:23–69). Its lexical profile factory owns those actual backings.
A validation path that receives independently trusted actual inputs from this
owner can compare candidates to them without adding a retained owner. Merely
comparing an arbitrary candidate against a second descriptor derived from that
same candidate is circular and would not prove rejection.

## Smallest identity options, for review

1. **Candidate local realization within the approved contract:** add a finite
   checked join at the existing counter host composition boundary. Take expected
   model/root/control/audit/report/profile inputs from the existing supplied
   owner, and compare proposed binding/admission/wake wiring before construction
   or notification/owner access. Use actual scope `sharesOwner`/`belongs`, exact
   pointer equality, selected static/dynamic profile, full audit/report equality.
   Retain the existing lifetime annotations and owners; add no stored adapter,
   accumulator, public/generic protocol or capacity. Ensure actual successful
   host construction goes through that join; tests alone checking an unrelated
   predicate are insufficient. Reviewer should confirm the trusted inputs and
   exact insertion point/finite failure payload. This may be ordinary local
   realization, so missing guards do **not** by themselves require a new ADR or
   user decision. A consuming helper must not revive the exhausted whole-
   coordinator projection shape.
2. If review finds the existing supplied owner cannot furnish independent
   expected inputs at that point, identify the precise absent association. A
   new retained model/control binding owner, new identity namespace, unsafe
   scope escape, or generic coordinator API change is outside this assignment
   and needs separate scope/ownership disposition. Do not select it implicitly.

Expected identity oracles before any eventual edit: valid actual Static/Dynamic
join accepted; foreign live control, foreign model scope/root, opposite-profile
audit and mismatched report rejected at the checked join; no change to either
control's canonical requests/reasons/outstanding, host wakes, accepted-fact
count/time, admission queue, application/endpoint constructions, finalized/applied
counts. A rejected scheduler report must also leave real pending work serviceable
with the original report. Foreign backing remains live during every negative.

## Separate finite-counter versus analyzer production boundary

The approved migration amendment SPEC-015:279–284 explicitly says counter uses
its **own immutable scalar workload descriptor** and actual storage ledger
without analyzer storage claims, preserves its finite corpus, and adds no counter
feature. Lines228–233 also distinguish its zero-capture scalar model from analyzer.

Analyzer production pacing SPEC-015:893–935 and HC-011:1597–1602 requires20
transition +2 bootstrap +6 action-induced =28,32 physical compact slots, physical
fact33 rejection and incompatible producer category projections rejected before
activation. This remains mandatory analyzer evidence, not optional deferred work.

Current counter facts are materially different:

- CounterWorkload:27–29/47–62 declares state limit34, two input/actions, one
  completion, cardinality compact32, and the same conservative pacing20/2/6.
- CounterAdmission:180–205 has one34-element UInt8 state queue, without separate
  snapshot/compact/failure category stores. CounterCoordinatorProbe:57–61
  explicitly accepts34 states and rejects35. It does not prove compact32/33.
- CounterApplication:8–49 has scalar source/repository/use-case callbacks with no
  transition/bootstrap/action category tag, per-window category count, or
  declared producer category projection. The actual startup callback admits one
  scalar through CounterApplicationOwners.startSource (77–94).
- CounterHostAssembly:61 supplies literal source/action projection values to
  existing `HostApplicationStartupValidation`, whose lines5–38 reject differing
  declarations. The declaration check exists, but its producer bounds are not
  derived from actual counter category-producing owners.

**Do not turn34 into32, map arbitrary state indices to snapshot/reserved slots,
or label28 scalar admissions as an actual20/2/6 production proof.** That would
change the finite counter's declared limits or invent semantics. B01's gap table
row160 correctly warned the34-state probe was not a production fact test, but
its wording should not override the counter/analyzer distinction above.

Smallest scope options: (a) test actual counter34/35 plus its existing source/
repository/use-case scalar callback boundaries and existing projection negatives
as counter-specific evidence, while keeping analyzer28/32/33/category evidence
explicitly assigned to the existing analyzer migration path; or (b) explicitly
assign the actual analyzer producer/admission fixtures/source needed for that
production proof. Option(a) is a likely traceability correction under the current
Spec, not a contract relaxation. Adding analyzer categories or changing capacity
to the counter is not an authorized local test fix. Independent review should
settle applicability before invoking any gate or asking the user for a decision.

## Exact prospective footprint, validation and disposition

Potential local identity files/symbols: CounterHostOwner.swift and
CounterDynamicHostOwner.swift supplied/activate joins; CounterAdmission.swift
binding construction; CounterHostProbe.swift/CounterDynamicHostProbe.swift actual
negative controls. CounterHostAssembly.swift and CounterApplication.swift only
for reviewed counter projection/callback controls. Driver changes only if needed
to register controls. No source has been edited, so no final file set or code
shape is selected here. These options are review questions, not a new
implementation design or selected architecture. [Read/hash identities](input-identities.json) pin examined
source to entryd2df7dcc. This receipt/progress are the only changes.

If the reviewer establishes the bounded local realization and correct category
applicability, the pre-edit receipt must name its exact symbols/cases before
formatting and source-specific validation with:

`python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static`

**That command was not invoked for R02.** No formatter/compiler/test, dependency
refresh, source edit, target build or R03–R05 work occurred. No failure/repair
allowance was consumed or reset. Freeze/commit this finding and return for the
parent's independent Strong review; do not claim R02 PASS or P08 completion.
