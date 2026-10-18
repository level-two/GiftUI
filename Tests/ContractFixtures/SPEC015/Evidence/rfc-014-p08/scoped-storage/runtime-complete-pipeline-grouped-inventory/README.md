# RuntimeCompletePipeline — bounded grouped inventory and correction proposal

**Read-only, ready for independent design review; no source candidate or new
repair allowance approved.** Fixed source22eea103 and all573 frozen inputs verify.
[Receipt](read-only-receipt.json). No source/compiler/decoder/runtime experiment
occurred. [85e1f676 evidence](../runtimecore-consumer-result/README.md) and
[dd43fde3 independent boundary](../p08-runtimecore-consumer-independent-review.md)
remain unchanged. SPEC-006/010/013/015 are implementing; approved ADR-036/039/040
and ITERATION-003 I3-04/I3-05 govern this reference Counter/host validation.
This is derived internal-realization work, not acceptance or a contract amendment.

## Cause established from the matched compiler

[Exact source/hashes/excerpts](matched-compiler-rule.json) pin Swift6.4 commit
b8189d766d86ad7fc8106787d6ce9e402f38dd72. Decl.cpp5470–5502 takes the minimum
adjusted access of a declaration and its enclosing nominal. `run` already has
`@inlinable`/`@inline(__always)`, but enclosing package RuntimeCompletePipeline
has no ABI qualification. Its formal scope therefore stays nonpublic.
DeclContext.cpp587–605 returns non-fragile for a nonpublic formal scope **before**
honoring the inline annotation. That produces maximal resilience expansion;
SILDeclRef.cpp1069–1074 does not serialize it. This explains the observed physical
FunctionID611/bit1118229/serializedKind0/zeroBB and effect-summary-only consumer
body, not merely a size-threshold hypothesis. Qualifying only the parent would
then expose the full body's source-access errors; the complete grouped dependency
map below is necessary. Repeating the existing method annotation is a no-op.

## Proposed root/helper source boundary

[Exact correction map](correction-map.json): **50 existing declaration edits plus
three explicit internal memberwise-equivalent initializers,53 sites in six files**.
Every existing declaration location/hash is checked; all edits are proposals only.

| File | Finite purpose |
| --- | --- |
| RuntimeCore/RuntimeCompletePipeline.swift | ABI parent/protocol/result/signature nominals; publication.changed; generic failure-record fields; serialize three private generic helpers as internal; ordinary internal ABI cleanupStage; three constructor equivalents. Existing run/bodyless requirements receive no edit. |
| RuntimeCore/RuntimeCoordinatorCleanup.swift | Exact cleanup enum/OptionSet/plan/oracle/tracker signature types; rawValue/init and nine used flags; ordinary ABI oracle.plan and tracker init/takeNext. Private tracker outstanding/take and Actions.action/contains remain private/ordinary. |
| Execution/RunCycleValues.swift | SemanticCycleDisposition and PresentationIntentState nominal ABI only. |
| Execution/FrameHandoffValues.swift | LogicalFrameDisposition nominal ABI only. |
| Execution/WakeValues.swift | ExecutionWakeReasons, rawValue/init and only semanticDirty/presentationPending flags. admittedWork excluded. |
| GiftUI/GiftUI.swift | PresentationRevision nominal ABI only; rawValue/init excluded. |

`finishOfferWithoutCommit`, `fail` and `cleanup` are generic on Owner; their
bodies must be available with the root. `cleanupStage`, oracle.plan and tracker
init/takeNext are ordinary nongeneric ABI calls; their implementations need not
serialize. Do not promote unrelated fields because a nominal is reached.
The three new constructors preserve existing synthesized **internal** memberwise
access/ownership/labels/order and every assignment: Disposition's six required
fields; Completion's four fields, including required Optional
committedPresentationRevision and operational; generic FailureRecord's four fields,
including required Optional publication. No parameter has a default.
The two nongeneric initializers are ordinary ABI; only the generic FailureRecord
initializer is serialized, with its four stored fields separately qualified.
Matched CodeSynthesis.cpp134–138 returns for let-backed properties before the
Optional nil branch at170–182. All these fields are let; the initial proposed
three nil defaults were incorrect and are removed before any source candidate.
Independent recheck remains required; the scope stays53sites/sixfiles.
No pointer/scope/capability constructor, validation or algorithm is introduced.
Existing checked factories, all other defaults and bodies remain byte/token exact.

