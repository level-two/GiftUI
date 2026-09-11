# T7.1 Final Boundary Audit

The final audit proves the production target remains exactly
`GiftUILayout -> GiftUISemanticCore -> GiftUI` and
`GiftUILayout -> GiftUITextResources -> GiftUI`. `GiftUIRenderCore` remains a
sibling, Semantic Core has no reverse layout edge, and portable `GiftUI`
neither imports nor re-exports layout. The test target alone additionally
depends on `GiftUIReferenceTextResources` for the required SPEC-005 goldens.

The registered negative boundary categories reject failure core,
capabilities, render, runtime, backend, platform, driver, OS/RTOS, HAL, and
hardware dependencies. Declaration, bounded-value, semantic-borrow, and
migration audits pass with no maintained parallel layout path.

Reproduce with:

```sh
scripts/contracts/check-spec-007-boundaries.rb
scripts/contracts/check-spec-007-semantic-boundary.rb
scripts/contracts/check-spec-007-declarations.sh
scripts/contracts/check-spec-007-values.rb
scripts/contracts/check-spec-007-migration.rb
```
