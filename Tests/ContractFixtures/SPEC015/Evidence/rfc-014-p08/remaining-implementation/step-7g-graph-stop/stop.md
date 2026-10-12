# P08 step7g — bounded graph projection stop

2026-10-12 sequential Strong Sol6.1 High. Last validated implementation48a987cd: canonical wake controls pass1,348,627assertions/23controls. This attempted graph slice is not validated. No target builds started.

ww2ukmjc failed pinned Swift6.4 counter-model SILGen with `can't set insertion point to a null instruction`, at CounterHostState.constructedRuntimeProjectionIsValid. The helper borrows the retained noncopyable enum and projects actual coordinator/model/root/cache/admission/wake state. Preserve full command, crash/backtrace and proposed changed fixture inputs.

One bounded repair removed nested noncopyable Optional-cache inspection, already covered by prior retained-cache lifetime proof, retaining actual root/models/admission/wake/endpoint checks. fbi5sbvm failed with the same assertion, stage and function, without passing or narrower evidence. Under conservative resumed repair accounting this reaches2/2. No third compile, new compiler, unchecked conformance, weakened expected value or contract change. Historical closed guards remain closed. Proposed source edits are intentionally preserved uncommitted; this packet commits only review evidence.

## Proposed construction inventory for review

The proposed graph replaces the fabricated predecessor chain with direct factory construction requirements. It remains an unvalidated proposal pending independent inspection. Runtime callback direction does not imply retained constructor dependency. A required forward construction dependency must be escalated, never omitted to satisfy ordering.

| Role | Actual factory/value | Proposed direct construction roles |
| --- | --- | --- |
| runtimeProfile | StaticCounterProfileStorage / DynamicCounterProfileStorage + exact audit | none |
| textResourcePackage | GiftUIReferenceTextResources.targetPackage | none |
| renderProducerContribution | CounterHostAssembly.validate renderProducer contribution | none |
| rasterBackendContribution | same assembly rasterBackend contribution | none |
| surfaceDisplayContribution | same assembly surfaceDisplay contribution | none |
| hostResourcePolicyContribution | same assembly hostResourcePolicy contribution | none |
| rasterEndpoint | CounterEndpoint / actual CounterNativeEndpoint from resolved configuration, text and profile bytes | runtimeProfile,textResourcePackage,four contributions |
| applicationExecutor | actual CounterApplicationOwners.gate:HostApplicationOpportunityGate | none |
| signalSource | CounterFactSource owner-free value constructor | none |
| signalRepository | CounterFactRepository owner-free value constructor | none |
| useCaseSet | CounterFactUseCases owner-free value constructor; explicit synchronous source/repository arguments | none |
| factAdmission | CounterAdmission / wake-free state over CounterQueuedFacts stable typed backing | runtimeProfile |
| actionDomain | finite CounterAction generated enum | none |
| actionHandler | CounterHandler.operation total over CounterAction | actionDomain |
| rootModelTarget | scoped root/model registration/target access | runtimeProfile |
| normalizedInput | one HostNormalizedInputGate in physical profile control | runtimeProfile |
| wakeRequester | one ExecutionWakeAccumulator<CounterWake> and scheduler in physical profile control | runtimeProfile |
| residualPolicy | FixedMVPHostResidualPolicyTable(fatalHookIsAvailable:false) | none |

Actual activation projection proposed checks actual source.running/emission count, repository exact observation/publication, use-case start count, application gate/flags, retained root/models, one admission state/canonical scheduler and exact constructed native endpoint. Eight malformed graph views derive from the same real table. Those additions failed before executable emission and are not claimed passing.

## Narrow independent-review option

The optional new borrowing helper is the failing compiler shape. Existing scoped/direct pipeline initializers already precondition exact root.belongs(to:models). Existing proven controlPointer getter and actual physical hasRoot/committedRecords/admissionController/wake/scheduler projections may support a separately reviewed construction check without borrowing the entire coordinator again. This is an option for independent review, not an implemented third repair or an upstream contract blocker. Preserve prior cache ownership proof at its exact boundary.

Graph validation, final four registered routes and early linked ARMv6/nRF grossRAM/stack/allocator/ABI evidence remain open. No P08 exit, analyzer migration, conformance pass or implemented transition.
