# SPEC-004 T4.1 Foundation Extent Adapter Evidence

The first boundary that knows both SPEC-002 geometry and SPEC-004 capability
values is the approved test-only `GiftUICapabilityAdapterTests` target. It
imports `GiftUI` and `GiftUICapabilities`; neither production leaf imports the
other or the adapter.

Its exact `Size` conversion proves:

| Input | Result |
| --- | --- |
| width or height zero | `malformedRequirement(field: .extent)` |
| positive width or height above `UInt16.max` | `logicalExtentOverflow` |
| positive representable dimensions | complete `CapabilityExtent` value |
| negative dimension | rejected earlier by SPEC-002 `Size`; cannot enter the adapter |

The valid 640 x 480 control preserves both dimensions. Raw requirement tests
also prove malformed fields preceding extent win before conversion, while a
well-formed positive overflow retains the distinct logical-overflow reason.
No partial or clamped extent is exposed.

The checked exact target graph permits the test adapter’s two downward imports
and keeps `GiftUI` and `GiftUICapabilities` dependency-free. SPEC-004’s source,
compiled-interface, and product-link checks continue rejecting reciprocal
imports, re-export, and relocation of Foundation geometry.

Validated on 2026-08-30:

```text
swift test --filter GiftUICapabilityAdapterTests
scripts/contracts/run-spec-002.sh --profile macos-dynamic
```

Both passed. This is owner-boundary evidence, not a production host API.
