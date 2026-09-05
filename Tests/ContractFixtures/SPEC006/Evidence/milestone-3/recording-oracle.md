# SPEC-006 T3.1 Canonical Recording Oracle Evidence

`GiftUISemanticCore` now provides the package-only closed recording vocabulary:
bounded symbolic roles; the exact root, custom-body, fixed-child, conditional-
branch, optional-presence, and declaration-role path components; and the five
structural, body, semantic, modifier, and action event cases required by
SPEC-006.

`SemanticRecordingSink` is generic over caller-owned recording storage and an
opaque recording identity that provides component-by-component canonical path
access. Dynamic fixtures may use array-backed storage while later static
fixtures provide fixed storage without changing event meaning. The sink
stages events through the storage, keeps them unpublished until the complete
summary matches all four counted event classes and greatest observed path
depth, and delegates atomic publish/discard/reset to that storage.

Focused `SemanticRecordingSinkTests` prove:

- an `EmptyView` root publishes one structural event at the exact two-component
  path, returns four zero counters, and reports `maximumObservedDepth == 2`;
- structural events never increment a summary counter;
- a custom-body event is staged at the custom-body path immediately before the
  returned declaration is evaluated and expanded;
- action-bearing nodes emit semantic then action events, and nested modifiers
  emit increasing chain indices after content;
- a test-only attempted-event log can retain the detecting event while the
  staged recording is discarded and the previous committed recording remains
  unchanged; and
- a count or maximum-depth mismatch refuses publication.

The checked-in semantic corpus now contains the `empty-root` input, exact
canonical transcript, normalized result, and symbolic identity-set row. Later
T3 tasks extend this same oracle; no layout, rendering, backend, runtime-
profile policy, failure fact, or connected-hardware claim is present.
