# Step 08 — Capabilities, Failures, Backend, Host, and Platform

Source baseline: `6cf31f26`. Contracts: SPEC-003/004/014/015 and the source,
geometry, text, render and profile contracts they consume; ADR-007/008/014–020.

| Owner | Inspected producer/consumer boundary and result |
| --- | --- |
| GiftUICapabilities | Fixed contributor roles, candidate workspace, deterministic resolver and precedence. Describes available raster/submission/resource facts independently of execution health; native capability widths are checked at adapters rather than importing GiftUI into this leaf. |
| GiftUIFailureCore | Condition/origin/scope/containment values, operational health and residual-policy input. Does not own subsystem errors or concrete hardware policy. |
| GiftUIFailureExecution | Correlation and layered disposition, owner-adapter mappings; preserves authoritative failure fact and execution context rather than treating diagnostics as a second failure source. |
| GiftUIFailureDiagnostics | Fixed-capacity buffer and lazy projector | Optional record construction and delivery counters; selected-out records do not invoke the producer closure. Diagnostics cannot select cleanup or change returned outcomes. |
| GiftUISurfaceCore | Canonical pixel encoding and surface descriptor/surface interface | Checked zero-origin, extent/stride/region descriptor; encoding and surface state are separate from transport ownership. |
| GiftUIDisplayCore | Reservation/writer/transfer contracts and capability contribution | Explicit before/after-responsibility-acceptance results; synchronous borrow/copy lifetime and in-flight limits bound writer access. |
| GiftUIRasterCore | Fill/glyph/stroke coverage, full surfaces, RGB565 tile workspace/work tracker | Owns coverage and bounded pixel replacement; retains no semantic hierarchy or application model. Checked descriptor bounds resolve the suspected nonzero-origin tile-alignment issue. |
| GiftUIBackendIntegration | Startup validator, one-shot endpoint, full-surface and operation-major sessions/payload emitters | Owns render-to-raster/display mechanics, validates reservation before invoking body, discards pre-acceptance failures, drains accepted responsibility and reports later transport health. |
| GiftUIHostConfiguration | Ordered validation, activation/teardown, input, pacing, recovery, policy/effects and endpoint-health controllers | Composes graph/resource/profile/capability/endpoint/action/input/policy checks before activation. Mechanical effects precede residual policy; graph/config changes require fresh construction. |
| GiftUIPlatformRaspberryPi | evdev decoding, aspect-fit/calibration, framebuffer projection, console ownership and Linux devices | Hardware mapping/transport isolated from portable policy. Device lifecycle closes/restores owned handles; native rehearsal does not establish real device behavior. |
| SignalAnalyzerTargetHost | Dynamic presentation/Pi lifecycle and input owners; static nRF packed source/capture/semantic/layout/drawing/input/display joins | Concrete composition root owns specialization/adapters. Different packed/native store realizations are justified by resource constraints; CBR-002/003 remain concrete maintenance opportunities. |
| SignalAnalyzerPresetHarness and four executable roots | Configuration/oracle/rehearsal versus production entry points | Fixed host selection and deterministic corpus evidence; exact entry-point roles documented in Step 09. |

## Boundary and failure findings

The pipeline separates capability resolution, operational health, optional
diagnostics, and host residual policy. Duplicated-looking enum projections
usually preserve distinct units, owners, origins, scopes or pre/post-transfer
states. No new forbidden owner dependency was established by this responsibility
pass. FailureAdapterFixture targets implement independent contract mapping
oracles; their absence from production executable dependency closures was checked
in Step 01. Preserve these narrow adapters/negative tests when changing mappings.

Operation-major tiling consumes one borrowed operation at a time, bounded by tile
visits/regions and fixed workspace; full-surface rendering is a separate resource
realization. Both have to preserve painter order and exact pixels. Repeated tile
and glyph work is a performance question, not sufficient evidence that the
operation grammar or adapter hierarchy is wrong. Existing FW-027/FW-032 own
target performance work; no cadence requirement was waived.

Input eligibility follows a committed physical presentation. Stale/unestablished
provenance, malformed input, source/sequence exhaustion and capacity refusal have
different host dispositions. Endpoint health checks counter regression and
requires the accepted stream to drain before routing a later failure. Clear,
fresh construction and teardown invalidate different state; merging them would
weaken safe restart semantics.

## Limits

The inspected contracts and production joins show no additional confirmed defect
beyond earlier findings. This is not a proof of every callback/transport failure
or an exhaustive hardware resource bound. Host fault corpora and target/compiler
checks are consolidated in Step 11. Pi/nRF physical input, real fault recovery,
sustained cadence and complete connected traces retain their approved exceptions.
No device descriptors were opened, remote service changed, or board flashed.
