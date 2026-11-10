# SPEC-006 package-surface decision and implementation receipt

Status: **approved bounded clarification; derived checks and Semantic Core/Drawing test migration validated; full P10 conformance remains unmet**.

## Human approval — 2026-11-10

Eugene approved both bounded changes: “Approve both bounded changes. Have the
weaker coordinator apply them, update the governing docs, commit, and continue
the remaining P10 work autonomously. Involve yourself only for genuine
decisions.” This authorizes only the SPEC-006 clause and exact derived
inventory/check/test changes described below, plus the separately named
`DynamicRuntimeProfileBinding` I4-07 transfer in the P10 record. It does not
authorize further Semantic Core SPI, a second traversal engine, changes to
limits or failure/binding semantics, or broader P08 reuse.

The recommendation, candidate wording, and “no changes made” statements below
preserve pre-approval analysis. They are historical decision evidence and are
superseded by this approval and the post-approval status at the end of this
record.

## Authority and exact discrepancy

- **Accepted authority:** `docs/specs/spec-006-declarative-view-semantics.md` (2026-10-10 RFC-014 amendment) says at lines 839–855 that the expansion entry point is the sole generic package operation over `Root: View`, `SemanticExpansionWorkspace`, and `SemanticExpansionSink`, returning `SemanticExpansionResult`. The amendment also requires a single typed stateful-body traversal path, bind-before-body ordering, and exact SPEC-010 failure routing; it does not name package bridge/result declarations.
- **Accepted supporting authority:** accepted ADR-035/036 and approved SPEC-010 require runtime-derived identity and scoped state access. They establish the semantics and ownership boundary, not these package declaration names.
- **Non-authoritative derived artifacts:** `docs/implementation-plans/spec-006-implementation-plan.md` T6.3 calls for exact package declarations and no extra package results/mutable operations; it cannot amend the Spec. `Tests/ContractFixtures/SPEC006/semantic-surface-allowlist.tsv` is a derived expectation. `scripts/contracts/check-spec-006-dependency-surface.rb` scans only `GiftUISemanticCore.swift`, so its 17-name comparison is not a full package-surface audit.

At the time of the pre-approval finding, the focused checker failed. Within its scanned source, the allowlist expected 17 declarations and the source had 18. Expected-only names were `SemanticStateBindingOutcome` and `expandSemanticTree`. Source-only names were `SemanticBodyEvaluation`, `SemanticExpansionAttempt`, and `SemanticExpansionTraversalOperations`. Both sets contained `expandSemanticTreeWithStateBinding`. The derived checker and declaration inventory have since been updated under the approved clarification, as recorded in the post-approval section.

Additional package declarations are outside the scanner: `SemanticRecordStore.expand` has two generic overloads in `Sources/GiftUISemanticCore/SemanticRecordExpansion.swift`. The overload taking a supplied `Traversal` is called by the SPEC-015 Counter fixture (`CounterSemanticProbe.swift`, `CounterPipelineOwner.swift`). The `Roles`/`Codec`/`Binding` overload is called by SPEC-006 `ScopedTraversalProbe.swift`, SPEC-007 `LayoutProbe.swift`, and SPEC-012 `CanvasSemanticProbe.swift`. Current repository search finds no production `Sources/` callers of either overload. Both delegate to the shared `SemanticExpansionTraversal` implementation; the source does not show a second traversal algorithm. `SemanticExpansionAttempt` and `SemanticExpansionTraversalOperations` support this record-storage route and its fixtures. `SemanticBodyEvaluation` is different: production `GiftUIObservableState.ObservableSemanticBodyBinding` returns it across the module boundary. `SignalAnalyzerTargetHost.DynamicSignalAnalyzerPresentationPipeline` calls `expandSemanticTreeWithStateBinding`; this production caller is analyzer-specific and retains its authorized I4 destination.

