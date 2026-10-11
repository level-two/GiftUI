# RFC-014 P08 execution receipt — 2026-10-11

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
