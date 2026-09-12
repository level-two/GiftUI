# T3.4 Dynamic Canvas Callables and Conveniences

Date: 2026-09-12

`DynamicCanvasCallableStorage` is a bounded, occurrence-ordered
`CanvasInvocationSource`. Staging rejects duplicate identities and first
excess without changing stored order. Invocation performs no drawing or plan
algorithm: it calls the SPEC-012-owned non-returning Canvas bridge. Release
nils the retained payload exactly once; later invocation fails with the typed
Drawing invariant, and discard releases every still-live occurrence.

The separately published `GiftUIDynamicConveniences` product depends only on
`GiftUI`. Its `DynamicCanvas` declaration is an exact public type alias to
portable `Canvas`, so it adds no semantic case, runtime selection, callback
registry, or alternate behavior. The SPEC-013 module checker now enforces this
one-edge boundary and forbids Runtime, backend, platform, driver, and host
dependencies.

Verification commands:

```text
swift test --filter GiftUIRuntimeDynamicTests
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter GiftUIRuntimeDynamicTests
scripts/contracts/check-spec-013-module-contract.sh
ruby scripts/contracts/check-target-dependencies.rb < package.json
```

Result: twelve default-profile tests and thirteen Dynamic-profile tests passed
under Apple Swift 6.3.3. The Dynamic-only test invoked the exact staged closure
once with the requested size, released it, and observed the typed invariant on
later invocation. The package graph contains 57 acyclic targets and 180 direct
edges; both dependency checks passed.
