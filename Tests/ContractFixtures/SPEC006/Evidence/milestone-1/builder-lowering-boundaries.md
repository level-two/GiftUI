# SPEC-006 T1.3 Builder Lowering and Boundary Evidence

## Exact lowering

Focused `DeclarativeViewTests` assign the zero-child builder result directly to
`EmptyView` and the one-child result directly back to its concrete leaf type.
The assignments are compile-time type checks; they do not use reflection or an
existential. The zero-sized empty value is also verified at runtime.

The conditional fixture constructs each selected branch with an opposite
generic type whose initializer and body both trap. Traversing first and second
selections records exactly one matching visitor category apiece. Completion
therefore proves the inactive generic branch was neither instantiated nor
evaluated; its only traversal input is the approved metatype.

## Ordinary-client boundary

The fixture driver now removes package identity from every `public` row and
adds `-package-name GiftUI` only for rows explicitly classified `package`.
External negative fixtures prove both `EmptyView()` construction and tuple
child storage access fail due to package protection. The registered builder
surface audit independently rejects any public wrapper initializer or stored
child/branch, and the direct-six and loop fixtures continue to prove the
bounded builder has no sixth or `buildArray` overload.

## Representation audit

For both optimized macOS configurations, the contract driver emits whole-
module SIL for the two `GiftUI` declaration sources. The registered
`check-spec-006-wrapper-sil.rb` audit records zero occurrences of:

- heap allocation instructions or runtime allocation calls;
- existential initialization or opening;
- reflection entry points;
- runtime type discovery entry points.

The source audit also rejects `AnyView`, public storage, and dynamic-array
lowering. Raspberry Pi and nRF profiles compile the same value-only generic
source with whole-module optimization; no profile-specific wrapper
implementation exists.

## Boundary

This task proves construction lowering and wrapper representation only. It
does not claim the later bounded semantic expansion allocation record, owned-
value layouts, canonical transcript, or state-host traversal evidence, all of
which remain explicitly incomplete in the fail-closed contract reports.
