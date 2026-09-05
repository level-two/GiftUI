# SPEC-006 Structural-Identity Relation Evidence

Task `T3.3` is implemented by the checked-in
`SemanticCorpus/identity-relations.tsv` relation oracle and
`SemanticDeclarationCorpusTests`.

The tests compare component-addressable canonical paths and endpoint roles.
They prove equality across repeated expansion and optional restoration, and
inequality for branch changes, sibling indices, endpoint roles, declaration
roles, and a complete descendant versus its path prefix. Optional absence is
observed between the two present expansions and has no semantic identity.

A fixture-only workspace mode deliberately maps two distinct path requests to
the same identity candidate. It detects the alias at the second request,
returns `invalidIdentity`, resets the workspace, and publishes no recording.
This injection is test scaffolding and does not define either runtime
profile's identity representation.

The corpus contains no raw identity bytes, addresses, hashes, or persistent
identity serialization. Dynamic and static contract drivers hash the same
checked-in relation oracle as a profile-neutral input.
