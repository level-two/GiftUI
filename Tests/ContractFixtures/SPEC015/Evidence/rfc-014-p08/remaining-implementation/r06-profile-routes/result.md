# R06 profile-route checkpoint — stopped for authority/scope review

Entry c49fc9b05e2b2bd67d6f0ca540d985dd4b2f079e. R01–R05 native accepted at0f7290ce; tiled endpoint accepted source-specific PASS atc49fc9b0. Current route WIP is preserved; no imports/dependencies/generated sources were repaired, no image work began, and no further compiler invocation is authorized before the separate review.

| Current route | Outcome | Exact build |
| --- | --- | --- |
| macos-static attempt3 | PASS1,349,555 assertions/0 failures,24/24; actual Static host, original full RGBA oracle | .build/contracts/p08-counter-ecyz4tl1 |
| macos-dynamic attempt1 | PASS1,349,501 assertions/0 failures,24/24; actual Dynamic host, original full RGBA oracle | .build/contracts/p08-counter-18g4uy1r |
| raspberry-pi-armv6 attempt1 | PASS28/28 cross-compile/negative checks; actual Pi Dynamic kind/factory, tiled text/stroke endpoint; no execution | .build/raspberry-pi/contracts/p08-counter-5snuaa2q |
| nrf52840-embedded attempt1 | FAIL at GiftUIHostConfiguration,130 direct-import diagnostics in5files; counter lowering/model not reached | .build/nrf52840/contracts/p08-counter-36l6m4yi |

All four attempts use the same route source patch SHA256 f8694d9045996b597689808e5c73554e32f1e128819c1a4d26829203895114ec. Current passing inputs192/192/219 match, no mismatch; exact result hashes/checks are in source-specific-summary.json. Every invocation preflight confirms496 pinned comparisons unchanged. All initial failures, source patches, commands, output, emitted artifact hashes and available result reports are retained per attempt. No generated binaries are copied into tracked evidence. NativeStatic attempts1/2 were distinct diagnosed source causes; exact corrections are in repair-ledger.md. nRF's new visibility failure has no repair attempt; no same-blocker exhaustion. Historical helper2/2 and B031/1 remain closed.

Registered run-spec-015.sh has an opt-in finite counter corpus preserving legacy default. Current driver freshly compiles required target modules with pinned target flags and receipts; target imports do not use native modules. Native routes execute their actual selected host, targets emit object inputs only. Static C entry accepts the existing synchronous SPI-compatible write callback and installs it in existing controls before construction; the eventual nRF image must supply the actual driver. No real transport, target execution, image/map/RAM/stack/allocator fit is credited by object success.

## Exact authority/scope handoff

Accepted ADR-008:66–76 requires acyclic compiler-enforced owner modules, permits selected components at executable composition roots, and prohibits GiftUI umbrella/reexports. It does not enumerate an exact HostConfiguration direct-dependency list. Implementing approved SPEC-015:475–491 gives GiftUIHostConfiguration pure validation/assembly/adapter ownership and permits approved contract-owner modules required for composition, while forbidding it from owning their behavior. That is the applicable permission wording; transitive visibility alone is not additional approval. SPEC-015:811–815 preserves approved package/module graph prohibitions.

Package.swift:277–293 currently directly declares GiftUI, BackendIntegration, Capabilities, DisplayCore, Execution, FailureCore, RasterCore, RuntimeCore, SurfaceCore and TextResources. Exact missing per-file imports from diagnostics:

| File | Required direct imports |
| --- | --- |
| HostApplicationStartupValidation.swift | GiftUIExecution, GiftUIRuntimeCore |
| HostEndpointStartupValidation.swift | GiftUIRasterCore, GiftUISurfaceCore |
| SignalAnalyzerDrawingStartupValidation.swift | GiftUIDrawing, GiftUIRenderCore, GiftUIRenderLowering |
| SignalAnalyzerWorkloadStartupValidation.swift | GiftUIExecution, GiftUIInteraction, GiftUILayout, GiftUIObservableState, GiftUIRenderCore, GiftUIRenderLowering, GiftUISemanticCore |
| Generated/SignalAnalyzerPresets.generated.swift | GiftUIDrawing, GiftUIExecution, GiftUIInteraction, GiftUILayout, GiftUIObservableState, GiftUIRenderCore, GiftUIRenderLowering, GiftUISemanticCore |

All files are under Sources/GiftUIHostConfiguration. Full exact source names/modules are in embedded-import-diagnosis.json. Seven modules (Drawing, RenderCore, RenderLowering, Interaction, Layout, ObservableState, SemanticCore) are currently transitive rather than explicitly listed for this target. Existing APIs are used already; this diagnosis alone does not assert those new direct declarations are approved. Existing nRF firmware CMakeLists.txt:284–291 combines fragments within each owner, so a sibling fragment's imports cover those APIs; current separate-source target compilation exposes this source visibility defect. No compiler crash, runtime contract failure or exhausted lifetime helper shape occurred.

Smallest review option: determine whether those seven approved lower-owner direct dependencies are already permitted by ADR-008/SPEC-015 and their owning module contracts. If permitted, correct the five source import headers, owning scripts/contracts/generate-spec-015-workload.rb:199–200, and matching Package.swift direct declarations; keep immutable generated scalar contents identical and verify generator freshness. Reverify changed-input recipes explicitly rather than silently relaxing frozen pins, format, then validate source-specific routes. If a direct edge is prohibited, return that precise authority conflict before any alternative recipe or workaround. No driver import injection/flattening, public API change, new owner, compiler/SDK, capacity or workload change is proposed. No authority waiver is requested.

R06 four-route completion, R07 early linked images, independent P08 exit and HC-003 final physical resource proof remain open; P09–P12 pending. No deploy/flash occurred.

Authored source/receipt/navigation diff whitespace check PASS. Whole staged diff reports only verbatim frozen compiler-log whitespace and patch context blank lines; these exact diagnostic/patch bytes are preserved. No new validation rerun at this checkpoint.