The four package-level declarations in `SemanticRecordExpansion.swift` named `SemanticRecordPayloadCodec`, `SemanticPayloadWriter`, `SemanticRecordWorkspaceState`, and `SemanticRecordTraversalRealization` are internal pieces of the record realization seam, not additional user-facing traversal engines. The old packet left their target-wide classification open. A bounded Swift 6.4.0 compile now emits the complete target interface under both Dynamic and Static profile defines. The interfaces are byte-identical and contain 51 top-level package declarations (the two `withSemanticRecordStore` overloads are listed separately) and a 533-row source/test/fixture reference map. The full declarations, declaration index, reference map, command inputs, and hashes are retained in `spec006-spi-inventory-2026-11-10.tar.gz` and its adjacent manifest. The map distinguishes production, contract-fixture, and unit-test text references; it is not a claim that every textual reference is an invocation.

The inventory classifies the declaration set into these bounded groups: core limits/results/workspace/sink/binding contracts; the state-bound expansion entry and result; recording test support; layout/render views and sinks; record codec/writer/workspace/realization support; the two `SemanticRecordStore.expand` overloads and scoped store constructors; runtime record, identity, owner, bank, and payload types. The only direct production invocation of `expandSemanticTreeWithStateBinding` in `Sources/` is the analyzer-specific I4 pipeline; the state-binding implementation is supplied by `GiftUIObservableState.ObservableSemanticBodyBinding`. There is no production caller of either `SemanticRecordStore.expand` overload. The `Roles`/`Codec`/`Binding` overload is called by SPEC-006, SPEC-007, SPEC-012, and SPEC-013 fixtures; the supplied-`Traversal` overload is called by SPEC-015 Counter fixtures and remains within the restricted P08/S1–S3 reuse boundary. The package support contracts have cross-target production consumers recorded in the map; they do not independently dispatch a second traversal engine.

| Concern | Required by accepted SPEC-006 / RFC-014 | Current declaration and callers | Derived expectation |
| --- | --- | --- | --- |
| Bounded expansion | One bounded traversal implementation; SPEC-006 also calls its expansion entry the sole generic package operation over `Root`, workspace, and sink. | `expandSemanticTreeWithStateBinding` is a generic entry taking a state binding and returning `BoundSemanticExpansionResult`; consumed by production `ObservableSemanticBodyBinding` and the I4 analyzer pipeline. | Allowlist expects `expandSemanticTree`; that declaration is absent. |
| State-bound body result | RFC-014 requires bind-before-body and typed failure routing through SPEC-010, but does not name this package result/bridge. | `SemanticBodyEvaluation` is returned by production `ObservableSemanticBodyBinding`; `BoundSemanticExpansionResult` carries typed binding failures. | `SemanticStateBindingOutcome` is listed but absent. |
| Record-store realization | The Spec defines record and transactional behavior, but does not clearly list package adapter overloads as additional entry points. | Two `SemanticRecordStore.expand` overloads delegate to common traversal; called by SPEC-006/007/012/015 fixtures, with no production caller. | T6.3 describes exact declaration surface but cannot create normative permission. |
| Record traversal support | No accepted text here explicitly enumerates the package helper declarations. | Codec, writer, workspace, and realization protocol support the record adapter; a complete audit must list exact per-declaration callers. | Current one-file checker does not inspect these declarations. |

The allowlist-only `expandSemanticTree` is called by nine current test files
(`GiftUISemanticCoreTests` expansion/recording/layout tests,
`GiftUIRuntimeDynamicTests/DynamicSemanticHostStorageTests.swift`, and
`GiftUIDrawingTests/CanvasInvocationAdapterTests.swift`) but is absent from
both `Sources/` and the compiled package interface. Candidate test migration is
to use the existing `expandSemanticTreeWithStateBinding` with a test-only
`SemanticStatefulBinding` whose domain has no state reads, preserving the
stateless body/result assertions without introducing a second package entry
point. Where a test specifically validates Observable State binding, it should
use the existing typed binding implementation. The migration must keep all
current success, exact-limit, first-excess, ordering, failure, reentrancy, and
recording assertions; the absent spelling is not to be restored implicitly.

