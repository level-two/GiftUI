# SPEC-006 T6.3 Dependency and Forbidden-Surface Evidence

The source and compiled-interface audit fixes Semantic Core to its sole `GiftUI`
dependency and an exact package declaration allow-list. It inventories every
`_GiftUI` reference and rejects unlisted compiled references, dynamic storage,
type erasure, reflection, concurrency/global-actor surfaces, Objective-C,
string identity paths, backend/platform/driver/runtime references, and legacy
dynamic/static traversal targets.

The existing migration checker remains a separate mandatory runner step and
compares every recorded PoC family/path count against the immutable tag. Test
instrumentation is outside the production-source scan and remains explicitly
named by its fixture artifacts.
