# SPEC-002 PF-008 Migration Ledger

This ledger is derived only from annotated tag `PoC`, tag object
`2b2837a66b94df38c7b74ead33ebbb54aa08a06d`, and dereferenced commit
`d5d6330432caa7c983d8dba35cf9f23c3800860b`. Line numbers below refer to that
commit. The PoC declarations and consumers are evidence, not authority.

Every disposition is `removed`, `recreated by SPEC-002`, or `owned by
SPEC-NNN`. No row authorizes preservation of a PoC implementation.

## Foundation declarations and behavior

| ID | PoC source | PoC evidence | Consumer / risk | Disposition |
| --- | --- | --- | --- | --- |
| `PF008-GS-001` | `Sources/GiftUI/Geometry/Point.swift:2` | `x` is a public mutable host-width `Int` | Every point producer and consumer observes host width and permits mutation | recreated by SPEC-002 as public immutable `GeometryScalar` (`Int32`) |
| `PF008-GS-002` | `Sources/GiftUI/Geometry/Point.swift:3` | `y` is a public mutable host-width `Int` | Every point producer and consumer observes host width and permits mutation | recreated by SPEC-002 as public immutable `GeometryScalar` (`Int32`) |
| `PF008-GS-003` | `Sources/GiftUI/Geometry/Point.swift:5-8` | public non-failable `Int` initializer | No fixed-width declaration or explicit conversion seam | recreated by SPEC-002 with exact immutable `Int32` fields |
| `PF008-GS-004` | `Sources/GiftUI/Geometry/Size.swift:2` | `width` is a public mutable host-width `Int` | Geometry, layout, rendering, integration, and tests | recreated by SPEC-002 as immutable `GeometryScalar` |
| `PF008-GS-005` | `Sources/GiftUI/Geometry/Size.swift:3` | `height` is a public mutable host-width `Int` | Geometry, layout, rendering, integration, and tests | recreated by SPEC-002 as immutable `GeometryScalar` |
| `PF008-GS-006` | `Sources/GiftUI/Geometry/Size.swift:5-9` | negative dimensions trigger `precondition`; initializer cannot report rejection | Trapping-only invalid-dimension path | recreated by SPEC-002 as `init?` returning `nil` |
| `PF008-GS-007` | `Sources/GiftUI/Geometry/Rect.swift:2` | `origin` is public mutable | All rectangle consumers can mutate a formerly constructed rectangle | recreated by SPEC-002 as immutable |
| `PF008-GS-008` | `Sources/GiftUI/Geometry/Rect.swift:3` | `size` is public mutable | Mutation bypasses construction-time edge validation | recreated by SPEC-002 as immutable |
| `PF008-GS-009` | `Sources/GiftUI/Geometry/Rect.swift:5-8` | initializer is non-failable and computes no exclusive edges | Overflow may remain latent until a consumer derives an edge | recreated by SPEC-002 as failable checked construction with total edges |
| `PF008-GS-010` | `Sources/GiftUI/Geometry/Rect.swift:10-22` | containment catches throwing subtraction and treats overflow as `false` | Rejection is collapsed into a hit-test result; no total `maxX`/`maxY` API | recreated by SPEC-002 with checked construction and half-open total-edge containment |
| `PF008-GS-011` | `Sources/GiftUI/Geometry/ProposedSize.swift:2` | `width` is public mutable `Int?` | Mutation can install a negative proposal after initialization | recreated by SPEC-002 as immutable `GeometryScalar?` |
| `PF008-GS-012` | `Sources/GiftUI/Geometry/ProposedSize.swift:3` | `height` is public mutable `Int?` | Mutation can install a negative proposal after initialization | recreated by SPEC-002 as immutable `GeometryScalar?` |
| `PF008-GS-013` | `Sources/GiftUI/Geometry/ProposedSize.swift:5-16` | two negative-value `precondition` paths; initializer cannot report rejection | Trapping-only invalid-proposal paths | recreated by SPEC-002 as failable construction preserving `nil` absence |
| `PF008-GS-014` | `Sources/GiftUI/Layout/LayoutArithmetic.swift:1-3` | package `LayoutArithmeticError.overflow` taxonomy | Competes with SPEC-002's local optional seam and SPEC-003's cross-layer owner | removed |
| `PF008-GS-015` | `Sources/GiftUI/Layout/LayoutArithmetic.swift:5-16` | package `add(Int, Int) throws -> Int` | Host-width throwing arithmetic | recreated by SPEC-002 as optional `GeometryScalar` result |
| `PF008-GS-016` | `Sources/GiftUI/Layout/LayoutArithmetic.swift:18-29` | package `subtract(Int, Int) throws -> Int` | Host-width throwing arithmetic | recreated by SPEC-002 as optional `GeometryScalar` result |
| `PF008-GS-017` | `Sources/GiftUI/Layout/LayoutArithmetic.swift:31-42` | package `multiply(Int, Int) throws -> Int` | Host-width throwing arithmetic | recreated by SPEC-002 as optional `GeometryScalar` result |
| `PF008-GS-018` | `Sources/GiftUI/Layout/LayoutArithmetic.swift:44-62` | `requireAdd`, `requireSubtract`, and `requireMultiply` erase optional/throwing rejection | Layout consumers receive trapping-only helpers | removed; later layout behavior is owned by SPEC-007 |
| `PF008-GS-019` | `Sources/GiftUI/Layout/LayoutArithmetic.swift:64-72` | private `require` calls `preconditionFailure` on overflow | Deterministic rejection becomes a process trap | removed |
| `PF008-IN-001` | `Sources/GiftUI/Input/InputEvent.swift:1` | public three-case `InputEvent` | Client API exposes integration traffic and has no bounded correlation/provenance | removed |
| `PF008-IN-002` | `Sources/GiftUI/Input/InputEvent.swift:2` | `pointerDown(Point)` | No source, sequence, ordinal, or presentation revision | recreated by SPEC-002 as package-SPI `PointerPhase.down` plus bounded event fields |
| `PF008-IN-003` | `Sources/GiftUI/Input/InputEvent.swift:3` | `pointerMove(Point)` | No source, sequence, ordinal, or presentation revision | recreated by SPEC-002 as package-SPI `PointerPhase.move` plus bounded event fields |
| `PF008-IN-004` | `Sources/GiftUI/Input/InputEvent.swift:4` | `pointerUp(Point)` | No source, sequence, ordinal, or presentation revision | recreated by SPEC-002 as package-SPI `PointerPhase.up` plus bounded event fields |
| `PF008-IN-005` | no PoC declaration | no source identity, sequence identity, ordinal, or presentation-revision wrapper exists | Absence permitted unbounded/uncorrelated producers | recreated by SPEC-002 as exact bounded package-SPI wrappers |

