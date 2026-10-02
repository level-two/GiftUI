# T10.1 — Production ownership baseline (2026-10-02)

Evidence lane: cross-build-inspection and source audit. Baseline source: the
working tree recorded by the source hashes in `selected-sources.tsv`;
use the hashes rather than the branch name to identify the inspected inputs.
The two pre-existing changes added Milestone 10 and its pending evidence rows.
SPEC-001 remains implementing; no contract or status approval is inferred.

## Reproduction and compiler result

- `python3 scripts/contracts/inventory-spec-001-production-sources.py` records
  the exact SwiftPM target/dependency inventory and all 133 CMake-selected Swift
  files, imports, hashes, and embedded branches. `targets.tsv` distinguishes
  test targets from production libraries and executables.
- `scripts/contracts/check-spec-001-embedded-owner-feasibility.sh` emits separate
  canonical GiftUI, GiftUITextResources, GiftUISemanticCore, and GiftUILayout
  modules using pinned Swift 6.3.2, Embedded mode, ARMv7E-M and Cortex-M4F
  hard-float flags. All four pass. The declaration-only macro plugin warning
  on GiftUI is recorded; no macro is expanded by this check.
- The maintained Layout implementation with an added runtime import fails
  with `no such module 'GiftUIRuntimeDynamic'` in that isolated owner closure.
  Positive owner source and forbidden edge checks therefore use the target
  compiler, not a host-only or preprocessed single-module surrogate.
- `scripts/nrf52840/doctor.sh` passes. The unchanged production build through
  `scripts/nrf52840/build.sh --application signal-analyzer-static` passes its
  ARMv7E-M/VFP inspection at 195,008 bytes RAM and 241,052 bytes flash.
  Artifact paths are `.build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf`,
  `zephyr.hex`, `zephyr.map`, `zephyr.dts`, and `reports/`.
- No production source was changed by this audit: linked resource delta is
  zero. Module emission is feasibility evidence, not an estimate of the final
  canonical firmware's size, zero-heap behavior, or execution. T10.4 must
  measure those after the actual consumer join.

## Contract producer/consumer ledger

| Contract or resource | Current production producer / consumer | Canonical owner | Disposition |
| --- | --- | --- | --- |
| SemanticLayoutPrimitive, SemanticLayoutModifier, SemanticLayoutView | EmbeddedLayoutInterfaces / EmbeddedLayoutAdapters, common Layout algorithm | GiftUISemanticCore | Duplicate authority; replace declarations, retain packed UInt16 projection |
| FontResourceID, FontInstanceID | Local UInt8/constant resource surrogate / embedded metrics, resolved layout, render preflight | GiftUITextResources | Incorrect identity meaning; consume canonical digest plus instance index |
| GlyphID, GlyphMapping, FontLineMetrics, GlyphMetrics | EmbeddedLayoutInterfaces / embedded measurement and glyph stream | GiftUITextResources | Duplicate declarations; keep generated metric lookup only |
| FontInstanceDescriptor, TextResourceDescriptor | EmbeddedLayoutInterfaces / embedded metrics and raster | GiftUITextResources | Local descriptors omit mapping/schema/manifest information and synthesize constants |
| TextResourceDigest, RasterRealizationID, TextRasterKind | EmbeddedLayoutInterfaces / embedded raster | GiftUITextResources | Duplicate declarations; canonical kind also includes packagedOutline |
| RasterRealizationDescriptor, GlyphRasterRecord | EmbeddedLayoutInterfaces / embedded font raster, common raster provider | GiftUITextResources | Duplicate declarations; retain bitmap borrowing and exact realization |
| CanonicalTextMetricsView, TextRasterResourceView | EmbeddedLayoutInterfaces / Layout, RenderLowering, RasterCore | GiftUITextResources | Duplicate protocols; local metrics omits canonical mapping enumeration |
| Packed semantic/topology/text/layout records | Generated NRF records and embedded codec projections | SignalAnalyzer target-host storage implementing owner contracts | Healthy fixed storage; preserve capacity, identity equality and borrow lifetime |
| Reference metrics and bitmap data | Generated NRF metrics, ReferenceBitmapPayload | Concrete selected text resource package | Healthy asset projection only if canonical checked identity survives all joins |
| Pi compact Inter metrics and raster selection | PiAssembly.textResources / DynamicPresentationPipeline and PiEndpoint | Host selects; GiftUITextResources defines compatibility | Healthy host selection, unhealthy pipeline-to-PiAssembly lookup; T10.3 injects selected view |
| Target clock, touch normalization, SPI transport, scheduler | Firmware C adapters and Pi platform/host loop | Target hosting and device integration | Healthy boundary; remain host-specific |
| Nine failure adapter fixtures | Test fixture targets in targets.tsv | Focused owner adapters with SPEC-003 correlation | Test evidence, not production dependencies or a consolidation mandate |

