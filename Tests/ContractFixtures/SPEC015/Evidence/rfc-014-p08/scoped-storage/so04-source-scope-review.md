# SO-04 source scope independent Strong review — 2026-10-14

**CONFIRM THE BOUNDED SCOPE STOP.** Sequential independent review
`so04_scope_review`, Sol 6.1 High, clean input `97f1fe3b`; no subagents.
The [checkpoint](so04-source-scope-stop.md) identifies a necessary unlisted
conformance boundary in the [authorized packet](so04-source-execution-proposal.md).
This is source evidence, not a demonstrated compiler failure. No source, driver
or generator edit, compiler/build/executable/debugger/IR/image/formatter/target
invocation or corrective pass occurred in this review.

## Authority and coverage

Accepted [ADR-039](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md)
and approved [S11/S13/S15](../../../../../../docs/iterations/iteration-003-review/rfc-015-contract-acceptance.md)
govern. SPEC-011/013/015 remain implementing, plans active. ITERATION-003
I3-04/I3-05 requires finite-counter/four-stack safety and storage evidence,
preserving ITERATION-001 analyzer/stack compatibility; full analyzer integration
remains I4-07/P09. This review covers the extension default requirements, its
actual callers and same-boundary inventory only, not the unimplemented migration.

| Inspected area at `97f1fe3b` | Finding |
| --- | --- |
| `CounterPipelineOwner.swift`:115–116 | G/C/R/H are currently owned; SO-05 must apply S15.1's complete suppressions. |
| `CounterAdmission.swift`:13–72 | Sole opportunity/quiescence conformance; no generic suppressions; absent approved file list. |
| `CounterHostOwner.swift`:32–37, 91, 164–166; `CounterDynamicHostOwner.swift`:14–19, 105–107 | Both selected host routes use this pipeline as coordinator Opportunity; other pipeline extension is already within SO-05 scope. |
| Static coordinator:20, 93–98; Dynamic coordinator:18, 91–96 | Opportunity requires both protocols and both suppressions; profile extensions already preserve the suppressed boundary. No coordinator change identified. |

## SS-01 — necessary extension boundary, inference supported

[SE-0427, concrete extensions](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0427-noncopyable-generics.md#struct-enum-and-class-extensions)
explicitly defaults each extended generic parameter to Copyable independently
of a base declaration's suppression. [SE-0446, generic contexts](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0446-non-escapable.md#in-generic-contexts-escapable-suppresses-the-default-escapable-requirement)
applies the suppressible-generic rules to Escapable independently of Copyable.
These primary language sources were read on 2026-10-14; they are corroboration,
not pinned Swift 6.4 output. The existing coordinator extension clauses and
S11 conditional-owned clauses provide repository-local corroboration.

Consequently, after the planned base/protocol changes, leaving this extension
unchanged restricts the conformance to owned G/C/R/H, excluding the intended
noncopyable/nonescapable accesses. The fact that the owner itself is already
~Copyable/~Escapable does not remove those parameter defaults. Current owned
counter routes and prior SO-03 fixture passes do not exercise the proposed scoped
CounterPipelineOwner instantiation and are not contrary evidence.

The extension witnesses access control, phase, recovery and owned result facts;
they do not directly extract/return geometry or Interaction fields. They invoke
`runTracedPipeline()` and `terminatePresentation()` on the base owner. No witness
body change is identified by this inspection. Their eventual usability with the
new base/access realization, exact syntax and target behavior remain unproved.

## Smallest decision and inventory

Add only `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterAdmission.swift`
to SO-05's source boundary, restricted to this conformance clause:

```swift
extension CounterPipelineOwner: ExecutionOpportunityRunner, RuntimeOpportunityQuiescence
where Geometry: ~Copyable & ~Escapable,
      Candidate: ~Copyable & ~Escapable,
      Committed: ~Copyable & ~Escapable,
      Hits: ~Copyable & ~Escapable {
```

Inherited protocol/Identity constraints remain. This is adequate for the known
extension-default obstacle, conditional on the already approved base/protocol
migration; it is not proof that the whole source package compiles. Bodies,
admission/wake logic and workload remain outside this added permission. Any new
necessary change still stops under the packet's zero-repair rule.

Repository source/generator inventory found exactly the two pipeline extensions
listed above; no additional predictable unlisted extension on the affected owner
or supplied generic carriers was found. `CounterWakeIntegration.swift`:79 extends
nongeneric CounterHostControl. Owned measurement/storage extensions are separate
and their relevant files are already listed. The counter driver already includes
CounterAdmission.swift in its source list; this finding needs edit-scope permission,
not a newly discovered source-registration path. Inventory does not accept future
carrier bodies, lifetime unions, private initialization or negative labels.

## Disposition and limits

This is a productive, bounded source discovery: it localizes a concrete missing
file permission before any initial source realization. It is not a failed compiler
attempt, source completion or consumed repair. Preserve every historical counter
and the cumulative two-consecutive-unproductive guard; this classification grants
no reset or new allowance. SO-04→06 remain stopped and incomplete pending the
maintainer's exact scope decision; the independent coherent-migration review is
still required after realization. No ADR/Spec amendment, exception, status change
or new deferred item is indicated by this constraint-only finding.

All nine SO criteria, HC-RD-003/P08/R07/T8.1, the 58,648-vs-27,648 failure,
I4-07/P09–P12 and timing/hardware obligations remain open. SO-07/08 compiler/image
allowances remain separately pending. Documentation validation is recorded in
the [shared receipt](../progress.md#so-04-independent-source-scope-review--2026-10-14).