## Expected replacements and evidence owners

The following accountability table is exhaustive over the 24 declaration and
behavior rows above. “None” is an intentional absence, not permission for a
compatibility alias or shim. The named plan task owns implementation; the
named evidence seam must demonstrate the disposition.

| Ledger ID | Expected replacement declaration or absence | Implementation and evidence owner |
| --- | --- | --- |
| `PF008-GS-001` | `Point.x: GeometryScalar` as public immutable `Int32` storage | `T2.1`; `GiftUITests` declaration, copy, equality, and boundary tests |
| `PF008-GS-002` | `Point.y: GeometryScalar` as public immutable `Int32` storage | `T2.1`; `GiftUITests` declaration, copy, equality, and boundary tests |
| `PF008-GS-003` | `Point.init(x:y:)` accepting only `GeometryScalar` | `T2.1`; public positive compile fixture and `GiftUITests` |
| `PF008-GS-004` | `Size.width: GeometryScalar` as public immutable storage | `T2.1`; `GiftUITests` declaration and value-semantic tests |
| `PF008-GS-005` | `Size.height: GeometryScalar` as public immutable storage | `T2.1`; `GiftUITests` declaration and value-semantic tests |
| `PF008-GS-006` | `Size.init?(width:height:)` returning `nil` for either negative dimension | `T2.1`; table-driven valid, zero, and negative `GiftUITests` |
| `PF008-GS-007` | `Rect.origin: Point` as public immutable storage | `T2.1`; `GiftUITests` declaration and copy tests |
| `PF008-GS-008` | `Rect.size: Size` as public immutable storage | `T2.1`; `GiftUITests` declaration and copy tests |
| `PF008-GS-009` | `Rect.init?(origin:size:)` with checked exclusive-edge construction | `T2.1`/`T2.3`; rectangle boundary and rejected-construction tests |
| `PF008-GS-010` | Total `minX`, `minY`, `maxX`, `maxY` and half-open `contains(_:)` | `T2.3`; complete rectangle edge/containment corpus |
| `PF008-GS-011` | `ProposedSize.width: GeometryScalar?` as public immutable storage | `T2.1`; independent-absence and declaration tests |
| `PF008-GS-012` | `ProposedSize.height: GeometryScalar?` as public immutable storage | `T2.1`; independent-absence and declaration tests |
| `PF008-GS-013` | `ProposedSize.init?(width:height:)` returning `nil` for a negative present dimension | `T2.1`; absent, zero, ordinary, and negative proposal tests |
| `PF008-GS-014` | None; no Foundation arithmetic error taxonomy | `T2.4`; exported-declaration and forbidden-compatibility audit |
| `PF008-GS-015` | `GeometryArithmetic.add(_:_:) -> GeometryScalar?` as package SPI | `T2.2`; exhaustive add boundary/overflow tests |
| `PF008-GS-016` | `GeometryArithmetic.subtract(_:_:) -> GeometryScalar?` as package SPI | `T2.2`; exhaustive subtract boundary/overflow tests |
| `PF008-GS-017` | `GeometryArithmetic.multiply(_:_:) -> GeometryScalar?` as package SPI | `T2.2`; exhaustive multiply boundary/overflow tests |
| `PF008-GS-018` | None; no `requireAdd`, `requireSubtract`, or `requireMultiply` helper | `T2.4`; source and compiled-interface compatibility audit |
| `PF008-GS-019` | None; no overflow `preconditionFailure` path | `T2.4`; source audit plus overflow tests proving optional rejection |
| `PF008-IN-001` | None; no public `InputEvent` declaration or alias | `T3.3`; public-interface and forbidden-compatibility audit |
| `PF008-IN-002` | `PointerPhase.down = 0` and package-SPI `NormalizedPointerEvent` correlation fields | `T3.1`; package fixture and normalized-event value tests |
| `PF008-IN-003` | `PointerPhase.move = 1` and the same bounded event representation | `T3.1`; package fixture and normalized-event value tests |
| `PF008-IN-004` | `PointerPhase.up = 2` and the same bounded event representation | `T3.1`; package fixture and normalized-event value tests |
| `PF008-IN-005` | Package-SPI `InputSourceID(UInt16)`, `PointerSequenceID(UInt32)`, `InputOrdinal(UInt32)`, `PresentationRevision(UInt32)`, and `NormalizedPointerEvent` | `T3.1`/`T3.2`; raw-min/max, layout, copy, equality, and package compile fixtures |

