# SPEC-005 T3.2 Concrete Reference Package Evidence

T3.2 adds one package-internal `GiftUIReferenceTextResources` target. It
depends only on `GiftUI` and `GiftUITextResources`, is not exposed as a
library product, and owns immutable metric and raster views over the generated
reference catalogue and both adopted payloads.

## Validation

```text
swift test --filter GiftUIReferenceTextResourcesTests
swift test --filter AccessorBehaviorTests
scripts/contracts/check-spec-005-reference-generation.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
swift package dump-package | scripts/contracts/check-spec-005-dependencies.rb
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```

The focused reference-package suite validates the complete package exactly
once with bitmap realization `0` required and exactly once with outline
realization `1` required. Both return `.valid`. A second focused test borrows
all 204 generated glyph records and proves exact record byte counts plus the
required bitmap or outline structural grammar.

The first concrete-package validation exposed that the contract leaf rejected
the adopted space glyph's five-byte outline header. SPEC-005 explicitly allows
zero commands after the five-byte header, so the parser and focused accessor
test were corrected to admit that exact empty outline while retaining every
malformed-header and trailing-byte rejection.

Payload storage is record-local: each generated glyph owns a static tuple of
explicit `UInt8` values, with a maximum adopted record size of 447 bytes. This
avoids collection initialization and whole-payload tuple inference while
preserving exact gap-free digest order. Later static/allocation/resource tasks
retain responsibility for cross-profile and linked-image measurements.

This is macOS host and package-graph evidence. It makes no cross-build,
connected-hardware, deployment, service, or flashing claim.
