# SPEC-012 Contract Fixtures

This directory contains the profile-neutral fixture and evidence schemas
derived from implementing SPEC-012. The corpus freezes the exact public-source
witness registry, symbolic identity relationships, normalized semantic,
layout, cycle, drawing-plan, combined-render, and raster observations, local
failure precedence, and acceptance evidence. It does not select production
storage, a raster algorithm, host capacities, or a backend-specific drawing
meaning.

## Canonical fixture registries

`fixture-manifest.tsv` is the ordered registry for canonical YAML fixture
files. `fixtures.yaml` owns declaration, semantic, layout, cycle, path, plan,
render, startup, and failure cases. `raster-vectors.yaml` owns normalized
stroke inputs, binary coverage masks, and exact encoded bytes. Both manifests
begin empty; the implementation task that owns a behavior adds complete cases
without changing the frozen field vocabulary merely to fit an implementation.

Every case or vector name is globally unique lowercase kebab-case. Every row
must cite one or more `DR-001` through `DR-013` criteria and one or more
registered evidence classes. Drivers reject unregistered manifests, duplicate
names or order values, missing or unknown fields, unknown symbolic tokens,
unknown evidence classes, and criterion references that are not reciprocal
with `required-evidence.tsv`.

`declaration-compile-fixtures.tsv` and `negative-compile-fixtures.tsv` freeze
the supported and deliberately rejected public-source witness names. Positive
witnesses must compile; negative witnesses pass only when compilation fails
for the registered ownership, escape, exclusivity, or typed-error reason. A
Spike source is evidence only and is never an alternate maintained witness.

## Normalized observations

`normalized-fields.tsv` fixes the complete field vocabulary by domain. Tests
compare typed field values, exact ordering, counts, and nominal identity
relations; no production serialization format is implied. Empty and no-op
sequences remain explicit observations. `symbolic-tokens.tsv` defines nominal
fixture tokens such as `identity:<name>` and `cycle:<name>`. Tokens preserve
only the equality and lifetime relationships named by their authority. They
are never pointers, raw identity bytes, hashes, metatype addresses, or
profile-private storage.

`failure-precedence.tsv` freezes the ordered local detection vocabulary and
the exact SPEC-003 mapping. Startup rows precede drawing-attempt rows, which
precede offer-time rows. A fixture reports the first applicable row and must
record that no later check capable of invoking client code occurred.

## Evidence registry

`required-evidence.tsv` contains exactly `DR-001` through `DR-013`. Every row
begins `pending`; T0.1 creates a fail-closed evidence registry and satisfies no
acceptance criterion by itself.

Evidence classes remain distinct:

- `host-execution` runs a focused fixture on the build host.
- `cross-build` compiles or links a non-host artifact without executing it.
- `inspection` examines interfaces, SIL/IR, layouts, symbols, sections, stack,
  link maps, images, or ELF attributes without target execution.
- `simulator` executes through an explicitly named simulator.
- `connected-hardware` executes on an explicitly selected physical target and
  requires separate user authorization.

No SPEC-012 fixture or schema command deploys, accesses a remote target,
restarts a service, or flashes a board. ARMv6 and nRF52840 compiler, linker,
image, symbol, and ABI reports are cross-build or inspection evidence only.