Current source identity SHA-256:

- SPEC-006: `cb1570fd599e1472b76aafacc8895b381eee18a1e20342d3aa8ddebbe6382a6e`
- T6.3 plan: `87ef1942563075be1eac00e49e94adb4325eff1345e4ef5f65b3032670206f11`
- Core source: `0526c6259995fd41b08d8bc3799915838eb6c2312454e25c541ed2cba6f8b299`
- Record expansion source: `2b9bf9fb82708661bba70d94cd5a19bcbe13fe760f32b6df782f4e8cbf9acb47`
- Observable body binding: `578514c2224b9311fbfa51c3e58b87a9c6b3801af961ba3a1a18d316d681eec0`
- Allowlist: `6aed3a54b68079ae592529dcbdfed9b3f682dc14cdcb2af7e378a8960806f6fd`
- Current checker: `d48207b6db029c68a38084be56758bb757ef46676f52c7096d79a5812453091f`

## Historical recommendation before approval

Choose whether the current typed state-binding bridge and record-store wrappers are intended package SPI under the approved contract.

1. **Keep the strict current contract.** Refactor to one package generic expansion operation, move fixture-only traversal helpers out of production package SPI, and update affected tests to exercise the approved entry point. The refactor must preserve RFC-014/SPEC-010's cross-module typed body and binding-error contract plus record-fixture coverage. This is an implementation/API refactor, not a checker-only fix. Do not delete the P08 fixture or suppress its failures; identify replacements and preserve the restricted-reuse condition.
2. **Approve a narrow SPEC-006 clarification (recommended only if retaining current structure).** Clarify that the requirement is one shared traversal engine, while allowing exact state-binding and typed record-store adapters that delegate to that engine. The decision text must classify `expandSemanticTreeWithStateBinding`, `BoundSemanticExpansionResult`, `SemanticBodyEvaluation`, the two `SemanticRecordStore.expand` overloads, package traversal helpers, and fixture-only declarations; this packet does not claim that list is yet an exhaustive target-wide allowlist. Keep all existing bounds, transaction behavior, no-allocation requirements, state-binding order, failure routing, and backend/profile independence unchanged. Extend T6.3's exact audit to the complete compiled module interface, migrate or justify current tests calling the absent `expandSemanticTree`, and classify all cross-module callers. Do not claim the current single-file checker proves that.

Option 2 changes the normative package-surface rule; it needs explicit Spec approval through the normal lifecycle. Neither the RFC's semantic requirements nor T6.3/the allowlist alone authorize it. No option changes P08's FROZEN/UNMET state, authorizes old P08 certification, removes S1–S3 restrictions, or authorizes analyzer migration beyond I4.

## Approved minimal Spec text

Replace the sole-operation paragraph at SPEC-006 lines 839–855 with:

> Semantic Core MUST implement one bounded expansion traversal engine shared by all profiles. Package entry points MAY be provided for direct caller-owned workspace/sink expansion with scoped SPEC-010 state binding, and for `SemanticRecordStore` record realization with a typed payload codec. These entry points MUST delegate to the same traversal engine; they MUST NOT create independent body dispatch, identity, limit accounting, recursion, staging, publication, or rollback paths. The state-binding bridge MAY return the owned body or the exact semantic, access, and binding failure required by the RFC-014 amendment and SPEC-010; Semantic Core MUST NOT import Observable State. Any fixture-only package traversal support MUST be separately identified in the T6.3 allowlist and MUST NOT be represented as an additional production entry point. Exact package declarations and cross-module callers MUST be audited across the complete Semantic Core target, not only one source file.

