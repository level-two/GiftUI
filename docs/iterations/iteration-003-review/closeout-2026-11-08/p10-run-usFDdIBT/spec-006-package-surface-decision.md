# SPEC-006 package-surface decision packet (review copy)

Status: **not approved; no contract, source, or allowlist edits applied**.

## Authority and exact discrepancy

- **Accepted authority:** `docs/specs/spec-006-declarative-view-semantics.md` (2026-10-10 RFC-014 amendment) says at lines 839–855 that the expansion entry point is the sole generic package operation over `Root: View`, `SemanticExpansionWorkspace`, and `SemanticExpansionSink`, returning `SemanticExpansionResult`. The amendment also requires a single typed stateful-body traversal path, bind-before-body ordering, and exact SPEC-010 failure routing; it does not name package bridge/result declarations.
- **Accepted supporting authority:** accepted ADR-035/036 and approved SPEC-010 require runtime-derived identity and scoped state access. They establish the semantics and ownership boundary, not these package declaration names.
- **Non-authoritative derived artifacts:** `docs/implementation-plans/spec-006-implementation-plan.md` T6.3 calls for exact package declarations and no extra package results/mutable operations; it cannot amend the Spec. `Tests/ContractFixtures/SPEC006/semantic-surface-allowlist.tsv` is a derived expectation. `scripts/contracts/check-spec-006-dependency-surface.rb` scans only `GiftUISemanticCore.swift`, so its 17-name comparison is not a full package-surface audit.

The focused checker currently fails. Within its scanned source, the allowlist expects 17 declarations and the source has 18. Expected-only names are `SemanticStateBindingOutcome` and `expandSemanticTree`. Source-only names are `SemanticBodyEvaluation`, `SemanticExpansionAttempt`, and `SemanticExpansionTraversalOperations`. Both current and expected sets contain `expandSemanticTreeWithStateBinding`.

Additional package declarations are outside the scanner: `SemanticRecordStore.expand` has two generic overloads in `Sources/GiftUISemanticCore/SemanticRecordExpansion.swift`. The overload taking a supplied `Traversal` is called by the SPEC-015 Counter fixture (`CounterSemanticProbe.swift`, `CounterPipelineOwner.swift`). The `Roles`/`Codec`/`Binding` overload is called by SPEC-006 `ScopedTraversalProbe.swift`, SPEC-007 `LayoutProbe.swift`, and SPEC-012 `CanvasSemanticProbe.swift`. Current repository search finds no production `Sources/` callers of either overload. Both delegate to the shared `SemanticExpansionTraversal` implementation; the source does not show a second traversal algorithm. `SemanticExpansionAttempt` and `SemanticExpansionTraversalOperations` support this record-storage route and its fixtures. `SemanticBodyEvaluation` is different: production `GiftUIObservableState.ObservableSemanticBodyBinding` returns it across the module boundary. `SignalAnalyzerTargetHost.DynamicSignalAnalyzerPresentationPipeline` calls `expandSemanticTreeWithStateBinding`; this production caller is analyzer-specific and retains its authorized I4 destination.

The four package-level declarations in `SemanticRecordExpansion.swift` named `SemanticRecordPayloadCodec`, `SemanticPayloadWriter`, `SemanticRecordWorkspaceState`, and `SemanticRecordTraversalRealization` are internal pieces of the record realization seam, not additional user-facing traversal engines. Their exact normative classification is not stated by the current one-operation paragraph; they need explicit classification in any complete allowlist rather than being assumed violations or automatically authorized. The current checker does not inspect this file. Other files in the target also declare package SPI, including runtime-record, layout, render, recording-sink, and store types; this packet addresses the current mismatch, not a completed compiled-interface census.

| Concern | Required by accepted SPEC-006 / RFC-014 | Current declaration and callers | Derived expectation |
| --- | --- | --- | --- |
| Bounded expansion | One bounded traversal implementation; SPEC-006 also calls its expansion entry the sole generic package operation over `Root`, workspace, and sink. | `expandSemanticTreeWithStateBinding` is a generic entry taking a state binding and returning `BoundSemanticExpansionResult`; consumed by production `ObservableSemanticBodyBinding` and the I4 analyzer pipeline. | Allowlist expects `expandSemanticTree`; that declaration is absent. |
| State-bound body result | RFC-014 requires bind-before-body and typed failure routing through SPEC-010, but does not name this package result/bridge. | `SemanticBodyEvaluation` is returned by production `ObservableSemanticBodyBinding`; `BoundSemanticExpansionResult` carries typed binding failures. | `SemanticStateBindingOutcome` is listed but absent. |
| Record-store realization | The Spec defines record and transactional behavior, but does not clearly list package adapter overloads as additional entry points. | Two `SemanticRecordStore.expand` overloads delegate to common traversal; called by SPEC-006/007/012/015 fixtures, with no production caller. | T6.3 describes exact declaration surface but cannot create normative permission. |
| Record traversal support | No accepted text here explicitly enumerates the package helper declarations. | Codec, writer, workspace, and realization protocol support the record adapter; a complete audit must list exact per-declaration callers. | Current one-file checker does not inspect these declarations. |

