# R06 route inventory and first endpoint step

Entry: `0f7290ce`; R01–R05 accepted. P08 remains open.

Read the four Pi/nRF toolchain/build skills and R05 independent review.
` scripts/raspberry-pi/doctor.sh ` and ` scripts/nrf52840/doctor.sh ` both exit0; exact output adjacent. Swift6.4 approved, no setup/probe/compiler invocation.

Existing registered boundaries: run-spec-015.sh profiles macos-dynamic/macOS Static, raspberry-pi-armv6 product SignalAnalyzerRaspberryPiARMv6 via raspberry-pi/build.sh, nrf52840-embedded application signal-analyzer-static via nrf52840/build.sh. Default analyzer consumers remain P10; no analyzer migration.

Reusable recipe receipts: native Static tmp0q82npqp, native Dynamic tmp_63jv4xj; Pi `.build/raspberry-pi/contracts/spec-013-runtime-cycle/tmpvq70p7a0/raspberry-pi-armv6/result.json`; nRF `.build/nrf52840/contracts/spec-013-runtime-cycle/tmp9d1k2h7s/nrf52840-embedded/result.json`. Both target recipes pin compiler79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69 and contain target core receipt/flags. Target runtime modules require fresh compilation from these current source recipes, not old-study regeneration or module substitution.

SPEC-015 lines280–284 gives counter its own scalar workload/ledger. CounterHostAssembly lines186–198 selects100x120 RGBA/fullsurface locally; CounterNativeRaster stores2x48000bytes. Existing OperationMajorRGB565RasterSession accepts validated arbitrary tiled descriptor and actual fill/text/stroke. Existing analyzer DisplayTarget reserveFrame concretely requires320x240; reuse unchanged is incorrect. A local100x120 counter adapter preserves source extent/action/text/stroke/oracle, changes only profile realization to100x4 RGB565 tile within2560 raster/payload and160coverage ceilings. It cannot claim analyzer storage or physical timing.

## Exact pre-edit first coherent endpoint slice

Files: RuntimeDerived/CounterTiledRaster.swift (local actual tile storage/display writer/session adapter, selected concrete reference text); CounterNativeRaster.swift (exclude fullsurface only for Embedded/explicit tiled validation); CounterPipelineOwner.swift (backend selection and remove discard-only Embedded placeholder); CounterHostAssembly.swift (finite compile-selected tiled configuration); CounterPixelOracle.swift (same independent font/layout/optional-stroke oracle checks submitted RGB565 bytes on native tiled validation); check-spec-015-counter.py (explicit `--raster-realization tiled` selects those same sources with define). No descriptor retained in owners, no public API/lifetime/owner/limits changes.

Exact validation after format: `scripts/format-swift.sh`; `python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static --raster-realization tiled`. Existing aggregate exercises actual Static/Dynamic action/changing-text/disabled Button/optional stroke, rejection/backpressure/refusal/retry/supersession, activation failures and construction origins. Independent pixel expectation remains authored font bits/source layout, quantized to RGB565; target actual output is never expected input. Native observation buffer excluded Embedded. Reject malformed envelope before reservation/body; endpoint projection exact and below/equal/above capacities; shared health preserved. Preserve every failure and exact same-blocker narrowing; old helper2/2+B031/1 closed.

Subsequent route selector/image integration is not yet edited or credited. No target execution/deploy/flash.
