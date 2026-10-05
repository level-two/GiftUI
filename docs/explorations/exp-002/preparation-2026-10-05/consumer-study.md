# ITERATION-003 coordinated consumer study

Evidence plan under [EXP-002](../../exp-002-backend-and-application-integration-shapes.md)
for [approved scope revision 2](../../../iterations/iteration-003-dev-ux-improvement.md)
and [PROPOSAL-007](../../../proposals/proposal-007-external-application-integration.md).
This fixes the evaluation workload and measurement method, not external API or
package architecture. [SPIKE-014](../../../spikes/spike-014-external-consumer-access-baseline.md)
answers only the initial declaration/access questions; the full study remains.

## Application and deterministic behavior

- One root observable counter model, integer range 0–9, and one finite typed
  action domain: Increment and Reset. No acquisition service or analyzer types.
- Initial value 0, Increment enabled and Reset disabled. Increment advances by
  one until 9, where it becomes disabled. Reset restores 0 and its disabled state.
  State-dependent text uses the ten single-digit bounded strings.
- Presentation: title `Counter`, changing value text, Increment and Reset
  Buttons in a fixed hierarchy. Portable source imports `GiftUI` alone.
- Canvas variant: one straight opaque stroke for a positive value; two points
  from (4, 8) to (4 + 4 × value, 8), width 1, round cap/join. At 0, no stroke.
  No curves, gradients, unrestricted strings or new drawing capability.
- Use each supported composition's existing display extent/encoding and explicit
  application text resources. Derive semantic/layout/drawing/resource bounds from
  the complete hierarchy and all ten states; do not borrow analyzer capacities
  or infer safety from the largest observed demo frame.

The probe's simple `CounterScreen` source is disposable declaration evidence;
it has no root model binding, action execution or Canvas implementation. Do not
copy it into a production example by implication.

## Required transcripts and modes

| Scenario | Observation / oracle |
| --- | --- |
| Startup | Validate then construct/activate; visible value 0 and exact enabled states. Invalid inputs must not partially activate or output pixels. |
| Finite action sequence | Increment to 1, Reset to 0, Increment nine times to 9, attempt disabled Increment, Reset to 0. State trace: 0 → 1 → 0 → 1…9 → 9 → 0. Compare actions and Canvas stroke counts as well as pixels. |
| Observable updates | Application-owned update and root-model generation replacement produce the governing invalidation behavior; stale bindings/input cannot target a retired root. |
| Display substitution | Replace only the display during construction with the external recording adapter; retain portable presentation/model/actions, raster/resource limits and assembly path. |
| Service-loop substitution | Deterministic clock/wake fixtures expose the same serialized lifecycle; callbacks request work without reentrant runtime mutation. Record runner and application-owned loop requirements. |
| Frame/device failures | Reservation refusal before body, exactly one body after reservation, pre-acceptance abort/cleanup, accepted responsibility and later device health; no retained Core borrow. |
| Shutdown/reconstruction | Quiesce input/observation, drain/cancel as governed, release backing storage after its borrowers, and rebuild fresh immutable selection. |
| Configuration negatives | Missing/incompatible exact resources; wrong encoding/extent/stride; first-excess workspace/payload/in-flight/storage; incomplete roles/bindings. Preserve structured origin and no allocation fallback. |

Input eligibility is established by explicit eligible-presentation fixtures,
not synthetic delivery treated as physical touch. Match limits/resources/surface
facts when comparing exact pixels. Derive per-target raster expectations from
the same canonical operations; different screen extents need identified target
oracles, not unqualified byte equality.

## Configuration and evidence matrix

| Configuration | Baseline/control and final evidence | Current preparation result |
| --- | --- | --- |
| macOS Dynamic | Actual separate-package consumer build/run; supported and recording modes; setup, transcript, diagnostics and pixels | Small declaration object compiles; display/host access blocked. No runnable host control yet. |
| macOS Static | Finite Static binding build/run; same semantic workload; both display modes and allocation/storage evidence | Native declaration probe is not profile execution. Static host/model/Canvas adaptation remains open. |
| Pi ARMv6 Dynamic | Actual ARMv6 consumer compile/link using supported framebuffer/PiScreen support; recording selection; native lifecycle/trace rehearsal | No consumer Pi build attempted; current external contracts block assembly independently of toolchain readiness. |
| nRF Embedded Static | Actual Cortex-M4F hard-float consumer firmware compile/link in both modes; native finite-binding rehearsal; ABI/heap/storage/stack evidence | Actual Embedded declaration object compiles; display/host access blocked. No model/Canvas/lifecycle or linked firmware claim. |

