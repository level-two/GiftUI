# RFC-015 downstream contract acceptance and application — 2026-10-13

## Explicit maintainer provenance

Eugene replied to the concrete acceptance question for ADR-039 and the exact
Specification amendment packet: “Yes, accept them and commit. And then please
proceed with the p08”. The clean input was `f01ee97c`; this instruction accepts
the presented ADR-039 and approves packet **S11.1–S11.4**, **S13.1–S13.2** and
**S15.1–S15.2**, including all nine IN-SO/RP-SO/HC-SO criteria and the source
application instructions. It authorizes applying the derived plans and then
sequential SO-01 inventory and SO-02 physical design preparation.

The [reviewed downstream package](rfc-015-downstream-review.md) at `3640bb5e`
found no substantive blocker. The later [delivery allocation](rfc-015-delivery-allocation.md)
assigns full delivery to ITERATION-004 I4-07 and preserves only the necessary
dependency path with complete applicable safety/fit evidence in P08. That
allocation remains in force; acceptance adds no full-scope P08 commitment.

## Applied contract and derived records

- [ADR-039](../../adrs/adr-039-scoped-storage-ownership.md) is accepted without
  changing its decision or superseding earlier accepted ADRs.
- [SPEC-011](../../specs/spec-011-interaction.md) receives S11 verbatim before
  IN-RD-001; [SPEC-013](../../specs/spec-013-runtime-profiles.md) receives S13 and
  [SPEC-015](../../specs/spec-015-host-configuration.md) receives S15 before their
  runtime Amendment acceptance criteria. The [exact packet](rfc-015-spec-amendments.md)
  remains the immutable text comparison source for these sections.
- The [shared RFC-014 plan](rfc-014-implementation-plan.md),
  [task context](rfc-014-task-context.md) and three owner plans adopt the
  [handoff](rfc-015-p08-handoff.md)'s ordered tasks, criterion mapping, physical
  design checklist and P08/I4-07 dependency test. The physical design note is
  linked from owner metadata only after it exists.
- The feature manifest records this accepted/applied state. No implementation
  criterion or existing task is closed; Specs stay implementing and plans active.

## Execution and evidence boundary

The [P08 receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md#approved-contract-application-dispatch--2026-10-13)
records the documentation dispatch before edits. SO-01 and SO-02 follow in
separate recorded steps; physical design requires independent Strong review
before presenting concrete source/commands/attempt limits for authorization.
The acceptance instruction supplies no new bounded production validation or
repair allowance. SO-03–09 remain blocked on that separate recorded allowance
and their ordered prerequisites. No production source, compiler, build,
experiment, deployment, flashing or connected validation occurs in this step.

All historical counters, stopped attempts and the two-consecutive-unproductive
guard remain intact. The last qualified construction result remains 58,648
bytes against 27,648; four-route/link passes do not establish stack fit. All
nine new criteria, HC-RD-003 and P08/R07/T8.1 remain open. P09–P12, remaining
timing/hardware obligations and human implemented transitions remain separate.
No exception, workload reduction, new compiler, ceiling change or generalization
is approved. FW-037 retains its separate ITERATION-004 I4-06 assessment.

## Subsequent bounded applicability and execution acceptance — 2026-10-13

At clean `18504c6b`, Eugene accepted the independently reviewed narrow analyzer
applicability disposition and concrete SO-03 next step: “If they will be addressed
in the scope of next iteration then yes, let’s keep them and proceed”. He added:
“The same is for other similar places”. The [allocation amendment](rfc-015-delivery-allocation.md#accepted-pre-existing-integration-gap-disposition--2026-10-13)
and [receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md#so-03-applicability-and-allowance-documentation-dispatch--2026-10-13)
record exact boundaries. Preserve the two unchanged legacy factories; missing
actual analyzer model/root/target/factory integration and owned-return evidence
are mandatory ITERATION-004 I4-07 work with the existing P09 integration handoff.
SO-03 validates shared owned interfaces/all six operation consumers with one
native driver invocation, zero automatic repairs, then independent result review.
SO-04–09 remain proposed and unapproved. Analogous pre-existing gaps outside
selected counter dependency/safety paths receive exact mandatory next-iteration
residuals without another identical permission request; necessary counter safety/
fit, new regressions/shared breaks and architecture remain outside that disposition.
No adopted contract text, criterion status, historical allowance or guard changes.
