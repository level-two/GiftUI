# SPEC-007 T2.3 Semantic Result Adapter Evidence

`SemanticLayoutResultSink` participates directly in the real SPEC-006
expansion operation and exposes that successful primary storage as the
package-scoped `SemanticLayoutView`. The adapter consists only of forwarding
operations and owns no node array, identity translation, or copied semantic
graph.

`SemanticLayoutResultAdapterTests` expands a custom root containing a stack,
an action-bearing occurrence, a spacer, modified text, and non-ASCII content.
The published result proves transparent-root flattening, canonical source
child order, same-identity action proxying, exact modifier scope and order,
and scalar access. The fixture storage is the semantic sink's result storage;
no layout-owned representation is constructed.

Reproduce with:

```text
swift test --filter successfulSemanticExpansionIsItsOwnBorrowedLayoutView
```
