# RFC-015 independent initial review — 2026-10-13

**Verdict: not ready.** Reviewed draft [RFC-015](../../rfcs/rfc-015-p08-scoped-storage-ownership.md)
at `f533d870`, using the RFC-reviewer skill. This is one independent read-only
design review, not architectural approval or a compiler experiment. Only this
report was written. Production source, lifecycle status, budgets, limits and
P08/R07's failed58,648-byte stack disposition remain unchanged.

Accepted PROPOSAL-007 and ITERATION-003 I3-04/I3-05 support the focused problem;
closed MVP and its stack/application regressions remain constraints. The
separation of physical ownership, transaction ownership and unique scoped access
is coherent as a candidate. Scalar/Identity associated values remain owned;
the proposed concrete access types explicitly suppress copying/escaping. The
draft properly labels new syntax uncompiled, prohibits unchecked/Sendable
fallbacks and retains physical/stack proof as approval blockers. The findings
below are concrete omissions or contradictions beyond simply repeating B1–B4.

## Approval blockers

| ID / location in RFC-015 | Finding and required resolution |
| --- | --- |
| **R1 — Owned compatibility**, lines344–380,526–531, Public API Impact | Both state types are unconditionally declared `~Copyable, ~Escapable`. Constraining G/C/R/H to owned Copyable/Escapable arguments does **not** itself make `InteractionOwnedKeyState<C,R,H>` owned/escapable. The current ordinary `CounterReturnedWorkspaces` stores that state, so the stated owned return route is not established by the proposed constraint change. Choose and show an owned-only state route or explicit conditional Copyable/Escapable conformance with full field/initializer constraints. Do not leave this required compatibility choice as “if desired.” Compiler acceptance of the chosen design remains B1; choosing the actual route precedes that evidence. |
| **R2 — Missing intermediate carrier constraints**, lines511–551 and B3 | The coordinator constructors are already scoped, but the selected pipeline's Interaction operations still pass through ordinary generic functions whose own parameters retain default constraints. Suppressing the six protocols alone does not suppress each consumer's generic requirements. Name the direct consumers below and mark each scoped-capable or explicitly owned-only. In particular, the storing `RuntimeInteractionDispatcher` currently has ordinary Records and a non-consuming initializer; choose whether to keep it owned-only or make its entire Dispatcher conformance/carrier scoped. This may expose another operational protocol amendment; do not silently include it or claim the six-protocol chain is complete. |
| **R3 — Exchange lifetime/session rule**, lines263–285 and Replacing the live Interaction slot | `exchangeContents(with: inout Self)` does not specify how two independently borrowed handles retain valid dependencies after exchanging pointers. The outer state initializer's five-bank union is useful, but is not by itself the concrete adapter witness rule. A viable narrow clarification is to create **every** adapter with the same common session/owner lifetime, restrict exchange to private state-held role pairs from that session, and preserve that dependency through moves/retirement. Write this rule into adapter/factory/witness contracts and state how same-session provenance is assured by restricted construction. This is consistent with the candidate, not a demand for a new universal architecture. If independent handle lifetimes or cross-session exchange are intended instead, that is a different unresolved design. Either chosen composition still needs B1 proof; no syntax is verified here. |
| **R4 — Failure transport contradiction**, lines243–246,427–430 and Initialization step3 | The allegedly fixed `withP08Storage` signature has a nonthrowing callback and returns only Result, while lifecycle text promises throwing-callback cleanup and construction has fallible validation/initialization. Choose one explicit boundary: nonthrowing body with owned failure values and a separately checked backing initializer, or an exact typed-throwing/other owned-result factory. State which stage may fail and what has been initialized/acquired at that stage. A missing method body cannot resolve a fixed signature that excludes the promised callback behavior. Do not return a scoped failure payload through ordinary Result. |

## Direct source inventory for R2 / B3

This bounded `Sources/**/*.swift` inventory records direct protocol/state
references and concrete alias users outside the counter. It is source evidence,
not a completed compiler-dependent transitive migration audit.

