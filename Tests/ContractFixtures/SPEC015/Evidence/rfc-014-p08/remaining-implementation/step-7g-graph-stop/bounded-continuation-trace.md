# Step7g bounded continuation — dependency trace before implementation

2026-10-12. Entry `87b6a0bf`, clean worktree. The user explicitly replied
“Please proceed” to the previous final's bounded continuation. This authorizes
first a complete dependency trace and review, then only the two whole-coordinator
borrowing projection replacements and activation call sites, and one invocation
of the native counter gate with no automatic repair or rerun. New allowance
**0/1**; the prior conservative **2/2** stop remains closed and recorded. No source
edit or compiler invocation has occurred under this allowance at this checkpoint.
The last validated source remains `48a987cd` (1,348,627 assertions / 23 controls).

The implementation-executor and deferred-work-curator skills apply. The current
question is necessary for graph correctness and cannot be deferred as optional
work. SPEC-015 remains implementing, plan active, T8.1/P08 incomplete.

## Authority and exact trace rules

SPEC-015 lines791–800 require all eighteen roles exactly once and the exact
compiler-visible direct dependency records, with no self, upward, unknown or
prohibited edge. Lines802–816 require inert factories and their exact validation
projections. Lines1118–1126 name live construction and activation duties. The
independent stop review requires a role-to-owner/factory trace and explicitly
rejects limiting dependencies to retained references. Therefore parameterless
initialization alone does not remove a concrete typed operation dependency.
Conversely, sharing physical storage is not automatically a constructor edge;
the exact selected symbol and supplied value must be identified.

## Compiler-visible role and factory trace

All fixture source paths below are under
`Tests/ContractFixtures/SPEC015/RuntimeDerived/` unless otherwise named.

| Role | Exact selected symbol / explicit inputs | Trace disposition before review |
| --- | --- | --- |
| runtimeProfile0 | StaticCounterProfileStorage / DynamicCounterProfileStorage; typed scoped model/root/semantic/value/geometry/Interaction/control backing and exact RuntimeStorageAudit | Storage is supplied before validation. No other live role is a constructor argument. Audit layout code references endpoint/coordinator types for byte accounting; this is not live endpoint construction. |
| textResourcePackage1 | GiftUIReferenceTextResources.targetPackage; GiftUIReferenceTextMetricsView / GiftUIReferenceTextRasterView | Concrete immutable package/views, no live peer inputs. |
| renderProducerContribution2 | CounterHostAssembly.validate: .renderProducer(operations, operationStream) | Exact inert constants, no live peer inputs. |
| rasterBackendContribution3 | Same function: .rasterBackend(primary: realization, alternate:nil) | Exact inert realization, no live peer inputs. |
| surfaceDisplayContribution4 | Same function: .surfaceDisplay(extent, encoding, lifetime, handoff, region/byte bounds) | Exact inert constants, no live peer inputs. |
| hostResourcePolicyContribution5 | Same function: .hostResourcePolicy(byte ceilings, allowed/preferred realization/encoding) | Exact inert constants, no live peer inputs. |
| rasterEndpoint6 | CounterEndpoint.init(configuration:control:), CounterNativeRasterAdapter.init(configuration:control:), CounterNativeEndpoint.init(...textMetrics:textRaster:...) | Supplied profile control0, selected text1, resolved exact configuration from contributions2–5. All these origins must be retained in the trace; actual endpoint checks remain. |
| applicationExecutor7 | CounterApplicationOwners.gate: HostApplicationOpportunityGate.init(), begin/complete/quiesce | The gate is the actual sole serialization state used by startSource; not the enclosing aggregate. The gate constructor has no peer input. The aggregate init(control:) retains profile control0 and initializes source8/repository9/useCases10; treating that aggregate itself as executor7 would introduce forward edges and cannot be silently substituted. |
| signalSource8 | CounterFactSource.init(); start(deliver:), service(value:deliver:), stop() | Scalar finite synchronous source; no autonomous timer/transport. Typed callback arguments are UInt8→Bool, with no concrete peer owner type. Its source→repository composition is performed by useCaseSet10. |
| signalRepository9 | CounterFactRepository.init(); observe/detach/receive(_:notify:) | Scalar owner and exact token, no concrete source argument; notify is UInt8→Bool. |
| useCaseSet10 | CounterFactUseCases.init(); start(source:inout CounterFactSource, repository:inout CounterFactRepository, deliver:) | Direct typed dependencies source8 and repository9 are present despite no retained references. Current zero dependency mask is incomplete. The delivery closure is constructed by the enclosing composition, not retained or concretely typed as CounterAdmission by this role. |
| factAdmission11 | CounterAdmission.init(control:limits:), CounterQueuedFacts(control:); submit and synchronize | Explicit stable profile control0 + ExecutionLimits. submit calls CounterControl.emitCounterWake synchronously through that supplied control; role16 ownership is in the same physical control. Must not represent a stored requester or second accumulator. |
| actionDomain12 | CounterAction enum in Counter.swift | No peer input. |
| actionHandler13 | CounterHandler.operation(_ action:CounterAction) -> CounterOwnedModel.Mutation in CounterModel.swift | Direct actionDomain12 dependency. The concrete model mutation return type also needs explicit role disposition; see unresolved mapping below. |
| rootModelTarget14 | ObservableModelScope<CounterOwnedModel,...>, ObservableStateRootScope, actual registration/modelKey/target access in CounterHostState and CounterPipelineOwner | Explicit profile backing0 and model/schema types; root.belongs(to:models) checked at existing initializers. Model declaration versus actual registration/target role membership is unresolved for the handler return type. |
| normalizedInput15 | CounterControl.inputGate = HostNormalizedInputGate(configuredSource:InputSourceID(0)); submit(...to:inout CounterAdmission) | Gate constructor has concrete source value, no profile-storage input. Actual submit has direct admission11 dependency; current profile0-only mask does not record that typed operation. Physical location alone is not proof of a dependency. |
| wakeRequester16 | CounterWake.init()/requestWake(for:); CounterControl.initializeCounterWake(); establishCounterScheduler(report:HostAssemblyReport) | Checked pointer-free recorder, one canonical accumulator, scheduler from immutable validated report. Exact profile-backed integration0 is visible; no retained application executor/runtime callback. Report is validation output, not another live component role. |
| residualPolicy17 | FixedMVPHostResidualPolicyTable(fatalHookIsAvailable:false) | Concrete finite policy, no peer input. |