## Production pipeline stages

| Stage | Dynamic Pi path | Embedded nRF path | Owner |
| --- | --- | --- | --- |
| Ingress/seal/fact application | PiWakeAdmission, PiLifecycleOwner, HostFactAdmission | firmware production_host, compact fact ring, SealedFactApplication | Host ingress; execution admission and application mapping |
| Observable begin/semantic | DynamicPresentationPipeline.derive, Dynamic root/reconciler | StaticPreset, model/topology writer, packed semantic validation | ObservableState / SemanticCore; RuntimeCore sequences |
| Layout | DynamicPresentationPipeline.derive | CommonLayoutPass and embedded adapters | GiftUILayout |
| Canvas/path/plan | CanvasPlanProducer called by DynamicPresentationPipeline | EmbeddedCanvasSource and fixed DrawingWorkspace | GiftUIDrawing |
| Combined render/preflight | DynamicPresentationPipeline.derive and offer | EmbeddedRenderPreflight and fixed RenderWorkspace | RenderLowering / Drawing |
| Interaction candidate and publication | DynamicPresentationPipeline.derive | EmbeddedInteractionOwner / StaticPreset | Interaction / ObservableState; RuntimeCore sequences |
| Offer and routing commit | PiInitialPresentationOwner.present | StaticPreset presentation handoff and embedded interaction commit | Endpoint / Execution / Interaction; RuntimeCore sequences |
| Failure cleanup | Parallel early returns in derive, separate host policy | Local Bool/optional preparation and firmware failure codes | RuntimeCore mandatory order; focused owners retain original failures |

Both production paths implement a parallel stage runner. RuntimeCompletePipeline
and its typed owner seam are the reusable sequencing/cleanup owners. Fixtures
already exercise this seam; fixture conformance is not a production-path join.
T10.2 must reproduce the Layout/Drawing/render observable-candidate leak before
repair; semantic/binding failures already explicitly discard, and interaction
transaction failures have owner-managed cleanup that must not be duplicated.

## Embedded realization and remaining gates

Canonical modules compile separately with the pinned target compiler. T10.4 can
split value-only declarations from generic expansion helpers within the same
canonical owners when useful, retaining exact APIs. Its production realization
must preserve module imports and an isolated compilation closure for each
selected owner and consumer before final specialization/linking. Simply moving
copied definitions to an owner directory and then stripping all imports would
not satisfy ADR-008 or SPEC-002 PF-005/PF-006.

There is no compiler-level blocker in the audited four-owner declaration chain.
This does not prove the full selected host or its final link. T10.4 must replace
local identity/protocol differences, compile the actual selected embedded
consumers against these owners, add forbidden-edge cases to those actual source
configurations, compare native transcripts and inspect the rebuilt firmware.
T10.6 consumes that result. If any required owner production seam cannot satisfy
its contract on this compiler, report it to that owner's plan; do not relax
isolation, identity meaning, allocation or resource bounds.

Profile closure baseline: both macOS executables depend on PresetHarness, which
depends on SignalAnalyzerHost. SignalAnalyzerHost imports both runtime profiles.
Thus a profile executable currently reaches the opposite runtime through the
shared host helper. T10.7 needs separate profile helpers and must check the full
transitive closure; keeping only the entry-point import clean is insufficient.

Pixel-reference review and physical display/input/timing/high-water checks stay
open. This audit performs no deployment, flash or connected execution.
