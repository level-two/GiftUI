# SPEC-006 T9.3 Action-Primitive-with-Content Evidence

The package compile fixture constructs leaf action primitives and action
containers with zero, one, and five stored children. The content-bearing
declaration has `Body == Never`, preserves an exact `UInt16` action value, and
calls only `visitActionPrimitive(content:payload:)`.

The canonical `action-container-chain` corpus records two action associations
at their declaration identities before either stored child subtree, with the
outer content entering `fixed-child(0)`. Its normalized result contains four
semantic nodes, two action occurrences, one modifier application, zero body
evaluations, and a maximum bounded path depth of eight.

The SPEC-006 traversal, semantic-profile, complexity, dependency, and
layout/allocation checkers require this operation. The four standalone driver
profiles compile the fixture and inspect the same optimized Semantic Core
source. ARMv6 and nRF52840 runs remain hardware-free cross-build and ELF
inspection evidence; they make no connected-target claim.

Focused host validation:

```text
swift test --filter SemanticExpansionTraversalTests
ruby scripts/contracts/check-spec-006-traversal-surface.rb
ruby scripts/contracts/check-spec-006-semantic-profiles.rb
ruby scripts/contracts/check-spec-006-complexity.rb
```
