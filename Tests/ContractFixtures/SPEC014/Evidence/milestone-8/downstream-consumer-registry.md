# SPEC-014 Downstream Host Consumer Registry

The SPEC-015 `GiftUIHostConfiguration` target is an approved downstream
consumer of SPEC-014's Backend Integration, Display Core, Raster Core, and
Surface Core owners. `downstream-consumers.tsv` records those four reverse
edges explicitly without classifying the host as a SPEC-014 owner or allowing
its dependencies to propagate transitively.

The module-contract checker compares the registered edge set with both
`Package.swift` and SPEC-002's target dependency registry. Unregistered,
missing, or additional edges fail. The host remains prohibited from importing
Drawing, drivers, Layout, platform, Render Lowering, or Semantic Core directly.

Validated on 2026-09-14 with:

```sh
scripts/contracts/run-spec-014.sh --profile macos-dynamic
```

The complete driver passed. This is host-side graph evidence only and makes no
connected-device claim.
