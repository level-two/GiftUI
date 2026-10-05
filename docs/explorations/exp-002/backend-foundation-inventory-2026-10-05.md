# EXP-002 Evidence: Backend Foundation Inventory

**Current scope handoff — 2026-10-05:** [ITERATION-003 revision 2](../../iterations/iteration-003-dev-ux-improvement.md)
is now approved with a shared consumer, recording-display extension level,
four-profile matrix and setup measures. [Review and approval](../../iterations/iteration-003-review/scope-review-and-approval.md)
records the dispositions. The initial inventory below remains source evidence
from draft revision 1; its proposed matrix/next-step questions are superseded
by that scope selection. No module/API/topology is approved and no consumer
experiment is performed by this handoff. Refresh this inventory against current
Iteration 2 inputs before restructuring.

Documentation-only preparation for [ITERATION-003](../../iterations/iteration-003-dev-ux-improvement.md)
IT-AC-002, coordinated with its IT-AC-003 integration rework and owned by
[EXP-002](../exp-002-backend-and-application-integration-shapes.md).
The maintainer requested the information needed to proceed toward a reusable
backend module or set of modules on 2026-10-05. Inspection began at clean revision
`7e11f066ce2cfa29719dff1a6c8f07a3b2f4edba`; concurrent capture-retention edits
appeared in the working tree during this documentation pass. They were not
modified or treated as completed implementation by this study. No production
code, consumer, cross-build or connected-target experiment was changed or run
for this study.
Statements about behavior are source observations or existing contract evidence,
not fresh execution results. Candidate directions below are not decisions.

## Lifecycle and Authority

`giftui-mvp-architecture` is `implemented`; SPEC-013/014/015 are implemented
contracts. ITERATION-003 is draft revision 1 and EXP-002 is active. This is
post-MVP developer-experience preparation, rather than a missing ITERATION-001
backend requirement. The original requirement was to execute the Signal
Analyzer on macOS Dynamic/Static, Pi/Linux Dynamic and nRF Static while keeping
hardware mechanisms below portable presentation.

The current owners are governed by accepted ADR-006/007/008, ADR-010 and
SPEC-009/014/015. SPEC-003/004 govern failures and capabilities; SPEC-005/012/013
govern exact resources, drawing and profile bounds. Existing conformance and
MVP exceptions remain scoped to their recorded configurations and evidence.
The October 2 discussion's `implementing` description is historical.

No approved external backend-development contract, new module ownership or
package topology is established by this inventory. Draft iteration membership
does not supply those approvals.

## Existing Reuse

| Owner / source | Already shared responsibility | Extraction implication |
| --- | --- | --- |
| [GiftUIExecution](../../../Sources/GiftUIExecution/FrameHandoffValues.swift) / SPEC-009 | Frame provenance, synchronous one-shot endpoint and offer outcomes | This is the existing frame-facing contract. Assess the actual external type closure before creating a parallel backend protocol. |
| [GiftUISurfaceCore](../../../Sources/GiftUISurfaceCore) | Checked surface geometry/stride/regions, canonical pixels, writable surface contract | Preserve its independence from raster, display, runtime and hardware owners. |
| [GiftUIRasterCore](../../../Sources/GiftUIRasterCore) | Fill/glyph/stroke coverage, full-surface buffers, RGB565 tile workspace, payload/work limits and raster contribution adapter | Substantial reusable software-raster implementation already exists. It need not become mandatory for other rendering families. |
| [GiftUIDisplayCore](../../../Sources/GiftUIDisplayCore/DisplayContracts.swift) | Reservation identity, payload writer, transfer outcomes, target health and lifetime contracts | Existing pixel/display extension seam; it is not automatically a universal GPU or remote-rendering API. |
| [OneShotRasterBackendEndpoint](../../../Sources/GiftUIBackendIntegration/OneShotRasterBackendEndpoint.swift) | Envelope/configuration checks, reservation before body, one body call, outcome resolution and cleanup/drain coordination | Reuse the existing mechanism; a convenience wrapper should not reproduce its state machine. |
| [OperationMajorRGB565RasterSession](../../../Sources/GiftUIBackendIntegration/OperationMajorRGB565RasterSession.swift) | Borrowed operation grammar, ordered rasterization, tiled submission and bounded work tracking | Generic parameters already separate storage, display target and exact metrics/raster views. |
| [OperationMajorTileTraversal](../../../Sources/GiftUIBackendIntegration/OperationMajorTileTraversal.swift) and payload emitters | Tile traversal and full-surface/RGB565 payload delivery | Rendering-family helpers, with resource/lifetime constraints; not platform semantics. |
| [RasterBackendStartupValidator](../../../Sources/GiftUIBackendIntegration/RasterBackendStartupValidator.swift) and text/work admission | Reconciliation of effective capabilities, descriptor, resource identity and supplied capacities | Prefer one existing validation path over another competing configuration model. |
| [GiftUIHostConfiguration](../../../Sources/GiftUIHostConfiguration) / SPEC-015 | Graph validation, activation, teardown, pacing, input/presentation gating and policy integration | This is an upper host owner. Its responsibilities should not migrate into a lower backend base merely to shorten application setup. |