| Module / files | Required disposition |
| --- | --- |
| GiftUIInteraction: `InteractionStorage.swift`, `InteractionValues.swift`, `InteractionState.swift`, `InteractionOwnedKeyState.swift`, `ExecutionGestureAdapter.swift` | Three storage plus three operation declarations; state constraints/consuming lifetime unions; `down/move/up<Resolver>` need explicit scoped generic permissions if used with scoped resolvers. Both current `withBacking` declarations expose generic conformers; choose the owned measurement replacement and migrate callers rather than retain an unbounded generic callback by accident. |
| GiftUIRuntimeCore: `RuntimeRecordInteractionBridge.swift`, `RuntimeRecordCanvasInteractionBridge.swift` | Candidate/Committed/Hits generic bridge parameters must admit the chosen scoped arguments; `dispatch<Records>` likewise needs an explicit owned/scoped disposition. |
| GiftUIRuntimeCore: `RuntimeInteractionCandidateTransaction.swift`, `RuntimeInteractionCandidateCoordinator.swift`, `RuntimeInteractionCandidateResolution.swift` | Ordinary `Interaction: InteractionCandidateBuilder` generic parameters occur at each phase boundary. Specify their scoped permissions and preserve owned scalar/result returns. |
| GiftUIRuntimeCore: `RuntimeInteractionDispatcher.swift` | Retains Records by value and conforms to InteractionDispatcher; this is the concrete ownership/conformance choice in R2, not an automatic six-protocol edit. |
| GiftUIRuntimeStatic / GiftUIRuntimeDynamic: `StaticInteractionStorage.swift`, `DynamicInteractionStorage.swift` | Existing owned bank conformers and Static/StaticSix/Dynamic state aliases require the R1 compatibility route. Keep equal logical limits and account Dynamic allocations. |
| GiftUIRuntimeStatic / GiftUIRuntimeDynamic: `StaticRuntimeExecutionCoordinator.swift`, `DynamicRuntimeExecutionCoordinator.swift` | Constructor lifetime union already exists. `admission`/`opportunity` are package getters with private setters, not wholly private fields. Existing consuming `takeQuiescedOpportunity() -> Opportunity?` has `@_lifetime(copy self)` and must remain in the full Optional/retirement proof. Do not test constructors alone. |
| SignalAnalyzerTargetHost: `DynamicSignalAnalyzerActionDispatcher.swift`, `StaticSignalAnalyzerActionDispatcher.swift`, `StaticSignalAnalyzerNRFEmbeddedInteractionOwner.swift` | Direct generic operational consumers/conformer; classify owned-only compatibility versus scoped adoption. |
| SignalAnalyzerTargetHost: `DynamicSignalAnalyzerPresentationPipeline.swift`, `StaticSignalAnalyzerNRFApplicationStorage.swift`, `StaticSignalAnalyzerNRFPresentationCommitter.swift`, `StaticSignalAnalyzerNRFInteractionHandler.swift`, `StaticSignalAnalyzerNRFApplicationInputOwner.swift`, `StaticSignalAnalyzerNRFInteractionCandidateProducer.swift` | Concrete state-alias owners, pointer users and inout producer/commit paths affected by changing the state types. `withInteraction<Result>` in application storage is also a callback boundary. Existing owned routes need not adopt a borrowed architecture, but must remain explicitly compatible. |

All paths in this table are under `Sources/<Module>/`. Counter fixture changes
remain the RFC's own carrier inventory. Other tests/generated/compiler consumers
are not exhaustively inventoried here and must be covered by the selected
migration/evidence plan, not silently assumed compatible.

## Enforcement clarifications and suggestions

- At lines324–331, replace “borrowing permits only read operations” with the
  precise value-access guarantee. Borrowing prevents consuming/mutating access
  to that value; an immutable wrapper or borrowed witness can still mutate a
  referenced/pointer-backed object. Reviewed concrete methods and hidden mutable
  capabilities must enforce the read-only semantic boundary. This is not proof
  of an existing external-client escape.
- At the access matrix, storage-protocol paragraph and lines397–441, explicitly
  identify the whole package implementation as trusted if that is the intended
  boundary. Package protocols and package generic initializers are available to
  other modules in that package; fileprivate adapter constructors do not seal
  those protocols. An outside-package frontend/backend cannot call package
  initialization through the shown declarations, so no supported external forge
  is demonstrated. Name the actual concrete client entry and its visibility;
  treat any untrusted in-package entry as a separate exposed boundary requiring
  restriction. Avoid claiming Swift seals a package protocol against package code.
- For P08-SO-002 and the exclusivity negative row, label which exclusions are
  compile-time lifetime/copy errors, which are access-control errors and which
  can require Swift's runtime exclusivity checks. State how reentrant access and
  Dynamic reference/COW aliases are excluded under the pinned Embedded and host
  configurations. Lack of Sendable is useful but does not itself prove physical
  disjointness or absence of aliases. This is a needed enforcement map/B1–B2
  evidence obligation, not a demand that every internal unsafe action be made
  impossible by Swift's type system.
- Retain B2 as an approval blocker. The old initialized optional cannot coexist
  with five rebound banks. The draft correctly preserves physical destruction
  inventory independently of role handles and infallible accepted-offer exchange.
  Before adoption provide one exact owner/init/session/end/deinit map, including
  partial failures, unequal capacities and repeated swaps. Exact byte offsets can
  wait for the chosen semantic interface; no fit claim follows now.
- The current ordinary generic Result deliberately excludes scoped returns.
  Preserve that restriction and test every omitted Optional/tuple/generic path
  with positive twins. Owned association/result constraints in the draft are
  deliberate; any actual new scoped associated type is an upstream incompatibility,
  not an unchecked fallback.

## Decisions, evidence and deferred scope

Resolve R1's owned/scoped compatibility route, R2's storing-consumer disposition,
R3's common-session exchange rule and R4's failure transport in the RFC first.
Then B1 asks whether the exact selected declarations, lifetime unions, consumed
mutations and cross-module positive/negative pairs work under pinned Swift6.4.
No new compile/Spike/repair is authorized by this review. Physical B2 and actual
nested stack/resource evidence remain separate from syntax acceptance.

After RFC approval, the proposed focused additive ownership ADR is appropriate
in scope: physical owner versus transaction owner versus unique scoped access,
trusted construction boundary and complete lifetime propagation. No ADR is
accepted/extracted here; conflicts with existing accepted decisions still need
explicit routing. No new capability, backend dependency or hardware commitment
was found. Fewer handles do not establish performance or stack feasibility.

FW-037 is an adequate bounded capture: current P08 proof obligations are
explicitly not deferred, Core/simulator generalization remains non-authoritative,
and consumer/evidence triggers are concrete. Manifest, Proposal/RFC navigation
and FW-022/FW-035/EXP-002 cross-links preserve current statuses and iteration
boundaries. Adding this review changes no lifecycle stage or closed budget.

Validation: `scripts/validate-governance.rb` PASS (195 authority nodes,
1991 edges;7features/75lifecycle artifacts/9skills); `git diff --check` PASS.
No repository test gate or formatter was run for this review-only Markdown
addition. No production edits, compiler/build/link, hardware or experiments.
