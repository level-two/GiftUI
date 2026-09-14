# SPEC-004 Final Capability-Boundary Evidence

- Task: `T4.5`
- Evidence categories: exact package graph, compiled module/interface/product,
  portable-source audit
- Date: 2026-09-14
- Immutable macOS dynamic run ID:
  `5ea9e58559b676cd3b5200a6e96b0ce32506aa56-17ec6a3cec1f6fdd`

## Exact owner set

The boundary registry exactly names every regular target whose direct package
dependencies include `GiftUICapabilities`: surface, raster, display, backend
integration, host configuration, the capability/failure adapter, and the
hardware-free Signal Analyzer preset harness.

The dependency checker derives this set from the package dump and fails any
unregistered consumer or dependency drift. Every production consumer is
scanned for capability re-export and diagnostic coupling. A repository source
scan permits exactly one production `RasterPresentationResolver.resolve` call
site—the checked host validator—and excludes the capability implementation and
the explicitly hardware-free preset oracle from that count.

## Reproducible checks

```text
swift package --disable-sandbox dump-package | scripts/contracts/check-spec-004-dependencies.rb
scripts/contracts/check-spec-004-portable-source.rb
scripts/contracts/run-spec-004.sh --profile macos-dynamic
```

Results:

- exact SPEC-004 registry: 10 active entries and 14 forbidden upward imports;
- portable presentation scan: four source files, zero capability or concrete
  target-identity branches;
- standalone macOS dynamic driver: passed and published the immutable run ID
  above.

The standalone driver also passed the repository-wide target graph,
positive/negative import fixtures, generated public interface audit, compiled
dependency scan, product-link inspection, undefined-symbol checks, value
boundary, static-path, semantic corpus, and regression controls. This is host
execution evidence and makes no connected-target claim.
