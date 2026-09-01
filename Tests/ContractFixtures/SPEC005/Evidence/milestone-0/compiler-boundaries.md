# SPEC-005 Compiler-Visible Boundaries

Plan task: `T0.4`

Date: 2026-09-01

## Compile fixtures

The ordered manifest contains one package-context positive import of
`GiftUITextResources` and sixteen public negative fixtures covering failure,
capability, layout, render, dynamic/static runtime, backend, concrete resource
implementation, platform, driver, host, OS/RTOS, HAL, and hardware owners.
Every profile compiles the positive row and requires each negative row to fail
with its exact missing-module diagnostic.

## Exact package and compiled graph

The checked target boundary requires `GiftUITextResources -> GiftUI` and
`GiftUITextResourcesTests -> GiftUITextResources`, rejects a standalone
text-resource product, and reserves pending rows for layout, render, raster,
backend, platform, concrete-package, and host consumers. A reserved target
appearing before its row is activated fails the check.

macOS interface and dependency scans prove the leaf imports only `GiftUI`,
`GiftUI` neither imports nor re-exports the leaf, and no prohibited owner is a
compiled dependency. The repository-wide source scan rejects nominal
`FontResourceID`, `FontInstanceID`, `GlyphID`, or `RasterRealizationID`
declarations outside the owning source root. The existing exact-set graph
checker independently rejects unknown edges and cycles.

## Portable Presentation

The Signal Analyzer portable Presentation source scan rejects text-resource,
concrete-package, raster-provider, backend, platform, driver, and host imports;
the four exact identity names; concrete target tokens; and `os`, `canImport`,
or `arch` conditional branches. It introduces no portable text-resource or
target-specific behavior.

All checks are structural hardware-free evidence. No layout, render, raster,
backend, platform, resource implementation, simulator, deployment, connected
target, or flashing behavior is claimed.
