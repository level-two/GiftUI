# P07 concrete coordinator constraint boundary — 2026-10-11

**Affected integration stopped for an exact contract decision.** P07 has not
passed. This is not deferred work, an accepted amendment, or authorization for
another experiment. The independent limits/audit and internal runner slices
are committed at `2935fb73` and `bbc753e5`.

## Demonstrated issue

The approved P03 model/root owners and P04/P06 record/Canvas owners lend
noncopyable, nonescapable scopes for their activation lifetimes. A concrete
coordinator inside that activation must preserve those scopes while accepting
work and running multiple opportunities. The minimal probe stores the real
`ObservableModelScope<Model, Schema>` and implements the exact admission and
opportunity signatures. It contains no mock model scope or pointer lifetime
substitute.

The current `ExecutionAdmissionSink` and `ExecutionOpportunityRunner` require
`Copyable` and `Escapable` implicitly. The compiler rejects the scope-bearing
coordinator. Evidence-only shadow protocols demonstrate the two constraints
independently: suppressing only Copyable still rejects Escapable; suppressing
both permits the same coordinator and scoped construction/calls.

The existing owner factories cannot simply be called independently for each
stage/opportunity: `withObservableModelScope` finishes activation and destroys
remaining models on callback exit; `withRoot` retires associations; semantic and
staged-value factories end their lent storage lifetimes. Replacing these scopes
with escaping borrowed pointer descriptors would discard the approved ownership
proof. No such workaround or new ownership architecture was attempted.

## Authority distinction

- [SPEC-009 exact declarations](../../../../../docs/specs/spec-009-execution-cycle-and-frame-handoff.md#admission-and-action-capture-views):
  lines 612–627 explicitly spell `package protocol ExecutionAdmissionSink` and
  `package protocol ExecutionOpportunityRunner` without either suppression.
- [SPEC-013 declarations](../../../../../docs/specs/spec-013-runtime-profiles.md):
  lines 565–579 explicitly make `GiftUIRuntimeProfileCoordinator` inherit both.
  Its current declaration also retains implicit Copyable/Escapable requirements.
- [ADR-036 ownership](../../../../../docs/adrs/adr-036-scoped-model-access-and-bounded-ownership.md)
  and the approved SPEC-013 **Cycle and retirement order** require actual backing
  ownership across body/Layout/draw, separate registration retirement, and
  quiescence before backing release. Raw descriptor copying is not that proof.
- The internal `RuntimeCompletePipelineOwner` inheritance is *not* specified
  exactly by SPEC-013's Shared pipeline failure and mutation seam; its associated
  failure/result shapes and behavior are. Allowing lexical internal owners in
  `bbc753e5` is therefore an implementation repair. It does not amend the
  explicitly declared Execution protocols above.
- SPEC-015's `MVPHostInstance: ~Copyable` (lines 739–747) remains implicitly
  Escapable, and its construction/activation text governs the containing host
  lifetime. P08 must align that boundary if a scoped host is selected. This
  packet does not claim to prove its entire construction route or authorize
  changing it through an implementation note.

## Reproduction and limits

From the repository root:

```sh
python3 Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/scoped-coordinator-proof/reproduce.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp79wv0dbn/macos-static
```

The script checks every source/artifact hash in the pinned runtime receipt,
uses its exact Swift 6.3.2 compiler and flags, and saves complete commands/logs.
The production protocol source and normative Spec declarations remain unchanged.

| Probe | Result |
| --- | --- |
| `Current.swift`, actual Execution protocols, actual ObservableModelScope | Compile rejects Copyable inheritance in both protocols |
| `CopyableOnly.swift`, evidence-only suppression of Copyable | Compile rejects Escapable inheritance |
| `Proposed.swift`, evidence-only suppression of both constraints | Compile succeeds with unchanged fact/result signatures |

See [result.json](scoped-coordinator-proof/result.json),
[commands](scoped-coordinator-proof/commands.txt), and
[all three sources and diagnostics](scoped-coordinator-proof/).
This proves the concrete language/contract seam, not runtime integration,
cleanup correctness, linked resource bounds or a completed package. The first
reproduction script expected Swift to diagnose both inherited constraints in
one pass; Swift reported Copyable first. Splitting the two shadows narrowed
that diagnostic assumption and produced the expected three results. No
production repair was attempted on the blocked seam. Counter remains **0/2**.

## Smallest decision options

1. **Approve a narrow coordinated contract correction for scoped coordinators.**
   Permit these exact constraints, preserving all current associated types,
   method arguments/results, admission semantics and failure/disposition rules:

   ```swift
   package protocol ExecutionAdmissionSink: ~Copyable, ~Escapable { /* unchanged */ }
   package protocol ExecutionOpportunityRunner: ~Copyable, ~Escapable { /* unchanged */ }
   package protocol GiftUIRuntimeProfileCoordinator:
       ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner
   { /* unchanged members */ }
   ```

   Generic callers and the concrete coordinator wrappers must propagate the
   suppressed constraints only where they carry these scoped values. Existing
   copyable/escapable conformers remain permitted. Review SPEC-015's containing
   instance/factory lifetime at the same contract boundary before P08 relies on
   it; no host API is silently changed here. This option implements the accepted
   lexical ownership direction; it is not a new runtime profile or lifetime
   fallback. The normal Spec amendment/reapproval gate still applies.

2. **Retain the exact Copyable/Escapable coordinator contracts.** Keep P07's
   concrete join stopped and return the conflicting ownership realization
   upstream. This packet supplies no safe alternative that preserves the
   approved lexical scope proof and all current lifetimes under those exact
   constraints. Do not treat a copied raw pointer or a shared recording bridge
   as completion.

The finite P07 exit still needs actual Dynamic/Static activation/cycle owners,
phase and fault transcripts, publication/refusal/retry/bank-reuse/teardown and
exactly-once cleanup evidence, then separate Strong review. T11.1 remains open
through P10–P12. P08 has not started.
