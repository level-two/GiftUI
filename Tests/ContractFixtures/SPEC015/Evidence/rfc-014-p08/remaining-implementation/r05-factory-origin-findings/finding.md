# R05 factory-origin realization finding — 2026-10-12

Read-only checkpoint at1f3a7ea0. Parent directs freeze/commit for sequential
Strong review before implementing. No R05 source edit, compiler invocation,
new ownership choice or new approval gate. This is an implementation-evidence
gap under accepted ADR038/SPEC015, not a demonstrated contract defect.

## Exact missing control

CounterHostAssembly.swift:13–36 declares reviewed actual masks, and its validate
function passes CounterHostGraph to CheckedMVPHostConfigurationValidator.
HostComponentGraphValidation.swift:13–39 checks roles/count/order and unknown,
self/upward edges; it does not require any lower input edge. Deleting any of
13 mandatory bits (endpoint6:0–5; admission11:0; root14:0; wake16:0,2–5)
therefore remains structurally valid. CounterGraphProbe.swift:35–36 explicitly
leaves hidden-origin rejection open. CheckedMVPHostConfigurationValidator.swift:
59–64 correctly rejects structural graph failures before runtimeProfile, but
has no independent actual factory-input origin against which to reject a
structurally valid omission. This is a source deduction, not a new native pass.

Actual source anchors remain B01 inventory, not a changed mask inference:
CounterNativeRaster.swift:211–232 consumes exact endpoint configuration,
profile control/surface/payload backing, and concrete reference text metric/raster
views. CounterHostOwner.swift:149–166 and Dynamic equivalent consume exact
profile scopes/audit/control for admission and root association. WakeIntegration:
49–51 passes full report to HostScheduledOpportunityController; that initializer
retains it (controller:28–38). HostAssemblyReport:40–54 retains storageAudit0 and
capabilitySnapshot/effectivePresentation2–5. Callback indirection cannot erase
those origins; actual application start/normalized submit remain operation-only.

## Smallest proposed ordinary realization (unimplemented)

A private finite inert construction descriptor can be ordinary implementation
of existing approved requirements; its absence does not imply a new contract.
Exact candidate fields/consumers to review:

| Finite field | Required origin | Actual consumer that must use same descriptor |
| --- | --- | --- |
| endpoint profile-backing input | profile0 | CounterEndpoint/CounterNativeRasterAdapter control, surface, payload |
| endpoint selected text input | text1 | CounterNativeEndpoint textMetrics/textRaster/realization |
| endpoint resolved configuration input | contributors2,3,4,5 | CounterHostAssembly.endpoint then CounterEndpoint.configuration |
| admission profile input | profile0 | CounterHostState.activate → CounterAdmission(control, execution limits) |
| root/model profile input | profile0 | CounterHostSupplied scopes → binding/pipeline association |
| wake full-report input | audit0, capability/effective2,3,4,5 | establishCounterScheduler → actual scheduled-controller report |
| bound construction-callback inputs, if any | explicit union of above source inputs | concrete factory callback binding; no opaque callback origin |

The descriptor must be generated or compiler-visible from these actual inert
factory inputs, derive direct graph edges, and be consumed by the same actual
construction paths. It must not introduce owners, roles, ambient lookup,
retained callback behavior or a generic service API. The existing fixed scalar
configuration values and approved report propagation suffice; no new runtime
owner is proposed. Endpoint/report values become available at their existing
validation stages; the earlier inert descriptor records required input origins
without reading later projections or constructing live owners. Review should
settle the exact private finite representation before coding, keeping lifetime
and value equality checks separate.

Required negative cases/oracles: independently omit each13 origin bits; hide
endpoint selected-text or wake retained report origins behind a bound callback;
supply undeclared callback origin; preserve all18 roles and structural validity.
Each must return graph-stage invalidGraph, later runtime/text/workload/capability/
endpoint/application/input/policy access counters0, no live construction, while
unaltered descriptor executes existing actual native hosts. Existing structural
self/unknown/upward/cycle cases stay. Changed coherent source would then justify
one formatted pinned counter invocation; none has been spent for R05.

B01 source trace proves which actual edges are required. An exact-mask comparison
can reject omissions but, alone, another hand-written vector does not tie a
bound callback or derived value to its actual input. The proposed descriptor is
the smallest candidate to make that tie explicit; Strong review may identify an
already sufficient finite local representation. No option relaxes the approved
before-later-projection requirement and no authority waiver is proposed.

## Current native handoff

R02 continuation1d3e9f77:1,349,199/zero failures23/23; R03 7c9a43d1:
2,696,981/zero failures23/23; R04 1f3a7ea0:2,697,541/zero failures24/24.
R04 exact raw-geometry evidence limitation remains in its result: actual factory
lexical containment is traced, independent stale-geometry rejection unproved.
No pointer after expiry is executed. Independent native review of R01–R04 and
this R05 realization is next; no target builds. Historical helper2/2/B031/1 stay
closed; SPEC015 implementing/plan active/P08/T8.1 open; P09–P12 pending.
