# RFC-014 P08 execution receipt — 2026-10-11

**Current checkpoint — compiler remedy proposed; approval pending, 2026-10-12.**
The [independently reviewed minimal comparison](compiler-comparison/final-review.md)
at `80161faa` verifies Swift 6.4 as a candidate for the unchanged minimal control:
its positive executes and its wrapped-owner callback escape rejects for the
intended lifetime condition. Swift 6.3.3 accepts that escape, matching frozen
6.3.2 controls; the comparison did not rerun 6.3.2.

[Fresh actual native feasibility](compiler-native-join/result.md), frozen at
`ceaed326` with `6a0fb348` reconciliation, rebuilds 25 dependencies, executes the
actual positive and rejects its reachable callback negative. [Independent review](compiler-native-join/final-review.md) at `156f3fb4` passes
the bounded pair and supports presenting the proposal for approval. This uses
the actual Static coordinator under preserved Dynamic-profile flags; it does not establish full Static/Dynamic profile coverage. The existing
macro executable is a separate host plugin, not a freshly validated macro baseline.

The [compiler-baseline correction proposal](../../../../../docs/iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md)
at `ba9fc7ce` awaits explicit maintainer approval. No normative pin or maintained
implementation changed. Generic host integration, additional ownership/backing
controls, complete lifecycle, target compatibility and resources remain unproved;
P08 and T8.1 remain open. Historical closed budgets and 2/2 guards are preserved.
[Blocker resolution record](blocker-resolution.md) summarizes the decision boundary.

**Historical checkpoint — invariant struct anchor pending, 2026-10-12.**
The latest [bounded scope](activation-struct/scope.md), committed at `99d4ddd1`,
tests a private invariant Span field outside the mutable inert/active enum state.
This is an unverified internal representation hypothesis under the maintainer's
[blocker-resolution authorization](activation-resolution/authorization.md).
No complete activation join with passing lifetime containment is verified;
maintained adoption and P08 completion remain blocked.

Independent reviews of [activation resolution](activation-resolution/final-review.md),
[callback token](activation-fence/final-review.md),
[retained span](activation-span/final-review.md), and
[matched callback boundary](activation-boundary/final-review.md) are complete
and reject adoption. The latest matched-boundary result executes the actual
positive but accepts reachable callback escape, including a minimal enum-only
reduction. It narrows the tested failure without establishing a compiler defect
or contract impossibility. Closed budgets (12/12, 7/8, 6/8, and 3/6 respectively)
and historical 2/2 guards remain unchanged; unused calls grant no continuation.
The maintained regression checker remains unapplied pending a verified pattern.

**Historical stop: production remains stopped at2/2; evidence investigation stopped after3/6 invocations on2/2 layouts, no passing controls, conservative candidate guard2/2.**
The [bounded stop packet](activation-join-stop/stop.md) preserves exact controls,
commands and narrowed cause. `c39733de` is the last validated maintained source;
P08 remains incomplete. Earlier0/2 checkpoints below are historical.

**Historical entry boundary: host integration blocked pending exact SPEC-015 lifetime
review/approval (resolved by explicit approval below).** User authorized proceeding after P07; orientation started at
clean `9fa495dd`. Strong Sol 6.1 High, sequential, no delegation. P08 starts and
remains **0/2 consecutive unproductive repairs**. P07 history is unchanged.