The attached 51-row TSV is a top-level declaration index, not a complete member allowlist. The exact source of truth is the complete compiled package interface snapshot in the archive, including nested package members, initializers, properties, and methods. The derived check compares every package declaration and member in the complete interface against a normalized declaration/member inventory generated from that snapshot; no prefix or wildcard allowance is used. The clarification permits only the exact state-bound expansion root, typed record-store adapters/constructors, and supporting package contracts and members present in that validated inventory. The supplied-`Traversal` P08 entry remains explicitly restricted and is not newly authorized for general reuse.

### Complete compiled-interface inventory and candidate migration delta

Evidence was compiled on 2026-11-10 with the pinned Swift 6.4.0 toolchain,
`arm64-apple-macosx26.0`, SDK 26.5, once with each profile define. Both package
interfaces have SHA-256
`210fba09a4c627ea2c16552aa6ceb50ed72d8981fbb335e63a25135c0fa4469d`.
The compiler interface emission warned that library-evolution interfaces
require `-enable-library-evolution`; this is a declaration snapshot for the
current package build, not a stable ABI promise. Exact flags, toolchain,
SDK, source/input hashes, the 51-row top-level declaration index, 533 text-reference
rows, and operation signatures are in the inventory manifest/archive linked
above.

The pre-approval candidate validation delta was limited to the derived
SPEC-006 checker and tests: compare the complete emitted package interface,
including nested package members and overload signatures, against a normalized
declaration/member inventory derived from the archived snapshot; reject any
unlisted declaration or member; verify the one shared traversal implementation
and adapter delegation; check direct production and fixture caller
classification; and migrate the nine files calling absent
`expandSemanticTree` as described above. The 51-row TSV is a top-level index
only. The maintainer approved this bounded clarification on 2026-11-10; the
post-approval implementation and validation status below supersedes the former
instruction to await a decision. Existing bounds, negative cases, and semantic
assertions remain in force.

## Consequences

These were pre-approval consequences, not current approval choices. The approved
clarification and derived-check implementation are recorded below. The current
focused Dynamic target and analyzer compile blockers remain accurately
classified as I4-07 transfers; the full archived P10 remains 24 pass / 59 fail.

## Independent review disposition

Two read-only reviewers agree that accepted SPEC-006 makes the single generic
package-operation rule normative. The finding is not merely drift in T6.3 or
the derived allowlist, and the reviewers recommend option 2 only if the
current API shape is retained. They also found that `expandSemanticTree` is
used by nine current test files although it is absent from `Sources/`, that
the two record-store overloads have distinct fixture caller sets, and that
the full target has package declarations beyond the checker's one-file scope.
At the time this pre-approval assessment was written, no Spec, source, test,
or allowlist changes had been made. The approval and implementation status
below supersede that historical statement.


## Post-approval implementation status — 2026-11-10

- The exact approved clause is applied in SPEC-006 and the corresponding T6.3
  follow-up is recorded in the implementation plan. One traversal engine,
  bounds, typed failure routing, state-binding order, borrowing, no-allocation,
  backend independence, and restricted P08 reuse remain unchanged.
- The derived Semantic Core package-surface check compares the complete
  compiled Swift 6.4 Dynamic/Static interface to the pinned exact snapshot and
  passes. It also checks source declarations/dependencies and compiled
  underscored references. Twenty-one exact existing GiftUI references were
  added to the reference allowlist after independent review; no wildcard or
  prefix rule was introduced.
- The nine test files using the absent `expandSemanticTree` spelling were migrated
  to the state-bound entry. Semantic Core and Drawing test targets build and
  their focused suites pass. The Dynamic target's compile blocker is the
  separately approved `DynamicRuntimeProfileBinding` I4-07 transfer; its test
  assertions remain outstanding in I4 with reuse blocked.
- Focused logs and counts are retained in the parent
  [`p10-run.md`](p10-run.md), section “Focused post-approval validation —
  2026-11-10.” These results do not revise the archived 24 pass / 59 failed
  run or claim full P10 conformance.
