# SPEC-005 T4.3 Assembly and Lifecycle Evidence

T4.3 adds a contract-local, test-only assembly fixture. Build validation checks
the complete generated package against the bitmap and outline realization in
turn. Target assembly receives an immutable bitmap-linked view of the same
catalogue, validates its selected bitmap realization exactly once, and only
then publishes the package to simulated consumers.

Focused tests prove:

- no consumer receives a package before successful target validation;
- descriptors, tables, records, and payload access are exposed only through
  immutable protocol views and nested synchronous borrows;
- a teardown request retains host ownership while two simulated consumers are
  attached and releases the package after the last consumer detaches;
- an unavailable unselected outline payload remains catalogued but cannot be
  borrowed, while bitmap-selected validation remains valid; and
- failed selected-realization validation publishes neither metrics nor raster
  access and performs exactly one validation attempt.

The fixture defines no production layout, render, raster-provider, backend, or
runtime API. Those integrations remain governed by their downstream
Specifications and T4.4.

## Reproduction

```text
swift test --filter AssemblyLifecycleTests
scripts/contracts/check-spec-005-assembly-lifecycle.rb
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```