## Unresolved role mapping — stop before dependent source edits

CounterHandler.operation visibly names CounterOwnedModel.Mutation in its result.
The existing inventory maps rootModelTarget14 to scoped model registration and
target access, while SPEC-015 activation step2 also names the model. There is no
separate model role in the fixed eighteen-role enum. If the model declaration is
part of role14, the handler's exact compiler-visible type dependency is13→14,
which is a forbidden upward edge. If role14 is only the live registration/target
factory and the model declaration belongs to a different already-approved
component contract, that distinction needs explicit authority and must not be
invented merely to pass graph validation. The trace does not declare a contract
bug or choose either interpretation.

Parent review is requested before projection edits or the single compiler gate.
The gate-vs-aggregate distinction and source/repository typed use-case dependencies
are now explicit. No mask has been changed to hide an edge. Further questions
about transitive storage field types versus component factory inputs must be
resolved using the approved graph contract, not by omitting actual dependencies.

## Proposed gate after trace acceptance

Only after the trace is accepted and any actual conflict resolved: replace only
the two new borrowing helpers and their activation call sites with existing
controlPointer projections; keep initializer root/model association and prior
cache-lifetime proof, actual application and endpoint checks. Format, then invoke
exactly once:

```sh
python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static
```

No repair/rerun, compiler change, unsafe conformance, target build or P08 pass is
authorized by this allowance. Freeze outcome and stop for independent review.

## Independent trace review disposition — current stop

The parent supplied sequential independent read-only Strong review conclusions
after this trace checkpoint (`fca0a3a9`), with no implementation or compiler work:

- Executor7 is the actual gate, not the enclosing composition aggregate; no peer
  dependency for its parameterless constructor.
- UseCaseSet10 has direct typed source8/repository9 dependencies. NormalizedInput15
  has direct admission11 dependency; physical placement does not imply profile0.
- CounterOwnedModel.Mutation is shared value vocabulary. The handler owns or
  accesses no root instance, model key, registration or target; coordinator
  separately supplies handler and target access to dispatch. SPEC-015 line1119
  names model, handler and target separately. Keep handler13→actionDomain12; no
  handler13→rootModelTarget14 edge is established by the mutation result type.
- **Current realization conflicts with the accepted direct operational dependency
  trace:** CounterAdmission.submit invokes emitCounterWake on canonical role16.
  Thus factAdmission11→wakeRequester16 is a forbidden upward edge under
  SPEC-015 lines791–800. Indirection through profile-backed CounterControl does
  not erase the behavior identity. Omitting it would be inconsistent with the
  accepted use-case and normalized-input operation edges.

The implementation-executor skill requires affected work to pause on a contract
or scope defect and forbids reinterpreting the Specification to fit existing
code. The concrete [decision packet](graph-boundary-decision.md) proposes a local
implementation relocation or a separately reviewed Specification amendment.
Neither is approved or implemented. Current stop is this graph-boundary conflict,
before the two projection replacements or compiler invocation. New allowance
**0/1** unused; historical **2/2** remains closed. No compiler failure occurred
under the new allowance, and no new compiler defect is inferred.
