# SPEC-005 Text-Resource Contract Leaf

Plan task: `T0.2`

Date: 2026-09-01

## Package graph

The root package contains one regular target named exactly
`GiftUITextResources`. It depends only on `GiftUI` and has one focused
`GiftUITextResourcesTests` target. The test target depends on the contract leaf
and `GiftUI` so it can construct the SPEC-002 geometry values named by the
text-resource contract without a re-export.

The package products remain exactly `GiftUI`, `GiftUIFailureCore`,
`GiftUIFailureDiagnostics`, and `GiftUICapabilities`. There is no standalone
`GiftUITextResources` product, and the `GiftUI` target has no dependency on or
source import of the contract leaf.

The SPEC-002 exact target/dependency allow-list now includes both new targets
and preserves every existing target and direct edge. The general source,
interface, compiled-dependency, product-link, and cycle checker treats
`GiftUITextResources` as a prohibited upward dependency of `GiftUI`.

## Focused evidence

The focused unit test imports `GiftUITextResources`, proving the empty leaf is
buildable and importable through its package test dependency. The exact graph
checker proves the production target's sole direct dependency is `GiftUI` and
that the graph remains acyclic.

No failure, capability, layout, render, runtime, backend, resource
implementation, platform, driver, OS/RTOS, HAL, or hardware dependency or
declaration was added. Full positive and prohibited-import compile fixtures
remain owned by T0.4.