The allowlist-only `expandSemanticTree` is also called throughout current
`GiftUISemanticCoreTests`, plus `GiftUIRuntimeDynamicTests` and
`GiftUIDrawingTests`, but is absent from `Sources/`. This creates a separate
test/source API reconciliation item: those tests currently exercise the
stateless spelling and must either migrate to an accepted stateful bridge or
be supported by an explicitly approved adapter. The discrepancy is not
resolved by noting that the name is absent from production call sites.

Current source identity SHA-256:

- SPEC-006: `cb1570fd599e1472b76aafacc8895b381eee18a1e20342d3aa8ddebbe6382a6e`
- T6.3 plan: `87ef1942563075be1eac00e49e94adb4325eff1345e4ef5f65b3032670206f11`
- Core source: `0526c6259995fd41b08d8bc3799915838eb6c2312454e25c541ed2cba6f8b299`
- Record expansion source: `2b9bf9fb82708661bba70d94cd5a19bcbe13fe760f32b6df782f4e8cbf9acb47`
- Observable body binding: `578514c2224b9311fbfa51c3e58b87a9c6b3801af961ba3a1a18d316d681eec0`
- Allowlist: `6aed3a54b68079ae592529dcbdfed9b3f682dc14cdcb2af7e378a8960806f6fd`
- Current checker: `d48207b6db029c68a38084be56758bb757ef46676f52c7096d79a5812453091f`

## Recommendation for a maintainer decision

Choose whether the current typed state-binding bridge and record-store wrappers are intended package SPI under the approved contract.

1. **Keep the strict current contract.** Refactor to one package generic expansion operation, move fixture-only traversal helpers out of production package SPI, and update affected tests to exercise the approved entry point. The refactor must preserve RFC-014/SPEC-010's cross-module typed body and binding-error contract plus record-fixture coverage. This is an implementation/API refactor, not a checker-only fix. Do not delete the P08 fixture or suppress its failures; identify replacements and preserve the restricted-reuse condition.
2. **Approve a narrow SPEC-006 clarification (recommended only if retaining current structure).** Clarify that the requirement is one shared traversal engine, while allowing exact state-binding and typed record-store adapters that delegate to that engine. The decision text must classify `expandSemanticTreeWithStateBinding`, `BoundSemanticExpansionResult`, `SemanticBodyEvaluation`, the two `SemanticRecordStore.expand` overloads, package traversal helpers, and fixture-only declarations; this packet does not claim that list is yet an exhaustive target-wide allowlist. Keep all existing bounds, transaction behavior, no-allocation requirements, state-binding order, failure routing, and backend/profile independence unchanged. Extend T6.3's exact audit to the complete compiled module interface, migrate or justify current tests calling the absent `expandSemanticTree`, and classify all cross-module callers. Do not claim the current single-file checker proves that.

Option 2 changes the normative package-surface rule; it needs explicit Spec approval through the normal lifecycle. Neither the RFC's semantic requirements nor T6.3/the allowlist alone authorize it. No option changes P08's FROZEN/UNMET state, authorizes old P08 certification, removes S1–S3 restrictions, or authorizes analyzer migration beyond I4.

## Proposed minimal Spec text (candidate only)

Replace the sole-operation paragraph at SPEC-006 lines 839–855 with:

> Semantic Core MUST implement one bounded expansion traversal engine shared by all profiles. Package entry points MAY be provided for direct caller-owned workspace/sink expansion with scoped SPEC-010 state binding, and for `SemanticRecordStore` record realization with a typed payload codec. These entry points MUST delegate to the same traversal engine; they MUST NOT create independent body dispatch, identity, limit accounting, recursion, staging, publication, or rollback paths. The state-binding bridge MAY return the owned body or the exact semantic, access, and binding failure required by the RFC-014 amendment and SPEC-010; Semantic Core MUST NOT import Observable State. Any fixture-only package traversal support MUST be separately identified in the T6.3 allowlist and MUST NOT be represented as an additional production entry point. Exact package declarations and cross-module callers MUST be audited across the complete Semantic Core target, not only one source file.

This candidate deliberately does not enumerate an allowlist yet: the permitted set must first be reconciled against the complete compiled module interface and the P08 fixture boundary. The proposed wording preserves the one-engine invariant but relaxes the strict “sole generic package operation” rule. Approval is therefore a contract decision, not a stale-checker correction.

## Consequences

- Under option 1, P10 remains blocked until a strict refactor and focused Dynamic/Static/Pi/nRF SPEC-006 validation pass.
- Under option 2, P10 remains blocked until the amendment and exact full-module allowlist are explicitly approved, implemented in derived checks, and independently reviewed. The current focused failure remains a real acceptance gap until then.
- The current four RFC-014 SPEC-006 profile rows from the archived P10 remain passing historical executions; this separate current-tree surface mismatch does not rewrite them. The complete archived P10 remains 24 pass / 59 fail.

## Independent review disposition

Two read-only reviewers agree that accepted SPEC-006 makes the single generic
package-operation rule normative. The finding is not merely drift in T6.3 or
the derived allowlist, and the reviewers recommend option 2 only if the
current API shape is retained. They also found that `expandSemanticTree` is
used by nine current test files although it is absent from `Sources/`, that
the two record-store overloads have distinct fixture caller sets, and that
the full target has package declarations beyond the checker's one-file scope.
The candidate amendment therefore remains a basis for a maintainer decision,
not an approval-ready complete allowlist. No Spec, source, test, or allowlist
changes were made in this assessment.