SPEC-014's Module Contract fixes ownership and forbidden imports. A combined
distribution product could expose several owners without merging them. Its
name, package location and access policy remain open.

### Concrete Pi/Static Reuse

[DynamicSignalAnalyzerPiEndpoint.swift](../../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiEndpoint.swift)
and [StaticSignalAnalyzerNRFEndpoint.swift](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEndpoint.swift)
alias the same `OperationMajorRGB565RasterSession` and
`OneShotRasterBackendEndpoint` with different storage/validator types. The
[actual firmware preset](../../../firmware/nrf52840/applications/signal-analyzer-static/src/StaticPreset.swift)
also defines `StaticSignalAnalyzerNRFEmbeddedSession` and
`StaticSignalAnalyzerNRFEmbeddedEndpoint` using those shared implementations.
The firmware path is important evidence: a native Static host alone would not
establish Embedded Swift consumption.

| Detail | Pi Dynamic source selection | nRF Static firmware selection |
| --- | --- | --- |
| Logical surface / tile | 240 x 240 / 240 x 16 | 320 x 240 / 320 x 4 |
| Row / tile bytes | 480 / 7,680 | 640 / 2,560 |
| Raster storage | Array-backed bytes and affected-pixel flags | Caller-owned 2,560-byte raster region plus separate 160-byte coverage bitset |
| Display path | Pi framebuffer adapter, including logical-to-physical projection | Synchronous RGB565 row-run SPI transport |
| Raster/payload relationship | Separate target writer storage | Writer compacts touched pixels into the same raster region |
| Frame envelope | Reference validator with replaceable expected provenance | Value validator; endpoint supports rebinding while idle |
| Resources and bounds | Analyzer assembly/resources and generated Pi limits | Embedded metrics, exact raster view and analyzer-specific limits |

These are selected fixture values, not universal framework defaults or complete
RAM totals. For example, coverage maps, target metadata, text/drawing workspace,
stack and runtime storage are additional resource domains.

## Friction and Consolidation Candidates

| Observation and source | Candidate to evaluate | Difference that must survive |
| --- | --- | --- |
| Endpoint factories repeat descriptor/limits/resource/session/endpoint construction; both select analyzer inputs | An application-neutral raster construction path accepting validated selection, exact resources, storage, target and provenance binding | Host capability resolution and application workload derivation remain separate. The factory cannot infer arbitrary application bounds from a board name. |
| `DynamicSignalAnalyzerPiTileStorage` and `StaticSignalAnalyzerNRFTileStorage` implement one `RGB565TileStorage` contract inside the reference host | Reusable storage implementations with explicit finite capacities | Arrays versus borrowed raw regions/coverage bitsets are legitimate profile/resource strategies. Preserve alias checks and backing-storage lifetime. |
| Pi, native nRF and embedded firmware validators all compare expected frame provenance | A shared value helper or documented narrow customization seam | Dynamic reference mutation and idle-only value rebinding have different ownership/cost. Compare behavior before merging them. |
| nRF display writer/target/transport hardcode 320 x 240 and 2,560-byte capacity | Separate reusable synchronous RGB565 delivery support from selected geometry and board transport | The writer and tile intentionally alias one buffer. Its ascending compaction must not overwrite unread pixels or introduce a hidden second buffer. |
| Pi/nRF targets each maintain reservation identity, writer state and operational health | Shared transaction fixtures first; extract implementation only if equivalence is demonstrated | Partial SPI transmission can already be an irreversible effect. Pi projection, submission and acceptance state are not interchangeable solely because method names match. |
| Firmware source selection and endpoint construction live in analyzer CMake/preset code | Reusable supported build/assembly entry points, coordinated with IT-AC-001/003 | Shared Swift/C constants, target flags, resource placement and ABI checks remain required. A shorter initializer cannot solve source selection by itself. |
| `Package.swift` has no surface/raster/display/backend-integration library products; extension declarations are `package` | Narrow externally consumable products and reviewed extension access | Adding a library product does not make package-scoped declarations available to a different package. Do not expose all owner internals. |

