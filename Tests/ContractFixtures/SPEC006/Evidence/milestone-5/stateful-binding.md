# SPEC-006 T5.2 Stateful Binding Evidence

Semantic Core now owns a generic downward binding hook and a combined result
that keeps semantic failures separate from typed owner failures. It imports no
observable-state module and continues to own traversal, structural identity,
body accounting, atomic semantic publication, and local semantic errors.
`GiftUIObservableState` supplies the hook by adapting its checked binding
decorator.

The macro-generated fixture has two direct `State` declarations. Its exact
transcript is `bind:0`, `bind:1`, then `body`; the body reads both bound values,
so it cannot succeed through an unbound or original declaration. The complete
stateful expansion and an ordinary equivalent produce identical summary,
structural/semantic event kinds, body count, maximum depth, and publication
count.

Binding itself emits no semantic node or body evaluation. Semantic Core stages
`evaluateCustomBody` only inside the decorator's success continuation and
evaluates the supplied accessor once. The transient declaration and binding
do not remain in Semantic Core after the synchronous call.

The registered audit proves the production dependency remains downward,
checks the distinct combined-result cases and owner-failure discard path, and
requires macro-generated lexical ordering plus comparison against ordinary
semantics. Exact failure injection and no-publication evidence remains T5.3.
