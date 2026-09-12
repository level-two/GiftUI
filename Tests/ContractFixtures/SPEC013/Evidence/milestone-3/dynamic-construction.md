# T3.1 Dynamic Profile Construction

Date: 2026-09-12

`GiftUIRuntimeDynamic` now owns one nonzero `DynamicStructuralIdentity` and a
typed failable construction value. Construction retains the exact successful
storage audit and immutable limits, accepts only the Dynamic profile, and
rejects both failed validation and any audit carrying Static Canvas limits.

The profile target continues to import only the focused owners and Runtime
Core permitted by SPEC-013. It does not import Static, a backend, platform,
driver, host, or failure authority. No public declaration or portable
Presentation profile-selection branch was added.

Verification commands:

```text
swift test --filter GiftUIRuntimeDynamicTests
scripts/contracts/check-spec-013-module-contract.sh
scripts/contracts/check-spec-013-harness.rb
```

Result: four focused construction and boundary tests passed under Apple Swift
6.3.3. Both SPEC-013 contract checks passed.