The review rejects any replacement that preserves or introduces one of these
PoC failure modes:

- trapping-only construction or arithmetic;
- host-width or otherwise unbounded scalar/correlation representation;
- a public raw input family instead of the package-SPI normalized family;
- mutable stored properties in an owned Foundation value; or
- absent or sentinel provenance in a normalized pointer event.

The `T2.4` and `T3.3` compatibility audits must fail if any such shim exists,
even when the exact replacement declarations also compile.

### Normalized-input closure

| Ledger ID | Closure evidence | Status |
| --- | --- | --- |
| `PF008-IN-001` | Generated public interface contains only the five approved geometry owners; `check-foundation-surface.rb` rejects `InputEvent` and every public normalized-input owner | closed by `T3.3` |
| `PF008-IN-002` | Package interface fixes `PointerPhase.down`; min-coordinate/down-phase package fixture and value test pass | closed by `T3.1`/`T3.2` |
| `PF008-IN-003` | Package interface fixes `PointerPhase.move`; ordinary-coordinate/move-phase package fixture and value test pass | closed by `T3.1`/`T3.2` |
| `PF008-IN-004` | Package interface fixes `PointerPhase.up`; max-coordinate/up-phase package fixture and value test pass | closed by `T3.1`/`T3.2` |
| `PF008-IN-005` | Package interface and raw-width tests prove required non-optional `UInt16`/`UInt32` provenance and correlation fields; concrete/sentinel vocabulary is rejected | closed by `T3.2`/`T3.3` |

