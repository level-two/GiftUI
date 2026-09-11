# SPEC-008 Amendment Contract Evidence

The amendment prerequisite step adds the exact owner-provided dense ordinal
and immutable-snapshot surfaces to `SemanticRenderView` and
`ResolvedRenderLayoutView`. Focused owner and direct-view tests verify forward
and reverse lookup, in-range identity preservation, out-of-range rejection,
and snapshot exposure without introducing a second identity domain.

`RenderProductionWorkspace` now reports a separate nonzero
`RenderWorkspaceCapacity` and provides semantic/layout ordinal visit sets.
Focused tests prove inactive and out-of-capacity visits are `.invalid`, first
visits are `.first`, repeated visits are `.repeated`, acquisition clears both
sets, and reset permits an independent next attempt. Layout tests prove the
required exact 8-byte capacity value and exact 1-byte visit value.

The registered value-layout probe was rerun for all four SPEC-008 profiles and
reported 13 passing bounded values for each:

```text
scripts/contracts/check-spec-008-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-008-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-008-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-008-value-profiles.sh --profile nrf52840-embedded
```

The focused Swift tests and source/owner checks also pass:

```text
swift test --filter 'SemanticRenderViewTests|ResolvedRenderLayoutViewTests|RenderProductionValueTests|DirectRenderViewFixtureTests|RenderViewBorrowTests'
ruby scripts/contracts/check-spec-008-semantic-render-view.rb
ruby scripts/contracts/check-spec-008-resolved-render-layout-view.rb
ruby scripts/contracts/check-spec-008-render-production-values.rb
ruby scripts/contracts/check-spec-008-direct-render-views.rb
```

The ARMv6 and nRF52840 results are cross-compilation evidence only. This step
performs no deployment, simulator execution, connected-hardware execution, or
flashing.
