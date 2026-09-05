# SPEC-006 Typed Modifier Corpus Evidence

Task `T3.4` is implemented by the `modifier-*` rows in the checked-in semantic
corpus and the focused modifier cases in `SemanticDeclarationCorpusTests`.

The fixtures cover zero and one modifier, repeated and mixed chains, custom
view and fixed-group content, nesting across a custom-body boundary, and two
modified siblings. Complete event sequences prove depth-first traversal,
inner-to-outer source application order, exact scope identities, chain-index
reset at nested and sibling scope boundaries, and no sibling interleaving.
Semantic occurrence identities remain equal when only a modifier payload
value changes, and wrappers do not add semantic nodes.

The fixture-owned inspecting sink copies each borrowed typed modifier only for
synchronous test consumption and observes its bounded integer marker in event
order. The generic recording result retains only the symbolic modifier role,
scope identity, and chain index. No fixture assigns layout or rendering
meaning to a modifier payload.
