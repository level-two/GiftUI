# Review Coverage

Source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
Each row distinguishes structural inspection from behavioral validation.
The [module inventory](evidence/modules.tsv) lists every target; lexical scanning
does not count as a detailed module review.

| Area / governing contracts | Configurations | Perspective / boundary | Status | Evidence / remaining work |
| --- | --- | --- | --- | --- |
| Manifest, source inventory, Spec portfolio | All four | Baseline and current authority/status inventory | Reviewed | [Step 00](00-baseline.md); no new behavioral or hardware claims |
| All 84 package targets; ADR-008/SPEC-002 | All four manifest topology | Declared dependencies and source imports | Reviewed | [Step 01](01-dependencies.md); owner responsibility reviews in Steps 05–08; [target index](evidence/09-module-review.tsv) |
| Firmware source composition; SPEC-001/013 | nRF Static | Selected owner/module boundaries | Reviewed | [Step 01](01-dependencies.md); fresh firmware/profile/negative checks in [Step 11](11-fresh-hardware-free-validation.md); connected proof remains separate |
| Portable declarations/domain/presentation; SPEC-001/002/006/010/012 | Portable meanings; actual host Data probe | Interfaces and requirements | Reviewed | [Step 05](05-portable-and-application.md); CBR-007 reproduced; target-host storage and joins covered separately |
| Semantic/layout/render/drawing; SPEC-005/006/007/008/012 | Portable/Static/Dynamic contracts and source realizations | Types, mappings, lifetime and failure flow | Reviewed | [Step 06](06-semantic-layout-render-drawing.md); representative algorithms and joins inspected, behavioral/profile gate recorded separately |
| Execution/observable/interaction/runtime; SPEC-009/010/011/013 | Static/Dynamic source and target joins | State, lifetime, failure, and publication flow | Reviewed | [Step 07](07-execution-observable-runtime.md); complete input/failure source trace; fresh profile corpus outcome recorded separately |
| Common pipeline and nRF common production owner; SPEC-001/009/013/015 | Shared source and nRF Static source | Mutation progress, derivation, preflight, publication, and cleanup joins | Reviewed | [Steps 03](03-requirements-flows-and-tooling.md), [07](07-execution-observable-runtime.md), [08](08-backend-host-platform.md); current corpus execution recorded separately; connected limits remain |
| InteractionState, storage protocols, dispatcher; SPEC-011/013 | Fresh macOS probe; standard nRF construction; current all-profile corpus | Capacity, action/target identity, candidate/commit validity | Reviewed | [Step 02](02-interfaces-and-mappings.md); CBR-001 remains reproduced despite passing current corpus in [Step 11](11-fresh-hardware-free-validation.md) |
| Packed nRF hierarchy and layout adapters; SPEC-001/007/013 | nRF source and host tests/probe consumers inspected | Representation purpose, manual model mappings, duplicate startup text rules | Reviewed | [Step 02](02-interfaces-and-mappings.md); no replacement measured or approved |
| Capabilities/failure/host/backend/display/raster/platform; SPEC-003/004/014/015 | All four source/configuration meanings | Ownership, policy, resource and transfer lifetimes | Reviewed | [Step 08](08-backend-host-platform.md); no additional confirmed boundary defect; physical behavior remains excepted |
| Selected generators/guards, runner ledger, criterion/report portfolio | Host checks; all four hardware-free profiles | Tooling and evidence traceability | Reviewed | [Steps 03](03-requirements-flows-and-tooling.md), [09](09-tests-generation-and-entrypoints.md), [11](11-fresh-hardware-free-validation.md); 240 criterion notes, current generator checks and 72-check gate; no blanket criterion pass |
| Remaining tests, generators, driver oracles and evidence freshness | All four hardware-free profiles | Corpus role, independence, source closure and source selection | Reviewed | [Step 09](09-tests-generation-and-entrypoints.md); fresh aggregate and verified report identities in [Step 11](11-fresh-hardware-free-validation.md) |
| Separate SwiftUI demo, firmware probes, toolchain probe | macOS and applicable target/probe configurations | Entry-point role and documentation | Reviewed | [Step 09](09-tests-generation-and-entrypoints.md); demo 17 XCTest passed; no physical proof inferred |
| Owner/module and criterion portfolio beyond initial seams | All four | Bounded owner interfaces/joins, requirement traceability and evidence dispositions | Reviewed at stated depth | Steps 05–09 and [240 criterion notes](evidence/11-criterion-review-notes.tsv); no every-line/all-branch manual proof or independent fresh pass for all criteria claimed |
| Connected timing/input/failure/trace coverage | Pi/nRF and physical macOS input | Connected behavior | Blocked for this audit | Existing approved exceptions and FW-027/031/032/033; no connected campaign authorized in this research |
| Candidate nRF hierarchy replacement | nRF Static | Measured comparative feasibility | Blocked pending comparison inputs | [Step 10](10-hierarchy-investigation-disposition.md), [EXP-001](../../explorations/exp-001-nrf-hierarchy-derivation.md); source assessment recorded, candidate prototype and agreed deltas/derivation budgets still needed; IT-AC-003 remains open |

Completion is bounded to these perspectives. The original "detailed module"
queue was expanded into owner reviews and a criterion/evidence disposition
index; this does not convert automated corpus results into universal conformance.
Comparative feasibility and connected proof remain visible gaps, not dropped tasks.