There is no finding that each target duplicates a complete rasterizer. The
2026-10-05 inventory supports construction/access improvements and selected
adapter extraction, not a rewrite of shared raster algorithms. Existing
`StaticSignalAnalyzerNRFEmbeddedRasterSink` and recording/probe paths must be
classified by caller role before calling them duplicate production backends;
the preset contains both validation exercises and production composition.

## Boundaries to Compare

The following are candidate consumption levels, not chosen module names:

| Consumer | Minimum useful extension boundary | Reuse expected |
| --- | --- | --- |
| New display/transport adapter author | `DisplayTarget`, its writer/lifetime/health contracts and narrowly required values | Existing software raster session, endpoint, validation and test vocabulary |
| New software-raster realization author | Normalized operations, raster sink/surface/storage contracts and exact text resources | Shared coverage where appropriate, endpoint/disposition support and pixel corpus |
| Different rendering-family author | Existing frame contract, normalized operation/resource requirements and contribution/failure obligations | Appropriate common validation/conformance support; no required RGB565 implementation |
| Application author | Supported host assembly and selected component inputs | Backend implementation and lifecycle wiring without copying analyzer factories |

A non-raster backend remains a future scenario for boundary review; this study
does not approve one or claim that current raster capability/pixel contracts
cover every graphics engine. Layout, semantic expansion, model/action dispatch,
input drivers, global services and platform discovery remain outside a common
backend implementation. Scheduling/input are sibling host seams.

Compare three modest alternatives in EXP-002's later decision work: document
and expose current owners; add a narrow raster convenience layer over those
owners; extract demonstrated common implementation into lower existing or new
owners. A new module is warranted by independent consumption, reduced repeated
mechanics or a resolved dependency problem, rather than its name alone.

## Decisions Needed Before Implementation

