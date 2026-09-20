# SPEC-001 T6.7 Dynamic Semantic Host Storage

The first production host-loop store now lives in `GiftUIRuntimeDynamic`
rather than a test fixture. `DynamicSemanticHostStorage` participates directly
in semantic expansion and preserves one bounded published tree for the later
layout, Drawing, render, and interaction stages.

The store keeps these facts from the same traversal:

- bounded structural identities and declaration roles;
- layout primitives, modifiers, text Unicode scalars, and child order;
- render scopes and a nonzero checked snapshot version;
- bounded Dynamic Canvas callables with explicit release;
- application action codes; and
- disabled-scope ancestry used to derive effective action eligibility.

`DynamicSemanticExpansionWorkspace` independently bounds path depth and
identity production, rejects reentry and first excess, and resets attempt
state after success or failure. The store validates the published summary
against its retained body, semantic, modifier, and action counts. A failed
expansion atomically discards actions, Canvas callables, and candidate data.

The focused command

```text
swift test --filter dynamicSemanticHostStorage
```

passes two tests. The accepted case expands a real `VStack` containing a
disabled `Button`, `Canvas`, and UTF-8 text; it verifies the action code,
effective disabled state, Canvas identity, render snapshot, and degree scalar.
The negative case sets action capacity to zero and proves the first excess
returns `capacityExhausted` with no published result or retained callable.

The package dependency graph remains acyclic with 83 targets and 335 direct
edges. This is a production-store prerequisite, not T6.7 completion: the exact
state-bound `SignalAnalyzerView`, layout/result storage, Drawing plan, render
workspace, interaction candidate, endpoint, and host lifecycle still need the
production join.