## Exact consumer inventory

The following lists are the complete files returned by `git grep -l` against
tag `PoC` for the governed names. A path can appear in more than one list.

### `Point`

```text
Sources/GiftUI/Geometry/Point.swift
Sources/GiftUI/Geometry/Rect.swift
Sources/GiftUI/Input/InputEvent.swift
Sources/GiftUI/Rendering/RenderBackend.swift
Sources/GiftUI/Rendering/RenderOperation.swift
Sources/GiftUI/Rendering/TextRun.swift
Sources/GiftUIBackendFramebuffer/BitmapTextRasterizer.swift
Sources/GiftUIBackendFramebuffer/FramebufferBackend.swift
Sources/GiftUIBackendFramebuffer/FramebufferSurface.swift
Sources/GiftUIBackendFramebuffer/MemoryFramebufferSurface.swift
Sources/GiftUIBackendRGB565/RGB565RetainedRenderer.swift
Sources/GiftUIBackendRGB565/RGB565TileRenderer.swift
Sources/GiftUIBackendRGB565/RGB565TileStorage.swift
Sources/GiftUIBuiltinFont/BuiltinFont8x12.swift
Sources/GiftUIDisplayILI9341/ILI9341Display.swift
Sources/GiftUIDisplayILI9341/ILI9341DisplayTransport.swift
Sources/GiftUIInputADS7846/ADS7846Calibration.swift
Sources/GiftUIInputADS7846/ADS7846TouchProcessor.swift
Sources/GiftUIPlatformLinux/DisplaySurface.swift
Sources/GiftUIPlatformLinux/FocusInputAdapter.swift
Sources/GiftUIPlatformLinux/GiftUILinuxApplication.swift
Sources/GiftUIPlatformLinux/LinuxFramebufferDisplaySurface.swift
Sources/GiftUIPlatformRaspberryPi/GPIOInputSource.swift
Sources/GiftUIPlatformRaspberryPi/TouchCoordinateMapper.swift
Sources/GiftUIPlatformRaspberryPi/TouchInputSource.swift
Sources/GiftUIRuntimeDynamic/DynamicLayoutSnapshot.swift
Sources/GiftUIRuntimeDynamic/GiftUIApplication.swift
Sources/GiftUIRuntimeDynamic/HitTestMap.swift
Sources/GiftUIRuntimeDynamic/ViewGraph.swift
Sources/GiftUIRuntimeDynamic/ViewNode.swift
Sources/GiftUIRuntimeStatic/StaticRuntime.swift
Sources/GiftUISimulatorMac/FramebufferView.swift
Sources/GiftUISimulatorMac/MouseInputAdapter.swift
Tests/GiftUIBackendFramebufferTests/GiftUIBackendFramebufferTests.swift
Tests/GiftUIBackendRGB565Tests/RGB565TileRendererTests.swift
Tests/GiftUIDisplayILI9341Tests/ILI9341DisplayTests.swift
Tests/GiftUIInputADS7846Tests/ADS7846CalibrationTests.swift
Tests/GiftUIInputADS7846Tests/ADS7846StaticDispatchTests.swift
Tests/GiftUIInputADS7846Tests/ADS7846TouchProcessorTests.swift
Tests/GiftUIInputADS7846Tests/XPT2046CompatibilityTests.swift
Tests/GiftUIIntegrationTests/GiftUIIntegrationTests.swift
Tests/GiftUIPlatformLinuxTests/GiftUIPlatformLinuxTests.swift
Tests/GiftUIPlatformRaspberryPiTests/GiftUIPlatformRaspberryPiTests.swift
Tests/GiftUIRuntimeDynamicTests/DynamicGraphTests.swift
Tests/GiftUIRuntimeDynamicTests/GiftUIRuntimeDynamicTests.swift
Tests/GiftUIRuntimeStaticTests/GiftUIRuntimeStaticTests.swift
Tests/GiftUITests/GiftUITests.swift
firmware/nrf52840/applications/ili9486/CMakeLists.txt
firmware/nrf52840/applications/ili9486/src/ILI9486BringUp.swift
firmware/nrf52840/applications/kmrtm24024_spi/CMakeLists.txt
firmware/nrf52840/applications/kmrtm24024_spi/src/KMRTM24024SPIApplication.swift
scripts/nrf52840/compile-layer.sh
scripts/raspberry-pi/probe/Sources/GiftUIToolchainProbe/main.swift
```