Resolve these against the same consumer as the integration rework. The
[coordinated study in EXP-002](../exp-002-backend-and-application-integration-shapes.md#coordinated-backend-foundation-and-integration-rework--2026-10-05)
owns the shared evaluation sequence and responsibility mapping. Foundation
inputs should be usable by the proposed host assembly; application onboarding
should not require a second raster factory or expose backend owner internals.
The package-consumption item supplies the access/build context for both.

| Question | Evidence / decision required |
| --- | --- |
| Who is the first external consumer? | Select display-adapter authors versus complete-renderer authors versus application authors. IT-AC-002's minimal example should exercise the selected extension level. |
| What is the extension API and compatibility policy? | Enumerate the transitive types required to conform/construct; classify each as public extension contract, supported factory input or internal owner detail. Include associated types, failures, resource views and capability values. |
| What does an additional module own? | Compare concrete import graphs, repeated construction and independent consumption. Preserve ADR-007 boundaries; avoid duplicating SPEC-009/014 contracts. |
| Which package/products carry those contracts? | Coordinate with FW-016/IT-AC-001 and review ADR-008 if departing from the one-package MVP topology. Do not make backend extraction depend on speculative independent releases. |
| Where do geometry, workload and storage facts come from? | Distinguish display facts, application resources/workload, profile storage and host policy. Require reconciliation with one immutable effective capability selection. |
| How are errors surfaced at construction and activation? | Existing optional factories are not a sufficient diagnostic design. Specify structured errors and responsible owners without discarding pre/post-acceptance distinctions or consulting diagnostics for correctness. |
| What budgets and build configurations define success? | Record setup steps/files/concepts and linked flash/RAM/stack baselines before selecting thresholds. Prove external access and Static specialization under actual toolchains. |

## Proposed Evidence for IT-AC-002 and Integration Rework

Use a small external recording display adapter over the existing software
raster family, with no import of `SignalAnalyzerTargetHost` and no copied
endpoint/session/coverage algorithms. This is an evaluation candidate, not a
new hardware backend commitment. Use the same small consumer proposed in
EXP-002 first with an existing supported composition and then with this
adapter substituted through the same host assembly path. A custom recording
target proves extension access; application setup and host lifecycle prove
IT-AC-003. These are distinct results from one coordinated study, not separate
applications or independently implemented bootstrap paths. Configuration,
resources, budgets and the selected toolchain matrix supply a shared baseline.

| Evidence | Expected comparison / failure cases | Existing starting point |
| --- | --- | --- |
| Extension and dependency closure | Separate-package conformance/assembly builds; selected closure excludes reference host/domain and unnecessary concrete platforms | Package manifest, SPEC-014 module/dependency fixtures; FW-016 |
| Pixel and operation behavior | Exact fill/glyph/stroke bytes, painter order, clipping/damage and full-surface/tiled parity for identical inputs | SPEC-014 `raster.yaml`, SPEC-012 stroke vectors, raster tests |
| Offer/transfer lifecycle | Refusal before body, one body call after reservation, grammar/capacity failures, cancellation, first accepted effect, drain and post-acceptance health | One-shot/session tests; `transactions.yaml` and `failures.yaml` |
| Configuration validation | Missing/incompatible exact resources, encoding/extent/stride mismatch and first-excess workspace/payload/in-flight limits fail before output | Startup/text/work admission tests; `capabilities.yaml` |
| Profile/resource preservation | macOS Dynamic/Static paired results; Pi ARMv6 build and actual nRF Embedded build, symbol/ABI/section/stack analysis, zero-heap Static path and backing-storage lifetime | SPEC-013/014 resources/evidence plus SPEC-001 production joins |
| Developer effort and host integration | Before/after setup steps, user-maintained files and framework concepts; replacing only the display through the same assembly path without copied pipeline owners; preserved startup/service/input/teardown behavior | EXP-002 joint consumer study, SPEC-015 and IT-AC-003 |

Existing entry points, to rerun when implementation changes justify them:

```sh
scripts/contracts/run-spec-014.sh --profile macos-dynamic
scripts/contracts/run-spec-014.sh --profile macos-static
scripts/contracts/run-spec-014.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-014.sh --profile nrf52840-embedded
```

Preserve the canonical fixture IDs and evidence schema. A reusable external
test harness needs an intentional contract rather than copying test-only
recording types as production support. Owner checks alone do not validate a
new package consumption path or the complete host; add those integration
results and use SPEC-013/015 plus the repository gate as appropriate. Run
the maintained Swift formatter before the repository gate for Swift changes.
Cross-builds do not prove connected timing, input, high-water or real transport
faults; carry existing exceptions forward accurately, and request hardware
actions only in a separately authorized campaign.

## Routing and Handoff

This inventory is evidence within EXP-002, not a new feature registration or
implementation plan. The smallest next step is to select the shared consumer,
extension level, application assembly needs and evidence/budget matrix in the
Iteration 3 scope review. Then draft a post-MVP integration Proposal covering
both the reusable backend foundation and application integration outcome, using
the existing accepted architecture as constraints. The MVP Proposal does not
automatically approve a new external extension/compatibility contract.

An independently reviewable backend extension/access decision cluster may
need a focused RFC; keep it in an integrating RFC when its package/host choices
cannot be evaluated independently. Public access, ownership, topology or
resource-semantic changes need reviewed RFC decisions, accepted ADRs and an
approved Specification before a ready implementation plan. Pure extraction
under unchanged contracts can use the lightweight path after its scope is
shown to be mechanical. Iteration approval and architecture/Spec approval are
separate gates; neither is requested or inferred by this evidence update.

Generation (FW-006), shared services (FW-009), replay (FW-014), live
reconfiguration (FW-018), simulation (FW-022), and performance investigations
(FW-027/FW-032) retain their existing scope and triggers. This work supplies no
new MVP requirement, package name, universal backend or generator commitment.
Refresh the inventory after Iteration 2 changes source/access/build selection,
or when a real separate consumer exposes a missing seam. Promotion and any
experiment should remain recorded through EXP-002 and its existing sources.

## Initial Inventory Documentation Validation — 2026-10-05

`scripts/validate-governance.rb` passed with 173 authority nodes, 1,731 edges
and all reported task-evidence checks. The inventory, parent Exploration and
iteration scope had 80 local Markdown targets checked with none missing.
`git diff --check` passed. These validate this documentation update; no Swift
test gate or hardware-free profile build was rerun for this study.

## References

- [ADR-006](../../adrs/adr-006-shared-semantics-runtime-profiles.md), [ADR-007](../../adrs/adr-007-integration-ownership-and-host-composition.md), [ADR-008](../../adrs/adr-008-module-dependency-graph-and-package-topology.md), [ADR-010](../../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [SPEC-009](../../specs/spec-009-execution-cycle-and-frame-handoff.md), [SPEC-013](../../specs/spec-013-runtime-profiles.md), [SPEC-014](../../specs/spec-014-backend-integration.md), [SPEC-015](../../specs/spec-015-host-configuration.md)
- [SPEC-014 conformance](../../conformance/spec-014-conformance.md) and [fixture guide](../../../Tests/ContractFixtures/SPEC014/README.md) — prior evidence, not rerun here
- [Iteration 2 backend/host review](../../iterations/iteration-002-review/08-backend-host-platform.md)
- [Package manifest](../../../Package.swift), [firmware composition](../../../firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt)
- [Static tile storage](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFTileStorage.swift), [nRF display target/writer](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDisplayTarget.swift), [SPI transport](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFSPITFTTransport.swift), [Pi display target](../../../Sources/GiftUIPlatformRaspberryPi/PiScreenDisplayTarget.swift)
