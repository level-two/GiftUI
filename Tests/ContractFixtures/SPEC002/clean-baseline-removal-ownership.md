# SPEC-002 Clean-Baseline Removal Ownership

This record applies implementation-plan task `T0.4` to the exact confirmed
175-path set in
[`clean-baseline-remove-paths.txt`](clean-baseline-remove-paths.txt). It assigns
one replacement owner or explicit no-replacement disposition to every removed
path. It does not retain any implementation and does not claim that a later
owner is implemented.

The maintainer explicitly confirmed the complete removal set in the Codex
thread on 2026-08-29 after reviewing the checked-in path manifest and its
SHA-256 `181af546c12a4fcf861bd76511494fcef841974c6c41f79d0e6d3cacd83b1922`.

## Exact ownership rules

The rules below are disjoint over the confirmed set. A path not matching
exactly one row blocks the cut.

| Exact path or path prefix in the confirmed set | Replacement owner / disposition |
| --- | --- |
| `Sources/GiftUI/Geometry/` | SPEC-002; remove and recreate only its exact checked immutable geometry declarations |
| `Sources/GiftUI/Layout/LayoutArithmetic.swift` | SPEC-002; remove and recreate only `GeometryArithmetic` |
| `Sources/GiftUI/Input/InputEvent.swift` | SPEC-002; remove public PoC event and recreate only the package-SPI normalized value family |
| `Sources/GiftUI/Composition/`, `Sources/GiftUI/Containers/`, `Sources/GiftUI/PrimitiveViews/`, `Sources/GiftUI/View/`, `Sources/GiftUI/GiftUI.swift`, `Sources/GiftUIDynamicConveniences/` | SPEC-006 declarative contract; remove with no retained implementation |
| `Sources/GiftUI/Input/ActionID.swift`, `Sources/GiftUI/Input/HitRegion.swift` | SPEC-011 interaction contract; remove with no retained implementation |
| `Sources/GiftUI/Rendering/TextRun.swift`, `Sources/GiftUIBuiltinFont/` | SPEC-005 text-resource contract; remove with no retained implementation |
| remaining `Sources/GiftUI/Rendering/` paths | SPEC-008 rendering contract; remove with no retained implementation |
| `Sources/GiftUI/Runtime/RuntimeProfile.swift` | SPEC-013 runtime-profile contract; remove with no retained implementation |
| `Sources/GiftUIRuntimeDynamic/`, `Sources/GiftUIRuntimeStatic/` | SPEC-009, SPEC-010, and SPEC-013 are coordinated owners; SPEC-013 is the single recreation owner for profile realization after its dependencies exist; remove all PoC code now |
| `Sources/GiftUIBackendFramebuffer/`, `Sources/GiftUIBackendRGB565/`, `Sources/GiftUIDisplayILI9341/` | SPEC-014 backend-integration contract; remove with no retained implementation |
| `Sources/GiftUIInputADS7846/`, `Sources/GiftUISimulatorMac/`, `Sources/GiftUIPlatformLinux/`, `Sources/GiftUIPlatformRaspberryPi/`, `Sources/CGiftUILinux/` | SPEC-015 host-configuration contract is the single future assembly owner; it must consume SPEC-011/SPEC-014 seams and may not retain this platform-owned stack |
| `Sources/GiftUIExampleThermostat/`, `Sources/GiftUIExampleThermostatView/`, `Sources/GiftUIExampleThermostatPortableView/`, `Sources/GiftUIExampleThermostatRaspberryPi/` | explicit no-replacement disposition; Thermostat is not the MVP reference application |
| each `Tests/<OldTarget>Tests/` path | same owner as its exercised source family above; explicit no-replacement for Thermostat-only integration; remove every PoC test and copy no helper |
| `firmware/nrf52840/applications/ili9486/`, `firmware/nrf52840/applications/kmrtm24024_spi/`, `firmware/nrf52840/applications/skeleton/` | SPEC-015 is the single future production-assembly owner, consuming SPEC-014 display/transport and SPEC-011 input seams; remove every PoC application file now |
| `scripts/nrf52840/compile-layer.sh` | explicit no-replacement disposition; hard-coded old module/source compilation is not reusable environment infrastructure |
| `.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata` | explicit no-replacement disposition; generated PoC package workspace metadata |
| each listed `docs/GiftUI_*.md` path | explicit historical-only disposition; remove active copy and retrieve from immutable tag `PoC` through `docs/engineering/POC_HISTORICAL_BASELINE.md` |

For old tests whose target name combines several old sources, the owner is the
Specification governing the behavior primarily asserted by that test target:

| Test target | Single removal/recreation owner |
| --- | --- |
| `GiftUITests` | SPEC-002 only for old geometry/arithmetic evidence; all other assertions are removed for their later owners and no file is copied |
| `GiftUIDynamicConveniencesTests` | SPEC-006 |
| `GiftUIRuntimeDynamicTests`, `GiftUIRuntimeStaticTests`, `GiftUIRuntimeConformanceTests` | SPEC-013 |
| `GiftUIBackendFramebufferTests`, `GiftUIBackendRGB565Tests`, `GiftUIDisplayILI9341Tests` | SPEC-014 |
| `GiftUIInputADS7846Tests` | SPEC-015 |
| `GiftUIPlatformLinuxTests`, `GiftUIPlatformRaspberryPiTests`, `GiftUIIntegrationTests` | SPEC-015 |

## Removal invariant

The clean cut removes all confirmed paths and retains none of their source,
test, firmware, document, package-workspace, or hard-coded compilation
implementation. Later plans may recreate only their approved Specification's
contract. The tag-derived SPEC-002 ledger and contract-fixture evidence remain
outside the removal set.