### `Size`, `Rect`, and `ProposedSize`

```text
Sources/GiftUI/Geometry/ProposedSize.swift
Sources/GiftUI/Geometry/Rect.swift
Sources/GiftUI/Geometry/Size.swift
Sources/GiftUI/Input/HitRegion.swift
Sources/GiftUI/Rendering/RenderBackend.swift
Sources/GiftUI/Rendering/RenderOperation.swift
Sources/GiftUIBackendFramebuffer/FramebufferBackend.swift
Sources/GiftUIBackendRGB565/RGB565RendererConfiguration.swift
Sources/GiftUIBackendRGB565/RGB565RetainedRenderer.swift
Sources/GiftUIBackendRGB565/RGB565TileRenderer.swift
Sources/GiftUIDisplayILI9341/ILI9341Display.swift
Sources/GiftUIDisplayILI9341/ILI9341DisplayConfiguration.swift
Sources/GiftUIDisplayILI9341/ILI9341DisplayTransport.swift
Sources/GiftUIExampleThermostat/main.swift
Sources/GiftUIInputADS7846/ADS7846Calibration.swift
Sources/GiftUIInputADS7846/ADS7846TouchProcessor.swift
Sources/GiftUIPlatformLinux/DisplaySurface.swift
Sources/GiftUIPlatformLinux/GiftUILinuxApplication.swift
Sources/GiftUIPlatformLinux/LinuxFramebufferDisplaySurface.swift
Sources/GiftUIPlatformRaspberryPi/RaspberryPiConfiguration.swift
Sources/GiftUIPlatformRaspberryPi/RaspberryPiPlatform.swift
Sources/GiftUIPlatformRaspberryPi/TouchCoordinateMapper.swift
Sources/GiftUIPlatformRaspberryPi/TouchInputSource.swift
Sources/GiftUIRuntimeDynamic/DynamicRuntime.swift
Sources/GiftUIRuntimeDynamic/GiftUIApplication.swift
Sources/GiftUIRuntimeDynamic/LayoutEngine.swift
Sources/GiftUIRuntimeDynamic/LayoutNode.swift
Sources/GiftUIRuntimeDynamic/ViewGraph.swift
Sources/GiftUIRuntimeDynamic/ViewNode.swift
Sources/GiftUIRuntimeStatic/StaticRuntime.swift
Sources/GiftUISimulatorMac/FramebufferView.swift
Sources/GiftUISimulatorMac/SimulatorApplication.swift
Sources/GiftUISimulatorMac/SimulatorWindow.swift
Tests/GiftUIBackendFramebufferTests/GiftUIBackendFramebufferTests.swift
Tests/GiftUIBackendRGB565Tests/RGB565FoundationTests.swift
Tests/GiftUIBackendRGB565Tests/RGB565StaticIntegrationTests.swift
Tests/GiftUIBackendRGB565Tests/RGB565TileRendererTests.swift
Tests/GiftUIDisplayILI9341Tests/ILI9341DisplayTests.swift
Tests/GiftUIDynamicConveniencesTests/GiftUIDynamicConveniencesTests.swift
Tests/GiftUIInputADS7846Tests/ADS7846CalibrationTests.swift
Tests/GiftUIInputADS7846Tests/ADS7846StaticDispatchTests.swift
Tests/GiftUIInputADS7846Tests/ADS7846TouchProcessorTests.swift
Tests/GiftUIInputADS7846Tests/XPT2046CompatibilityTests.swift
Tests/GiftUIIntegrationTests/GiftUIIntegrationTests.swift
Tests/GiftUIPlatformLinuxTests/GiftUIPlatformLinuxTests.swift
Tests/GiftUIPlatformRaspberryPiTests/GiftUIPlatformRaspberryPiTests.swift
Tests/GiftUIRuntimeConformanceTests/GiftUIRuntimeConformanceTests.swift
Tests/GiftUIRuntimeDynamicTests/DynamicGraphTests.swift
Tests/GiftUIRuntimeDynamicTests/GiftUIRuntimeDynamicTests.swift
Tests/GiftUIRuntimeStaticTests/GiftUIRuntimeStaticTests.swift
Tests/GiftUITests/GiftUITests.swift
firmware/nrf52840/applications/ili9486/CMakeLists.txt
firmware/nrf52840/applications/ili9486/src/ILI9486BringUp.swift
firmware/nrf52840/applications/kmrtm24024_spi/CMakeLists.txt
firmware/nrf52840/applications/kmrtm24024_spi/src/KMRTM24024SPIApplication.swift
scripts/nrf52840/compile-layer.sh
```

