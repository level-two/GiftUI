# SPEC-006 Bounded Action Corpus Evidence

Task `T3.5` is implemented by the `action-*` semantic corpus rows, their
identity relations, and focused action tests in
`SemanticDeclarationCorpusTests`.

The action payload is a finite `UInt16` enum. Tests prove distinct identities
at sibling paths, equality under equivalent re-expansion, and unchanged
structural/action identity when only the enum value changes. The combined
fixture records semantic occurrence, action association, then modifier
application at the required paths.

A fixture-owned sink synchronously copies the borrowed enum value. A separate
token retained only by the declaration poisons its lifetime at deinitialization;
after expansion the token is gone while the committed recording contains the
structural and action-role identity event and the fixture consumer contains
only the bounded enum value. No action generation, target binding, callable,
handler, model, decoding path, or invocation exists in this expansion fixture.
