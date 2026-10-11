# P07 coordinator associated-type decision packet

Status: **blocked for separate Strong review and human decision**. No amendment
in this packet is applied to a Specification or production protocol.

## Confirmed boundary

The prior approval covered three protocol-level `~Copyable, ~Escapable`
suppressions and expressly preserved associated requirements. That correction is
implemented at `2fe8a86e`; frame cleanup is independently repaired at `db78cf9c`.
The current SPEC-013 declaration still requires:

```swift
associatedtype Storage: RuntimeProfileStorage
associatedtype Handler: GiftUIActionHandler
associatedtype TargetAccess: ActionModelTargetAccess
    where TargetAccess.Model == Handler.Model
```

[Normative SPEC-013 declaration](../../../../../docs/specs/spec-013-runtime-profiles.md#module-contract)
(lines 568–595 at `027bdc11`) and
[production declaration](../../../../../Sources/GiftUIRuntimeCore/RuntimeCoordinatorContracts.swift)
(lines 13–18) agree. Associated types implicitly require Copyable. The existing
[StaticProfileStorage](../../../../../Sources/GiftUIRuntimeStatic/StaticProfileStorage.swift)
is explicitly noncopyable (line 166); it owns caller-supplied noncopyable regions.
The declaration cannot describe that actual storage as its associated Storage.
A copyable recipe or unrelated placeholder would not establish the required
actual storage relationship. No existing conforming recipe/view solves this;
introducing one would be a new representation/ownership decision, not forwarding.

The pinned Swift 6.3.2 compiler rejects both current conformance and the obvious
`associatedtype Storage: RuntimeProfileStorage & ~Copyable` edit: it reports
“cannot suppress 'Copyable' requirement of an associated type.” The generic
proof stores `S: RuntimeProfileStorage & ~Copyable` and a real model scope; it is
compile-only evidence, not an activation, resource or full-cycle test.

## Immediately adjacent requirements

| Requirement in this same protocol | Current finding / disposition |
| --- | --- |
| Self and inherited admission/opportunity protocols | Approved suppressions compile; actual model scopes and both existing wrappers pass current four-profile evidence. |
| Storage | Confirmed Copyable conflict above. Associated suppression is unavailable on pinned compiler. |
| Handler | `GiftUIActionHandler` still requires `Model: _GiftUIObservableReference` and a borrowed raw-model handler callback (SPEC-011 public declarations, line 243). This is the legacy interface, not the checked typed-operation bridge approved by the RFC-014 amendment. No standalone handler failure is claimed. |
| TargetAccess and `TargetAccess.Model == Handler.Model` | Confirmed actual `ObservableStateRootTargetAccess<M, UInt8>` cannot meet `ActionModelTargetAccess`. The actual target is `~Copyable, ~Escapable` and exposes generation-checked typed mutation, not `withCurrentModel`. This is not repaired by the prior three suppressions. |
| Endpoint / Endpoint.Sink | Remain `SynchronousFrameEndpoint` / `DrawingOperationSink`. Existing endpoints/sinks are copyable operational values; no immediate failure demonstrated. No suppression/removal proposed. Containing SPEC-015 host lifetime remains separate. |
| Inherited StateChangeFact / CompletionFact | Sendable finite facts; current fixture uses UInt8/UInt16. They do not carry model/read scopes. No change proposed. |
| Inherited OwnerFailure | Equatable/Sendable finite value; preserved exact failure carrier. No change proposed. |
| profile, storageAudit, executionContext, isQuiescent, quiesce | Ordinary value getters and mutating operation; no scoped return. All signatures preserved. |

The target discrepancy is independently grounded in
[SPEC-011's runtime amendment](../../../../../docs/specs/spec-011-interaction.md#rfc-014-runtime-amendment),
which requires dispatch through a checked typed write route, and
[SPEC-010's runtime amendment](../../../../../docs/specs/spec-010-observable-reference-state.md#rfc-014-runtime-amendment),
which governs exclusive checked writes and scoped ownership.
[ObservableStateRootTargetAccess](../../../../../Sources/GiftUIObservableState/ObservableStateRootTargetAccess.swift)
implements that route;
[RuntimeRecordInteractionBridge.dispatch](../../../../../Sources/GiftUIRuntimeCore/RuntimeRecordInteractionBridge.swift)
(lines 60–80) binds the actual target Model to `Model.Mutation`, validates action
and target generations, and calls the checked owner. It does not conform to the
legacy callback protocol. P03/P05 component evidence is not full P07 conformance.

## Concrete proposed correction for review

Remove exactly the Storage, Handler and TargetAccess associated requirements,
including `TargetAccess.Model == Handler.Model`, from the common coordinator
protocol. Do not replace them with another associated-type abstraction. Keep:

```swift
package protocol GiftUIRuntimeProfileCoordinator:
    ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner
{
    associatedtype Endpoint: SynchronousFrameEndpoint
        where Endpoint.Sink: DrawingOperationSink
    var profile: RuntimeProfileKind { get }
    var storageAudit: RuntimeStorageAudit { get }
    var executionContext: ExecutionContext { get }
    var isQuiescent: Bool { get }
    mutating func quiesce()
}
```

Retain the storage and checked-action relationships in the concrete coordinator
construction/generic joins: actual storage must still meet RuntimeProfileStorage
with noncopyable ownership and validated audit; the concrete model/root scopes
must share Model/Schema; the single finite Action domain must be preserved across
lowered declarations and dispatch; typed operation results must be Model.Mutation.
The existing checked bridge statically binds target Model and mutation type, and
its runtime checks preserve action/registration generations. The complete
coordinator/assembly proof for these relationships remains to be implemented and
reviewed; it is not supplied merely by the positive syntax proof.

Every operational signature, failure, phase, mutation/publication/offer order,
capacity, audit duty, cleanup obligation, and module-owned algorithm remains a
requirement. No public GiftUIActionHandler or ActionModelTargetAccess change is
proposed here, and no legacy raw-model callback is reintroduced into the new
path. Their historical controls remain. SPEC-015 host construction/activation
is outside this decision. No compiler upgrade or alternative ownership mechanism
is proposed.

This **is a contract amendment** because SPEC-013 explicitly lists these
associated relationships. It also changes where static guarantees are enforced:
a generic caller constrained only to the common coordinator protocol would no
longer be able to name Storage/Handler/TargetAccess or rely on their equality.
Repository search found no current caller using those associated members and no
production conformance to the full protocol, but this does not make the loss
meaningless. Review must decide whether concrete construction checks adequately
preserve the accepted owner boundaries; do not assume the change is automatically
architecture-neutral. If accepted ADR ownership/dispatch decisions require these
relationships specifically on this protocol, this proposal needs an upstream
architecture decision instead. Reapproving SPEC-013 alone must not silently
amend SPEC-011's public action contract.

The bounded alternative is to keep the exact contract and leave P07 blocked;
no safe compatible representation has been demonstrated. Broader alternatives
were not explored.

## Reproduction and limits

Run from repository root:

```sh
python3 Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/associated-type-proof/reproduce.py .build/contracts/spec-013-runtime-cycle/tmpuk4e29x5/macos-static
```

The script validates the pinned compiler and every selected module input against
the existing receipt before typechecking four committed sources. Its
[result.json](associated-type-proof/result.json) stores exact commands/hashes:

1. CurrentStorage: rejected because S is not Copyable.
2. UnsupportedSuppression: rejected because associated Copyable suppression is unsupported.
3. CurrentTarget: rejected because the actual scoped target does not conform to ActionModelTargetAccess.
4. ProposedOperational: compiles, storing actual model/target scopes and noncopyable storage under the proposed smaller protocol.

This is native compiler evidence only. The positive proof uses trap/no-op method
bodies to isolate conformance and makes **no** cycle, activation, audit, cleanup,
endpoint, handler, target execution or downstream feasibility claim. It is not
an actual-integration substitute. Exact historical blocker proof remains intact.

## Preserved implementation and remaining work

- `498720fc`: approved declaration amendment / human ledger before code.
- `2fe8a86e`: approved suppressions and actual scoped wrapper forwarding; four routes.
- `db78cf9c`: successful freeze cleanup obligation and real model-store regression;
  native 179 assertions and nRF compile/ABI; copy/escape negatives.
- `027bdc11`: honest WIP preservation of record-qualified workspace changes and
  tiny State/Button/Canvas fixture. Native source compilation passes, but the new
  workspace/presentation behavior is not exercised; cross-target proof pending.

Complete actual Dynamic/Static cycle, all-stage differential faults, accepted
Interaction commit/refusal retry, retirement, quiescence, full physical audit and
separate Strong package exit review remain open. No P08 work, no remote actions,
no package acceptance. Repair counter remains **0/2**; this is a newly confirmed
contract/compiler boundary, not two unproductive repairs.