### `LayoutArithmetic`

```text
Sources/GiftUI/Geometry/Rect.swift
Sources/GiftUI/Layout/LayoutArithmetic.swift
Sources/GiftUIRuntimeDynamic/ViewGraph.swift
Sources/GiftUIRuntimeDynamic/ViewNode.swift
Tests/GiftUITests/GiftUITests.swift
firmware/nrf52840/applications/ili9486/CMakeLists.txt
firmware/nrf52840/applications/kmrtm24024_spi/CMakeLists.txt
scripts/nrf52840/compile-layer.sh
```

### `InputEvent`

```text
Sources/GiftUI/Input/InputEvent.swift
Sources/GiftUIInputADS7846/ADS7846TouchProcessor.swift
Sources/GiftUIPlatformLinux/FocusInputAdapter.swift
Sources/GiftUIPlatformLinux/GiftUILinuxApplication.swift
Sources/GiftUIPlatformLinux/LinuxInputSource.swift
Sources/GiftUIPlatformRaspberryPi/TouchInputSource.swift
Sources/GiftUIRuntimeDynamic/GiftUIApplication.swift
Sources/GiftUISimulatorMac/FramebufferView.swift
Sources/GiftUISimulatorMac/SimulatorApplication.swift
firmware/nrf52840/applications/ili9486/CMakeLists.txt
firmware/nrf52840/applications/ili9486/src/ILI9486BringUp.swift
firmware/nrf52840/applications/kmrtm24024_spi/CMakeLists.txt
firmware/nrf52840/applications/kmrtm24024_spi/src/KMRTM24024SPIApplication.swift
scripts/nrf52840/compile-layer.sh
```

## Consumer ownership disposition