## Owner implementations and separate latent stage frontier

[Compatibility inventory](compatibility.json) covers the exact protocol-reference
search. Matched TypeCheckProtocol.cpp1910–1937 demands ABI witnesses only when
**both** protocol and conforming nominal are formally public after ABI adjustment.
Current CounterPipelineOwner is internal/nonABI; its16 witnesses and private
geometry/interaction/runtimeClaim fields therefore require no ABI widening.
The Pi initial-presentation owner is package/nonABI too; its extension conformance
is outside current registered25/42. No Pi edit or compile PASS is claimed.
Legacy constrained Static/Dynamic profile bindings also remain excluded from the
canonical8/13 composition. Preserve these distinctions in future compatibility checks.

[16-owner stage frontier](owner16-stage-frontier.json) records direct current SIL
references, not a lexical type sweep:23 distinct project-generic declarations have
no local basic blocks, across interaction key state, observable root/model operations,
semantic storage/traversal/binding, Canvas codec/transfer and action generations.
Typed-error runtime calls are recorded separately, not treated as missing Swift
serialization bodies. **None of these23 is added to the six-file edit proposal.**
Their current generic-stage references do not prove each survives future concrete
specialization or requires serialization rather than a valid ordinary ABI leaf.
They are known review/validation obligations, not hidden future one-symbol fixes.
Before extending any source scope, group surviving actual-concrete edges with their
reached private callees/signatures and metadata/cost evidence. The53-site proposal
addresses the proven run/helper availability boundary; it guarantees neither all42
closure nor strict cold conformance. Independent review must assess that limited
feasibility boundary and the separate latent frontier together.

## Guardrails and validation proposal

[Focused gate proposal](validation-proposal.json) requires independent design and
explicit source/budget authorization before edits. No previous exhausted activity
is reset. GiftUI ABI changes require all25 fresh registered owners, canonical8
Static/13 Dynamic/42-source host and pinned flags; collect all independent compiler
failures, block dependents, never auto-repair/stale-import. Then normal-import
privacy positives/isolated negatives for helper/constructor boundaries, previous22
controls, physical run+three-helper bodies and six retained roots, actual concrete
SIL/object/16-stage/private-callee/continuation/destruction review. Body availability
is not specialization. OptionSet literal/static flags, Optional paths, synthesized
witnesses and optimizer decisions remain explicit compiler/codegen uncertainties.

Approved [S13.1](../../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
and [S15.1](../../../../../../../docs/specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement)
keep concrete P08 tokens/accesses/session/inventory/supplied/pipeline/retired
construction and coordinator admission/opportunity private setters unchanged.
Authored _model, original State references,14 physical loans, complete Optional/
lifetime unions, provenance/exclusivity, failure order and backing-last cleanup
remain exact. No public/package unchecked helper, ownership/representation change,
enforcement/flag matrix or observer exemption is selected. No architecture/contract
change was needed for this proposed internal ABI realization; any contrary result
must route upstream rather than weaken a gate.

All42/private-callee/State structural-borrow/metadata/TLS/context/observer coverage,
full native384 lifetime/Optional/provenance/exclusivity/failure-cleanup controls and
strict host-first cold/reuse remain unqualified. Only complete safety/codegen PASS
permits unchanged cold windows/counts/baselines. Key-failure first-use costs remain
unmeasured. Compile25/selected22privacy/sixbody PASS is retained; source candidate/
combined overlay/P08/R07/T8.1 remain unaccepted. Protected external five/pycache
verify unchanged. No deferred artifact is created: these are required current gates.
