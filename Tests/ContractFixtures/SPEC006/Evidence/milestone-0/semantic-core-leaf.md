# SPEC-006 Semantic Core Leaf

Plan task: `T0.2`

Date: 2026-09-04

`GiftUISemanticCore` is a package-internal production target with the sole
direct edge `GiftUISemanticCore -> GiftUI`. `GiftUI` remains dependency-free
and neither target is re-exported through the other. A focused import test
proves the empty leaf compiles before semantic declarations are introduced.

`GiftUISemanticFailureAdapterFixture` is unpublished and imports exactly
`GiftUIFailureCore` and `GiftUISemanticCore`. Its focused import test provides
the first test-only owner boundary without introducing mappings before T4.4.
Neither failure module imports GiftUI or Semantic Core.

SPEC-002's exact target/dependency allowlist and checks now include both
targets and their tests. The SPEC-006 registry adds the positive Semantic Core
import and reverse failure-import negatives. The package boundary rejects a
GiftUI-to-Semantic-Core edge, a failure-to-Semantic-Core edge, publishing the
internal targets as products, undeclared imports, or a dependency cycle.

Validation:

```text
scripts/format-swift.sh
swift package dump-package | scripts/contracts/check-target-dependencies.rb
swift test
scripts/test.sh
```

This step adds only importable target seams. It defines no declaration,
traversal, semantic result, failure mapping, runtime policy, or backend work.