| PoC consumer family | Exact PoC paths | Disposition |
| --- | --- | --- |
| Foundation geometry and normalized input declarations | `Sources/GiftUI/Geometry/`, `Sources/GiftUI/Layout/LayoutArithmetic.swift`, `Sources/GiftUI/Input/InputEvent.swift` | removed, then recreated by SPEC-002 only from its exact declarations |
| Declarative composition and primitive consumers | remaining `Sources/GiftUI/Composition/`, `Containers/`, `PrimitiveViews/`, `View/`, and `Runtime/` paths | owned by SPEC-006 and SPEC-013; removed |
| Hit/action declarations | `Sources/GiftUI/Input/ActionID.swift`, `Sources/GiftUI/Input/HitRegion.swift` | owned by SPEC-011; removed |
| Render declarations and consumers | `Sources/GiftUI/Rendering/` | owned by SPEC-005, SPEC-008, and SPEC-012 as applicable; removed |
| Dynamic/static runtime consumers | `Sources/GiftUIRuntimeDynamic/`, `Sources/GiftUIRuntimeStatic/` | owned by SPEC-009, SPEC-010, and SPEC-013; removed |
| Backend/raster consumers | `Sources/GiftUIBackendFramebuffer/`, `Sources/GiftUIBackendRGB565/` | owned by SPEC-014; removed |
| Font consumers | `Sources/GiftUIBuiltinFont/` | owned by SPEC-005 and downstream SPEC-008/SPEC-014 contracts; removed |
| Input, display, simulator, Linux, and Raspberry Pi consumers | `Sources/GiftUIInputADS7846/`, `Sources/GiftUIDisplayILI9341/`, `Sources/GiftUISimulatorMac/`, `Sources/GiftUIPlatformLinux/`, `Sources/GiftUIPlatformRaspberryPi/`, `Sources/CGiftUILinux/` | owned by SPEC-011, SPEC-014, and SPEC-015 at their respective seams; removed |
| Thermostat consumers | every `Sources/GiftUIExampleThermostat*/` path | no MVP replacement owner; removed |
| PoC tests | every tracked `Tests/*Tests/` path present in tag `PoC` | owned by the same Specification as the exercised implementation; removed; no test helper is copied |
| PoC firmware consumers | `firmware/nrf52840/applications/ili9486/`, `firmware/nrf52840/applications/kmrtm24024_spi/`, and `firmware/nrf52840/applications/skeleton/` | owned by future SPEC-014/SPEC-015 production assembly or no replacement where sample-only; removed |
| Hard-coded compilation | `scripts/nrf52840/compile-layer.sh` | no reusable environment purpose; removed |

## Final row closure audit

This 2026-08-31 audit re-runs the immutable PoC inventories and assigns every
declaration/behavior row a current implementation location or an exact
intentional-absence check. There are no approved exceptions and no remaining
owner blockers for these 24 SPEC-002 rows. Downstream consumer families remain
removed until their separately approved owning Specifications implement them.

| Ledger ID | Final code, removal, or absence evidence | Status |
| --- | --- | --- |
| `PF008-GS-001` | `Sources/GiftUI/GiftUI.swift:1-5`; exact `Int32` alias and immutable `Point.x` | closed |
| `PF008-GS-002` | `Sources/GiftUI/GiftUI.swift:1-5`; exact `Int32` alias and immutable `Point.y` | closed |
| `PF008-GS-003` | `Sources/GiftUI/GiftUI.swift:7-10`; exact public fixed-width initializer | closed |
| `PF008-GS-004` | `Sources/GiftUI/GiftUI.swift:13-15`; immutable `Size.width` | closed |
| `PF008-GS-005` | `Sources/GiftUI/GiftUI.swift:13-15`; immutable `Size.height` | closed |
| `PF008-GS-006` | `Sources/GiftUI/GiftUI.swift:17-23`; failable negative-dimension rejection | closed |
| `PF008-GS-007` | `Sources/GiftUI/GiftUI.swift:26-28`; immutable `Rect.origin` | closed |
| `PF008-GS-008` | `Sources/GiftUI/GiftUI.swift:26-28`; immutable `Rect.size` | closed |
| `PF008-GS-009` | `Sources/GiftUI/GiftUI.swift:30-37`; failable checked-edge construction | closed |
| `PF008-GS-010` | `Sources/GiftUI/GiftUI.swift:39-55`; total edges and half-open containment | closed |
| `PF008-GS-011` | `Sources/GiftUI/GiftUI.swift:58-60`; immutable optional proposal width | closed |
| `PF008-GS-012` | `Sources/GiftUI/GiftUI.swift:58-60`; immutable optional proposal height | closed |
| `PF008-GS-013` | `Sources/GiftUI/GiftUI.swift:62-74`; failable present-negative rejection and independent absence | closed |
| `PF008-GS-014` | `check-spec-002-migration.rb` and compiled-surface audit reject legacy arithmetic error vocabulary | closed |
| `PF008-GS-015` | `Sources/GiftUI/GiftUI.swift:77-84`; package optional checked add | closed |
| `PF008-GS-016` | `Sources/GiftUI/GiftUI.swift:86-92`; package optional checked subtract | closed |
| `PF008-GS-017` | `Sources/GiftUI/GiftUI.swift:94-100`; package optional checked multiply | closed |
| `PF008-GS-018` | `check-spec-002-migration.rb` rejects all three legacy trapping helper names | closed |
| `PF008-GS-019` | `check-spec-002-migration.rb` rejects Foundation preconditions and fatal traps | closed |
| `PF008-IN-001` | Public-interface audit and `check-spec-002-migration.rb` reject a public `InputEvent` shim | closed |
| `PF008-IN-002` | `Sources/GiftUI/GiftUI.swift:103-107,141-163`; package down phase and mandatory event fields | closed |
| `PF008-IN-003` | `Sources/GiftUI/GiftUI.swift:103-107,141-163`; package move phase and mandatory event fields | closed |
| `PF008-IN-004` | `Sources/GiftUI/GiftUI.swift:103-107,141-163`; package up phase and mandatory event fields | closed |
| `PF008-IN-005` | `Sources/GiftUI/GiftUI.swift:109-163`; exact `UInt16`/`UInt32` wrappers and non-optional provenance | closed |

