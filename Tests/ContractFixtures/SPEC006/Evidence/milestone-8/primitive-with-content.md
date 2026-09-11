# SPEC-006 T8.3 Primitive-with-Content Evidence

The package compile fixture type-checks the exact typed
`visitPrimitive(content:payload:)` operation alongside the unchanged leaf
operation. The canonical `layout-container-chain` case records each container
primitive before entering its `fixed-child(0)` content and then records
modifier applications in source-call order.

`SemanticExpansionTraversalTests` covers empty, one-child, five-child, nested,
conditional, optional, and modified content. It also proves zero body
evaluation, exact identity paths, capacity-before-child failure, late sink
refusal, atomic discard, and reuse.

Every SPEC-006 profile driver validates the same canonical corpus digest,
compiles the package fixture, runs the strengthened complexity check, audits
the two exact visitor overloads with no default compatibility hook, and scans
the optimized Semantic Core SIL for heap allocation instructions. ARMv6 and
nRF52840 profiles additionally inspect the required hard-float ELF attributes.
These are hardware-free build and inspection claims only.
