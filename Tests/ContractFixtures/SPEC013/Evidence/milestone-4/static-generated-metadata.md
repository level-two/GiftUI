# T4.1 Static Generated Metadata Integration

Date: 2026-09-12

`StaticGeneratedProfileMetadata` binds one generated observable-slot table,
one compile-time `GiftUIAction` specialization, one SPEC-012
`StaticCanvasCallableTable`, and separate dense coverage metadata. Construction
validates nonzero dense `0..<slotCount` observable identities without dynamic
lookup. Action decode uses the statically known raw-representable action type
and exact raw-value round trip.

The generated integration fixture names SHA-256 provenance for the checked
SPEC-010 portable-profile expansion and SPEC-012 Static Canvas manifest. It
contains two observable slots, three nonzero Canvas cases, exact capture byte
counts 8/12/0, and one complete switch. Runtime Static consumes these outputs;
it does not parse Presentation source or assign IDs.

Verification commands:

```text
swift test --filter GiftUIRuntimeStaticTests
scripts/contracts/check-spec-013-static-generated-fixture.rb
scripts/contracts/check-spec-013-harness.rb
```

Result: three focused Static tests passed under Apple Swift 6.3.3. The
fail-closed generated-source checker reproduced both input digests, two slot
bindings, three callable IDs, exact capture sizes, and 2,305 generated source
bytes. The SPEC-013 harness passed with the checker registered in the repository
gate.
