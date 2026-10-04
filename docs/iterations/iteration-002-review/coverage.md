# Review Coverage

Source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
Each row distinguishes structural inspection from behavioral validation.
The [module inventory](evidence/modules.tsv) lists every target; lexical scanning
does not count as a detailed module review.

| Area / governing contracts | Configurations | Perspective / boundary | Status | Evidence / remaining work |
| --- | --- | --- | --- | --- |
| Manifest, source inventory, Spec portfolio | All four | Baseline and current authority/status inventory | Reviewed | [Step 00](00-baseline.md); no new behavioral or hardware claims |
| All 84 package targets; ADR-008/SPEC-002 | All four manifest topology; fresh macOS Dynamic driver | Declared dependencies and source imports | Reviewed | [Step 01](01-dependencies.md); legal responsibility placement still needs interface review |
| Firmware source composition; SPEC-001/013 | nRF Static | Selected owner/module boundaries | Reviewed | [Step 01](01-dependencies.md); CMake and guard inspection only, actual firmware negatives not rerun |
| Portable declarations/domain/presentation; SPEC-001/002/006/010/012 | Portable meanings; actual host Data probe | Interfaces and requirements | Reviewed | [Step 05](05-portable-and-application.md); CBR-007 reproduced; target-host storage and joins covered separately |
| Semantic/layout/render/drawing; SPEC-005/006/007/008/012 | Portable/Static/Dynamic contracts and source realizations | Types, mappings, lifetime and failure flow | Reviewed | [Step 06](06-semantic-layout-render-drawing.md); representative algorithms and joins inspected, behavioral/profile gate recorded separately |
| Execution/observable/interaction/runtime; SPEC-009/010/011/013 | Static/Dynamic source and target joins | State, lifetime, failure, and publication flow | Reviewed | [Step 07](07-execution-observable-runtime.md); complete input/failure source trace; fresh profile corpus outcome recorded separately |
| Common pipeline and nRF common production owner; SPEC-001/009/013/015 | Shared source and nRF Static source | Mutation progress, derivation, preflight, publication, and cleanup joins | Reviewed | [Step 03](03-requirements-flows-and-tooling.md); source inspection only, full input/failure/profile behavior remains open |
| InteractionState, storage protocols, dispatcher; SPEC-011/013 | Fresh macOS host tests/probe; standard nRF construction inspected | Capacity, action/target identity, candidate/commit validity | Reviewed | [Step 02](02-interfaces-and-mappings.md); asymmetric capacity defect reproduced, full profile behavior remains open |
| Packed nRF hierarchy and layout adapters; SPEC-001/007/013 | nRF source and host tests/probe consumers inspected | Representation purpose, manual model mappings, duplicate startup text rules | Reviewed | [Step 02](02-interfaces-and-mappings.md); no replacement measured or approved |
| Capabilities/failure/host/backend/display/raster/platform; SPEC-003/004/014/015 | All four source/configuration meanings | Ownership, policy, resource and transfer lifetimes | Reviewed | [Step 08](08-backend-host-platform.md); no additional confirmed boundary defect; physical behavior remains excepted |
| Selected generators/guards, runner ledger, criterion/report portfolio | Host structural checks; all four profile documentation | Tooling and evidence traceability | Reviewed | [Step 03](03-requirements-flows-and-tooling.md); 240 recorded table entries, selected freshness/structural checks, no fresh all-profile gate |
| Remaining tests, generators, driver oracles and evidence freshness | All four hardware-free profiles | Detailed tooling and conformance behavior | Not reviewed | Production versus reference independence, exact input closure and failure evidence outside selected checks |
| Separate SwiftUI demo, firmware probes, toolchain probe | macOS and applicable target/probe configurations | Entry-point role and documentation | Not reviewed | Outside root manifest; inventory discovered additional maintained paths |
| Detailed module/criterion review outside selected seams | All four | Complete behavior and lifetime coverage | Not reviewed | Remains required before claiming a complete codebase audit |
| Connected timing/input/failure/trace coverage | Pi/nRF and physical macOS input | Connected behavior | Not reviewed | Existing exceptions; separate explicit connected authorization needed |
| Candidate nRF hierarchy replacement | nRF Static | Measured feasibility | Not reviewed | Named experiment/questions and acceptable cost thresholds needed |
