# SPEC-006 T1.4 Non-Stateful Traversal Slice

## Implemented slice

The declaration module now contains the exact primitive, action, and modifier
payload protocols and every SPEC-006-owned non-stateful visitor operation.
Every fixed wrapper dispatches directly to its matching generic visitor method
without evaluating `Never.body`. Focused tests exercise empty, arity two
through five, both conditional branches, absent/present optional content,
ordinary custom bodies, and all three typed payload categories.

The registered traversal-surface audit rejects `Any`, view existentials,
reflection, the retired `_visit`/`ViewVisitor` surface, a second traversal
spelling, underscored production references outside the declaration/Semantic
Core allow-list, and any attempt for SPEC-006 to define the SPEC-010-owned
state-host protocol.

## Completion blocker

T1.4 is not complete. Its normative visitor protocol also requires
`visitStatefulCustomView<Declaration: View & _GiftUIObservableStateHost>`.
Approved SPEC-010 exclusively owns `_GiftUIObservableStateHost`, but its
implementation plan, declaration target, macro target, and generated-witness
fixture do not yet exist in the package. Defining a placeholder in SPEC-006
would violate that ownership boundary and make a non-authoritative contract
look executable.

The non-stateful slice is independently usable and tested, but Milestone 1
remains open until the SPEC-010 owner supplies the declaration and generated
witness seam. No later task is credited with stateful traversal evidence.