Entry authority: approved SPEC-015 runtime amendment, T8.1 / HC-RD-001–004,
accepted ADR-035/036/037, [bounded P08 sequence](../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md#ordered-work-packages),
ITERATION-003 I3-04/05 and closed MVP stack/behavior regression. SPEC-015 remains
`approved`, plan `ready`; no production implementation transition is claimed.
P07 finite exit passed separately; full T9.1/T11.1 and P10–P12 remain open.

## Step 0 — exact containing-host boundary

Files/symbols inspected: SPEC-015 `MVPHostInstance` and concrete construction
clauses; source `HostConfigurationResults.swift` / `MVPHostInstance`,
`HostPresetBootstrap.swift` / `MVPValidatedHostInstanceFactory.Instance` and
`HostPresetConstructionResult`; both actual runtime concrete coordinators and
their audited-binding conformance. Invariant: a host retaining a scoped
coordinator cannot outlive any supplied backing, yet must preserve the complete
validation/activation/teardown contract and role graph.

The [decision packet](scoped-host-constraint.md), evidence-only exact
[proposed diff](proposed-spec-015.diff) and [seven pinned controls](scoped-host-proof/result.json)
record the concrete conflict, proposed narrow correction and limits. Exact command:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-host-proof/reproduce.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmpwj8mqyyn/macos-static
```

Current host protocol rejects inherited Escapable; proposed correction and
concrete lifetime-dependent return compile; copy/escape reject. Current internal
associated factory rejects a scoped Instance, and naive associated suppressions
are unavailable on the pinned compiler. No existing bootstrap success is inferred.
All seven persistent controls match their expected outcome; all 165 runtime
inputs, 143 artifacts and compiler/core receipt hashes verify. An initial missing
audited-binding constraint in a temporary fixture was corrected productively.
Guard remains **0/2**. Only evidence/checkpoint documentation changed.

Next: separate bounded Strong review of the exact proposal, including construction
compatibility and required negative/lifecycle proof; explicit maintainer decision;
then implementation only under the resulting approved contract. No independent
schema expansion, P09 work, compiler change, hardware operation, resource claim
or package acceptance accompanies this blocker record.


## Approved correction — 2026-10-11

Eugene explicitly replied “Approved, please proceed” after the separate
[independent proposal review](independent-blocker-review.md). The exact reviewed
[diff](proposed-spec-015.diff) is applied to SPEC-015; the
[approval map](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#scoped-host-lifetime-amendment--2026-10-11)
records the decision and unchanged construction/activation/teardown obligations.
Original packet/probes/review remain intact. This commit changes authority and
traceability only; production implementation starts afterward. Guard **0/2**.


## Step 1 — approved host propagation (validated component slice)

The approved protocol constraint is propagated through the existing
`SignalAnalyzerPresetHostInstance`, activation/teardown owner constraints and
concrete construction return. Lifetime dependence copies the supplied scoped
owner; no coordinator is constructed by a host initializer. Conditional
Escapable/Copyable conformances preserve the existing owned construction result
surface. `MVPValidatedHostInstanceFactory` remains unchanged: a scoped concrete
construction route avoids its compiler-limited associated type.

`ScopedHostProbe.swift` borrows actual `StaticObservableModelStorage` through
`withLifetime`, and tests the unchanged activation controller with an inert
recording owner. It proves 187 assertions: valid-only activation, seven ordered
steps, every first failing step and containment, preservation of the injected
configuration failure, repeated activation refusal, ordered teardown, report
invalidation and exactly-once repeated teardown. Actual host copy/escape controls
reject; an owned-owner host remains Escapable. This is component evidence, **not**
a constructed runtime/endpoint, pure validator, complete counter or production
factory proof. Those remain P08 steps below.

Exact checks:

```sh
scripts/format-swift.sh
python3 scripts/contracts/check-spec-015-scoped-host.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmpwj8mqyyn/macos-static
```

Fresh selected modules and executable pass; [immutable receipt](scoped-host-step-1.json)
records commands, hashes, logs and artifacts in `.build/contracts/p08-scoped-host-13ylmwfh`.
Every reused runtime input/artifact and pinned compiler hash was verified.
A full host-module attempt including existing Generated schema-3 data fails
on newly required P07 records/models/byte-count initializer arguments, retained
at `.build/contracts/p08-host-holu8b57/{commands.txt,GiftUIHostConfiguration.log}`.
The selected gate explicitly excludes Generated files and does not replace the
complete host gate; the next schema-4 step must resolve this dependency. Temporary
fixture failure-type and mutable-span corrections were productive. Guard **0/2**.

SPEC-015 is now `implementing`, its owner plan `active`; T8.1/HC-RD-001–004 and
P08 package exit remain open. Next: schema-4 scalar generation and validation,
actual supplied storage, then complete counter host/lifetime/early image evidence.


## Step 2 — schema-4 scalar generation and complete host-module compile

`SignalAnalyzerHostWorkload` now requires all six non-defaulted fields. Workload
and Drawing validation accept exactly schema4; zero/malformed requirements reject,
UInt32 path counts convert exactly to UInt16, and each requirement must fit its
corresponding records limit. Complete limits remain equal; analyzer model bounds
are exactly2 slots/4 tickets/2 pins/1 capture bank. The scalar descriptor restores
approved analyzer34/14/50 depth/body/modifier bounds and layout/renderdepth13;
other approved logical, pacing, queue and raster limits remain unchanged.

The generator reads only the scalar descriptor and emits all four schema4
manifests plus complete limits/leaves. It no longer reads hierarchy-shape input,
synthesizes actual storage bytes or substitutes generated Canvas witness coverage.
`GeneratedSignalAnalyzerPreset.validatedStorageAudit(storage:)` requires a supplied
physical RuntimeProfileStorage, checks exact profile/limits and rechecks its audit.
The removed no-argument projection cannot certify schema4 backing. Remaining
analyzer consumers of that old entry are P09 migration work; this step certifies
the complete host module, not the analyzer composition or full repository gate.

The [current design note](../../../../../docs/implementation-designs/spec-015-generated-workload-and-presets.md#current-rfc-014-realization--p08)
records selected378/34/5 path reservations,7168 payload bytes and204 interaction
components and their finite-vocabulary rationale. These scalar capacities are not
actual byte audits or physical budgets. P09 must prove complete analyzer traversal
and supplied layout; the counter must supply its independent scalar pools/capture0.

Exact validation (after formatter):

```sh
scripts/format-swift.sh
ruby scripts/contracts/generate-spec-015-workload.rb --check
python3 scripts/contracts/check-spec-015-schema4.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmpwj8mqyyn/macos-static
python3 scripts/contracts/check-spec-015-schema4.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmpke3zvfyl/macos-dynamic
```

Both fresh routes compile complete HostConfiguration including Generated and pass
320 assertions each (187 lifecycle +133 workload-stage controls). Six missing-field
compiler controls reject; both host ownership negatives reject. Ten generator
missing-field controls and UInt16/UInt32 overflow controls reject; a70000-byte
UInt32 payload capacity generates without narrowing. Freshness and no hierarchy
input checks pass. Supplied unrelated actual storage is rejected, not recast as
analyzer backing. [Static receipt](schema4-macos-static.json) and
[Dynamic receipt](schema4-macos-dynamic.json) retain exact commands/hashes/logs.
The previously retained Generated initializer failure is resolved. Guard **0/2**.

Next: actual activation-time runtime/endpoint storage join, independent finite
counter composition using all nine existing validation stages, cache ticket and
replacement/lifetime controls, four builds and early linked images. T8.1,
HC-RD-001–004/package exit and P09–P12 remain open.


## Step 3 — activation-time storage join, stopped

Initial control and two unproductive repairs reject on the pinned compiler;
a diagnostic reduction without `activate()` still rejects. See the
[complete bounded record](activation-join-stop/stop.md). The shared P08 guard is
now **2/2**, with no reset from model switching, diagnostics or earlier component
success. Affected implementation has stopped; no failed join was copied into
maintained source. No new compiler controls or unsafe/lifecycle workaround were
selected. Current authority remains unchanged and no compiler-bug attribution
is established. Parent will arrange independent confirmation and a concrete
maintainer decision before further affected implementation. Remaining package
requirements and smallest bounded next decision are explicit in the packet.


## Separately authorized evidence-only investigation — 2026-10-11

Eugene replied “Agree, Please proceed” after independent stop review. The
[authorization and fixed hypotheses](activation-join-investigation/authorization.md)
reserve at most6 fresh compiler invocations and2 internal layouts, each requiring
positive initialization/activation/real supplying-scope caller plus separate copy
and outliving-backing negatives. All corrections count; negatives skip failed
positives; stop on first complete pass, budget exhaustion or2 unproductive
candidates. Initial counters0/6 invocations,0/2 layouts; no compile has run.
This allowance does not reset the historical2/2 production guard, authorize
integration or change any contract. Independent review and separate production
resumption remain required after the finite evidence result.


## Evidence-only investigation: raw result held for independent accounting

Authorization `0bc51d70` preceded all fresh compiles. Exactly2/6 invocations used
one layoutA; positive run1 failed caller setup, corrected run2 failed with mixed
activation lifetime/internal-copy/imported non-frozen caller diagnostics. No
negative or layoutB compile ran. The [raw result packet](activation-join-investigation/result.md)
preserves exact sources, full diagnostics, commands and hashes. Runner counted
both failed positives as2 unproductive candidate attempts; parent requires
independent interpretation because only1 layout was used and the approved guard
names candidate attempts. Current ledger hard-holds further compiler work;
exhaustion/continuation accounting is unresolved. Historical productionguard2/2
unchanged; no compiler bug/rootcause/feasible host or P08 pass is claimed.


## Evidence-only investigation: reviewed continuation and finite stop

Independent [accounting review](activation-join-investigation/accounting-review.md)
`c05e6d35` charged failed A conservatively1/2 and permitted only predeclared B's
positive with a caller-only correction under the original allowance. Invocation3
used unchanged B/Supplied and actual profile lending scopes in place; compiler
exit1 retains activation self-lifetime plus use-after-consume/internal-copy
failures. Imported-field partial-consumption diagnostics are absent; no isolated
caller pass or compiler-bug attribution follows. Exactly3/6 calls,2/2 layouts,
zero negatives/positive passes; conservative candidate guard2/2, production2/2
unchanged. No further compiles or implementation. The [finite result](activation-join-investigation/result.md)
preserves all diagnostics/hashes, original held receipt and accounting record.
Next: independent read-only final review and separate explicit resumption decision.
