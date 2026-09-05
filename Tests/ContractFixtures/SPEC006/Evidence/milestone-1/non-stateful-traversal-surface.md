# SPEC-006 T1.4 Traversal Surface

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
Core/SPEC-010 macro-generator allow-list, and any attempt for SPEC-006 to
define the SPEC-010-owned state-host protocol.

## Generated stateful completion

SPEC-010 supplies `_GiftUIObservableStateHost` and
its declaration visitor, unblocking the normative
`visitStatefulCustomView<Declaration: View & _GiftUIObservableStateHost>`.
The exact stateful visitor operation now compiles against that owned protocol,
including its borrowed declaration body accessor. The host-only macro now
synthesizes the sole supported `_giftUITraverse` client witness. Focused
framework execution proves an annotated host selects the stateful category,
does not select the ordinary custom category, and evaluates `body` through the
borrowed declaration. The registered SPEC-010 audit rejects handwritten
application substitutes.

T1.4 and Milestone 1 are complete. Runtime binding before body remains owned by
SPEC-010 T3.2 and is not claimed by this declaration-surface task.