Do not build with another ARM architecture, substitute a shared package name
for external access, or copy Signal Analyzer owners to declare consumption
successful. Hardware-free study work may use supported project-local toolchains;
connected actions require separate authorization. Failure of an environment or
toolchain check is inconclusive and must not become an architecture finding.

## Setup and resource measurement protocol

1. Pin maintained source hashes, package manifests, exact resources/workload,
   toolchains, flags and target facts. The [baseline snapshot](evidence/baseline.json)
   starts this inventory; rerun/capture when cleanup inputs change.
2. Build a reproducible equivalent control using the current owners before
   comparing improved setup. If research requires privileged existing SPI or
   handwritten bindings, record each explicitly as control-only debt. Never
   describe that workaround as successful supported external consumption.
3. Maintain a per-target ledger with step ID, command/manual edit, prerequisite,
   user-owned path, copied/generated input, required framework concept and
   outcome. Count toolchain setup separately as well as end-to-end setup; count
   work performed inside presets/generation rather than hiding it.
4. Count manual actions as documented invocations/manual configuration edits;
   count unique user-maintained infrastructure files separately from UI/model/
   action/resource content. Preserve the same step granularity in both ledgers.
   Compare clean setup and display customization independently for each target.
5. Baseline host setup is currently **blocked**, so setup/file counts and assembled
   consumer resource totals are **not yet measurable**. Do not use 0, infinity,
   analyzer setup counts or the six compile probes as improvement denominators.
   A bounded control prototype needs a new Spike with its exact candidate,
   inputs, resource ceilings and stop conditions before code.
6. Capture linked flash/RAM, distinct live backing regions, configured stack
   reservations, specialization/dependency closure, ABI and forbidden symbols.
   Distinguish linked totals, measured high-water and analytical bounds. Analyzer
   flash 274,144 / RAM 95,104 is an identified comparison image, not the counter's
   budget or a whole-program stack bound.
7. Agree numerical consumer ceilings at contract review before production code;
   retain Static zero-heap and governing analyzer/platform limits. Preserve
   expected failure outcomes when a finite bound is exceeded.

The scope requires fewer manual actions **and** infrastructure files per target,
zero copied analyzer infrastructure, framework source lists and handwritten
storage offsets. A failed or unmatched control blocks this numerical claim.
Improved syntax, skipped prerequisites or reduced workload are not valid evidence.

## Access and construction inventory to resolve

| Need | Current owner / concrete starting point | Required evaluation |
| --- | --- | --- |
| Portable UI/action declarations | `GiftUI` public View/Text/Button/BoundedText/drawing surface | Positive declaration evidence exists; root observation and Canvas invocation/lowering still need full consumer proof. |
| Display extension | `GiftUIDisplayCore`: DisplayTarget, Writer, reservation/transfer/error values | Review transitive signature types: Point, descriptor, encoding, submission lifetime/handoff and operational health. Do not expose unrelated owner internals. |
| Raster/session construction | `GiftUIBackendIntegration`: endpoint/session/startup validator; Surface/Raster/Text/Execution owners | Enumerate storage/resource/validator generic inputs and lifetimes, identify existing reuse, and keep capability resolution at the host. |
| Host assembly | `GiftUIHostConfiguration`: bootstrap, graph/limits/configuration, analyzer-specific workload/cardinality | Separate application inputs from host mechanics; preserve exact validation/startup/error sequencing and serialized service/teardown. |
| Finite Static bindings | Existing RuntimeStatic/Observable/Interaction/Drawing owners and analyzer generated projections | Prove model/action identity, finite text, Canvas callable and caller-owned backing-storage adaptation for this consumer; general lowering is excluded. |
| Supported builds | SwiftPM and nRF CMake/direct selection, Swift/C constants and project-local toolchains | Consume selected components without app-maintained framework lists; identify compiler-host macro dependencies versus target runtime dependencies. |

## Study handoff and gates

Eugene accepted [PROPOSAL-007](../../../proposals/proposal-007-external-application-integration.md)
on 2026-10-05, as recorded in the [acceptance provenance](../../../iterations/iteration-003-review/proposal-007-acceptance.md).
RFC work may proceed; solution selection and implementation remain downstream.
Continue EXP-002 evidence while preparing the smallest coherent package/access/
host/backend decision cluster. Any independent RFC split needs lifecycle
justification and explicit dependencies. Implementation plans wait for approved
Specifications.

Keep IT-AC-001/002/003 evidence separate even though the project is shared.
IT-AC-004 requires analyzer and consumer compatibility/resource results, and
IT-AC-005 requires reproducible guides/migration and complete dispositions.
If finite adaptation, compatible external access or reviewed resource bounds
cannot be demonstrated, record the affected outcome as unmet and route a scope
amendment/exception to the maintainer; do not silently drop Embedded support.
