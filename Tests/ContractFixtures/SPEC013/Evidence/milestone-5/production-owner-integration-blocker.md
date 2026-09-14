# SPEC-013 T5.1 Production Owner Integration Blocker

Date: 2026-09-12

SPEC-011 T5.1-T5.6 is complete and no longer blocks Runtime Profile work.
Milestones 3 and 4 now bind both concrete profile storage representations to
Runtime Core's common lifecycle. The next ordered task, T5.1, is nevertheless
blocked because its required production profile workspaces have not landed
under SPEC-010's owning plan.

Repository inspection found no production conformance in either runtime target
for `ObservableStateReconciler`, `SemanticExpansionWorkspace`,
`SemanticExpansionSink`, `LayoutWorkspace`, or
`ResolvedRenderLayoutResultStorage`. The only semantic storage adapter exposed
by Semantic Core is the recording adapter, and the concrete Observable State
lifecycle mechanisms remain internal to `GiftUIObservableState`. Test-only
reconcilers and workspaces cannot satisfy SPEC-013 Milestone 5, whose entry
condition explicitly requires every focused production owner.

The authoritative SPEC-010 plan leaves T6.1-T6.4 open. T6.1 owns equal Dynamic
and Static profile workspaces behind the focused protocols, and T6.3 owns the
typed fixed Static state path with zero heap, reflection, type erasure,
task-local state, tasks, threads, exceptions, Apple Observation, or Objective-C.
That milestone's recorded entry condition also requires SPEC-015 host assembly
inputs; SPEC-015 currently has no completed implementation task or package
target.

Proceeding inside SPEC-013 would require one of the prohibited substitutions:

- duplicate Observable State association/generation algorithms in a runtime
  profile;
- test/recording storage presented as a production owner;
- unowned numeric host capacities; or
- a closure/type-erased Static state fallback that invalidates the established
  zero-allocation evidence.

T5.1 remains unchecked. T5.2-T8.4 depend on the complete production
coordinator or on later milestones and therefore cannot be claimed from the
currently authoritative repository state. The blocker can be re-audited after
SPEC-010 T6.1/T6.3 and their required SPEC-015 assembly inputs land.

## Resolution — 2026-09-14

SPEC-010 T6.1 and T6.3 are now complete. Runtime Core owns the common
production reconciler and target-view seam, Dynamic supplies bounded array
slots, and Static supplies its inline typed slot without heap facilities.
SPEC-013 T5.1-T5.5 subsequently integrated those focused seams through
`RuntimeCompletePipeline`; their completion evidence is recorded in
`complete-production-pipeline.md`. This historical blocker no longer applies
to Milestone 6. SPEC-015 host assembly remains assigned to SPEC-013 T8.2 and
does not block the profile-local T6.4 corpus.