`scripts/contracts/check-spec-002-migration.rb` fails if the annotated tag or
peeled commit changes, any governed-name inventory count/hash changes, closure
rows are missing or reordered, the exact Foundation source inventory changes,
or a mutable, trapping, host-compatibility, or public-input shim appears.

## Package-edge inventory

The PoC root manifest places Foundation in target `GiftUI`. These are every
direct target dependency edge to `GiftUI` in that manifest:

```text
GiftUIDynamicConveniences -> GiftUI
GiftUIRuntimeDynamic -> GiftUI
GiftUIRuntimeStatic -> GiftUI
GiftUIBackendFramebuffer -> GiftUI
GiftUIBackendRGB565 -> GiftUI
GiftUIInputADS7846 -> GiftUI
GiftUIDisplayILI9341 -> GiftUI
GiftUISimulatorMac -> GiftUI
GiftUIPlatformLinux -> GiftUI
GiftUIPlatformRaspberryPi -> GiftUI
GiftUIExampleThermostatView -> GiftUI
GiftUIExampleThermostatPortableView -> GiftUI
GiftUIExampleThermostat -> GiftUI
GiftUITests -> GiftUI
GiftUIDynamicConveniencesTests -> GiftUI
GiftUIDisplayILI9341Tests -> GiftUI
GiftUIIntegrationTests -> GiftUI
GiftUIPlatformLinuxTests -> GiftUI
```

The old manifest and all of its edges are removed. SPEC-002 later recreates a
minimal one-package manifest containing only the stable `GiftUI` product,
`GiftUI` target, and its contract tests. Downstream edges are introduced only
by their owning ready plans and must enter the exact dependency allow-list.

## Reproduction

The governed-name inventory is reproduced with:

```sh
git grep -l Point PoC -- Sources Tests firmware scripts
git grep -l Size PoC -- Sources Tests firmware scripts
git grep -l Rect PoC -- Sources Tests firmware scripts
git grep -l ProposedSize PoC -- Sources Tests firmware scripts
git grep -l LayoutArithmetic PoC -- Sources Tests firmware scripts
git grep -l InputEvent PoC -- Sources Tests firmware scripts
```

The declaration table is reproduced with `git show PoC:<path>` for each
Foundation source named above. Any newly discovered PoC declaration, mutable
field, precondition, throwing/trapping path, input case, consumer file, or
direct `GiftUI` edge must receive a ledger row before the clean cut.
