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

## Remaining completion dependency

T1.4 is not complete. SPEC-010 now supplies `_GiftUIObservableStateHost` and
its declaration visitor, unblocking the normative
`visitStatefulCustomView<Declaration: View & _GiftUIObservableStateHost>`.
The exact stateful visitor operation now compiles against that owned protocol,
including its borrowed declaration body accessor, and focused framework tests
exercise the category. Macro-generated witness evidence still waits for
SPEC-010 T1.2; no handwritten application substitute is authorized.

The non-stateful slice is independently usable and tested, but Milestone 1
remains open until the generated witness seam lands. No later task is credited
with macro-generated traversal evidence.
