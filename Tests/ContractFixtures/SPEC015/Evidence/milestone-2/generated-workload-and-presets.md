# SPEC-015 Milestone 2 — Generated Workload and Presets

The checked descriptor deterministically emits four schema-2 workload
manifests, one 164-row per-profile/per-leaf limit corpus, and immutable Swift
preset projections. The embedded source identity is
`3bd60ea9632d9c1ec5c6187b0e28452d0394d88672dfad4b7102ec32a3787dc6`.

Reproduction:

```sh
ruby scripts/contracts/check-spec-015-generated-workload.rb
swift test --filter GiftUIHostConfigurationTests
```

The focused tests prove complete runtime-limit construction and successful
SPEC-013 storage audit for each preset, exact render-workspace source/limit
relations, the `5/202/12/5/832/16/5` Drawing minima, checked combined operation
capacity `30 + 5 == 35`, dynamic/static optional-table separation, the equal
macOS projection, Pi `240 x 16` RGB565 region, and nRF52840 `480 x 4`, 960-byte
row, 3,840-byte raster/payload projection. Generation reads only the descriptor
and does not evaluate a client body or Canvas closure.
