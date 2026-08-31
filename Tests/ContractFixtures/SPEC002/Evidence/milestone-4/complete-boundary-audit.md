# SPEC-002 T4.3 Complete Boundary Audit

**Task:** `T4.3`

**Recorded:** 2026-08-31

## Exact current package graph

The fail-closed dependency allow-list and `swift package dump-package` agree on
all 12 current targets and 15 direct edges, and both graphs are acyclic. The
audit found that `GiftUIFailureDiagnosticsTests` imports
`GiftUIFailureCore` directly while its manifest previously relied on a
transitive dependency. The manifest and both affected SPEC-002/SPEC-003
checked-in boundary allow-lists now record that direct edge explicitly.

Every current target has an audited `Sources/<target>` or `Tests/<target>`
Swift source tree. Each source import naming another current package target is
required to appear as a direct manifest edge. Exported imports are rejected in
all current target source trees.

## GiftUI compiled and linked boundary

The macOS dynamic and static drivers now build the `GiftUI` library as well as
its module, then inspect:

- the public and package interfaces for prohibited imports, exported imports,
  and prohibited qualified references;
- the compiler dependency scan for prohibited higher or concrete modules; and
- the linked image for prohibited GiftUI product dependencies.

The public and package interfaces retain only the approved SPEC-002 surface,
the compiled module has no prohibited package dependency, and neither library
image links a prohibited GiftUI module.

## Protected owner fixtures

The audit requires and the owning drivers execute a positive import and a
forbidden upward-import fixture for each protected owner:

| Owner | Positive fixture | Forbidden fixture |
| --- | --- | --- |
| `GiftUI` | `import-giftui` | `forbidden-runtime-import` |
| `GiftUIFailureCore` | `import-failure-core` | `forbidden-giftui-import` |
| `GiftUICapabilities` | `import-capabilities` | `forbidden-giftui-import` |

## Validation

Validated from the repository root on 2026-08-31:

- `ruby -c scripts/contracts/check-spec-002-boundaries.rb`
- `bash -n scripts/contracts/run-spec-002.sh`
- `scripts/contracts/run-spec-002.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-002.sh --profile macos-static`
- `swift test`
- `scripts/test.sh`

These are local macOS host checks. They do not claim Raspberry Pi, nRF, or
connected-hardware evidence. Any later package target or edge must fail the
exact-set audit until its ownership and fixture disposition are reviewed.
