# SPEC-006 T3.2 Shared Declaration Corpus Evidence

The checked-in semantic corpus now covers empty and one-child lowering, every
fixed arity two through five, nested custom views, a view-returning property
and function, both conditional branches, optional presence and absence, a
nested conditional/optional combination, and equivalent active output when a
sibling is inserted only in the inactive branch.

`SemanticDeclarationCorpusTests` supplies source-declared bounded symbolic
roles for its fixture declarations and retroactive test-only roles for the
fixed framework wrappers. Its recording workspace uses an explicitly fixture-
only protocol-conformance cast to recover those symbolic tokens; no production
path, identity implementation, or declaration traversal uses reflection,
metatype addresses, strings, or a registry.

The tests compare every event's complete component path, role, and kind. They
also prove:

- fixed children emit in increasing source index from arity two through five;
- nested custom bodies are each accessed exactly once;
- a property and function returning views preserve their equivalent inline
  structure and are each invoked once;
- only the selected conditional branch enters the path;
- optional absence emits exactly its wrapper structural event with no presence
  child or counted event;
- the nested combination remains depth-first and left-to-right; and
- changing only the inactive branch's sibling shape neither observes that
  metatype nor changes the active transcript or normalized result.

`cases.tsv`, `canonical-transcript.tsv`, and `normalized-results.tsv` contain
the same fifteen profile-neutral rows/case groups, symbolic identity-set names,
event counts, summary counts, and maximum depths. The SPEC-006 harness validates
their registered schema. Identity relations beyond the inactive-branch pair
remain assigned to T3.3.
