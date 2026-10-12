# Independent R06 import-boundary review — 2026-10-12

Entry `2379dddb`; Strong, sequential, read-only. **The diagnosed explicit-import
correction is authorized local realization, not a new ownership decision.**
R06 remains incomplete until the corrected current nRF route passes; R07 images
and independent P08 exit remain open. No source/dependency correction, compiler,
binary, test, image, deployment or flashing was performed by this review.

## Authority and exact boundary

Accepted ADR-008:66–76 requires acyclic compiler-visible modules, narrow portable
GiftUI and composition roots. It does not prescribe the exact HostConfiguration
direct dependency list. Approved implementing SPEC-015:475–491 explicitly permits
GiftUIHostConfiguration to import approved contract owners for pure validation,
assembly reports and adapters, while forbidding ownership of semantic/layout/
render/drawing/observable/interaction/execution behavior. SPEC-015:811–815 keeps
approved module prohibitions binding; transitive visibility is not permission.

The diagnosed source accesses existing limit/configuration types and members
owned by those lower contracts; it does not expand, lay out, render, draw, bind
state, hit-test or execute application behavior. SPEC-006:457–481, SPEC-007:
336–365, SPEC-008:263–302, SPEC-010:458–471, SPEC-011:274–293 and SPEC-012:442–461
preserve their lower-owner responsibilities and prohibit their upward/concrete
imports. Host-to-contract imports for this validation do not reverse those
edges, add a runtime profile implementation, or make GiftUI an umbrella.
No lower owner gains HostConfiguration or executable visibility. Thus the
positive SPEC-015 module permission supplies authority independently of the
existing accidental/transitive source visibility.

## Smallest correction and consistency inputs

Correct only these per-file import headers under Sources/GiftUIHostConfiguration:

| File | Add explicit imports |
| --- | --- |
| HostApplicationStartupValidation.swift | GiftUIExecution, GiftUIRuntimeCore |
| HostEndpointStartupValidation.swift | GiftUIRasterCore, GiftUISurfaceCore |
| SignalAnalyzerDrawingStartupValidation.swift | GiftUIDrawing, GiftUIRenderCore, GiftUIRenderLowering |
| SignalAnalyzerWorkloadStartupValidation.swift | GiftUIExecution, GiftUIInteraction, GiftUILayout, GiftUIObservableState, GiftUIRenderCore, GiftUIRenderLowering, GiftUISemanticCore |
| Generated/SignalAnalyzerPresets.generated.swift | GiftUIDrawing, GiftUIExecution, GiftUIInteraction, GiftUILayout, GiftUIObservableState, GiftUIRenderCore, GiftUIRenderLowering, GiftUISemanticCore |

Update the corresponding generated header in
scripts/contracts/generate-spec-015-workload.rb:199–200 and use its normal output
workflow. Preserve immutable descriptor/source identity and every generated
scalar/limit/workload value; this is not new workload generation authority.
Add exactly seven existing lower owners to GiftUIHostConfiguration's direct
Package.swift dependency list: Drawing, Interaction, Layout, ObservableState,
RenderCore, RenderLowering and SemanticCore (each with GiftUI prefix).
Existing Execution/RuntimeCore/RasterCore/SurfaceCore direct declarations remain.

Two additional maintained registry inputs must be reconciled; the packet did
not list them. Tests/ContractFixtures/SPEC002/target-dependencies.yaml freezes the
old Package list. Tests/ContractFixtures/SPEC015/module-owners.tsv freezes that
list and marks Drawing/Interaction/Layout/ObservableState/RenderLowering/
SemanticCore imports forbidden. Those are stale implementation/test registries
relative to the current positive SPEC-015 contract-owner permission and actual
scalar validation duties; they do not independently amend accepted authority.
Update only the exact HostConfiguration dependency/allow/forbid entries to match
the seven reviewed edges, preserving other owners and reverse/portable boundary
checks. Do not bypass the scans or broadly whitelist arbitrary future imports.
No ADR/Spec amendment or user approval is required for this reconciliation.

Existing firmware CMakeLists.txt:284–291 concatenates fragments **within each
owner module**. Another fragment's imports can therefore cover the affected
source there. Lines299–351 retain owner modules and derive direct/transitive
visibility from their imports; this is not an undifferentiated cross-owner
module. The faithful separate-source target route exposes the missing explicit
file imports. Fix sources and declarations, rather than inject imports in the
driver, add export(interface), flatten owners or change compiler selection.

## Route provenance and finite continuation

Independently matched all current passing route input hashes against both live
files and Git `2379dddb`: Static192, Dynamic192, Pi219. Matched their frozen result
hashes, four current invocation patch hashes and frozen reports against artifact
receipts; no mismatch. Static is1,349,555/zero24/24; Dynamic1,349,501/zero24/24.
Both select their actual native hosts with arm64-apple-macosx26.0 flags and the
original full-surface oracle. Pi selects raspberryPiDynamic/tiled and
armv6-unknown-linux-gnueabihf, passes28 compile/negative checks and records no
execution or image. Native and Pi counts are source/route-specific, not a
replacement total for the prior combined native corpus.

The counter driver recompiles target runtime recipes and required lower host
modules with pinned target flags, without native host module imports. The nRF
attempt stops at fresh GiftUIHostConfiguration, before counter lowering/model.
Its log has **65 primary missing-file-import diagnostics**, printed again in
source annotations as **130 error occurrences**, across exactly five files.
All primary diagnostics name a module not imported by that file; there is no
compiler crash or newly exhausted lifetime shape. The recorded130 should be
understood as rendered occurrences, not130 independent causes. Earlier modules
compiled; no nRF counter result or linked-image pass exists.

After the bounded correction, verify generator freshness, exact dependency graph
and source-boundary registry agreement, format maintained Swift and validate the
changed current route inputs. Preserve old frozen receipts as history: explicitly
record reviewed changed-source recipe applicability before fresh compilation;
never overwrite old hashes, silently relax pins or regenerate dependencies.
The next new nRF invocation is a legitimate first correction of this visibility
blocker; later failures must be diagnosed separately against the exact guard.
Revalidate affected native/Pi source-specific routes as needed to establish the
corrected shared source, then continue the existing R07 image handoff only after
R06 completion. This review does not predict that imports resolve every possible
later Embedded diagnostic.

The fixture C entry accepts the existing synchronous pixel writer and Static
construction installs it in current controls. R07 still must supply the actual
target transport and prove linked image/resource/ABI obligations. Object success
does not establish transport, RAM/stack/allocator fit or hardware execution.
No new application/target, general API, owner, ceiling, workload or compiler/SDK
change is authorized by this correction. Such a genuinely new requirement would
need its concrete upstream decision; none is demonstrated by these import errors.
Historical helper2/2 and B031/1 stay closed. One nRF failure with no repair does
not exhaust the same-blocker rule. SPEC-015 implementing, P08/T8.1/R06/R07 open,
P09–P12 pending; no package completion or lifecycle transition.
