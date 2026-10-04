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
| Portable declarations/domain/presentation; SPEC-001/002/006/010/012 | All four portable meanings | Interfaces and requirements | Not reviewed | Producers/consumers, portable hierarchy versus nRF projection |
| Semantic/layout/render/drawing; SPEC-005/006/007/008/012 | All four | Types, mappings, and execution flow | Not reviewed | Focused seam review followed by module behavior review |
| Execution/observable/interaction/runtime; SPEC-009/010/011/013 | Both profiles and target realizations | State, lifetime, failure, and publication flow | Not reviewed | Trace production joins and exact contract criteria |
| Capabilities/failure/host/backend/display/raster/platform; SPEC-003/004/014/015 | All four where applicable | Ownership, policy, resource behavior | Not reviewed | Validate concrete integration separation and resource hypotheses |
| Tests, generators, drivers, evidence freshness | All four hardware-free profiles | Tooling and conformance evidence | Not reviewed | Inspect guards/oracles; rerun proportionate checks |
| Separate SwiftUI demo, firmware probes, toolchain probe | macOS and applicable target/probe configurations | Entry-point role and documentation | Not reviewed | Outside root manifest; inventory discovered additional maintained paths |
| Detailed module/criterion review outside selected seams | All four | Complete behavior and lifetime coverage | Not reviewed | Remains required before claiming a complete codebase audit |
| Connected timing/input/failure/trace coverage | Pi/nRF and physical macOS input | Connected behavior | Not reviewed | Existing exceptions; separate explicit connected authorization needed |
| Candidate nRF hierarchy replacement | nRF Static | Measured feasibility | Not reviewed | Named experiment/questions and acceptable cost thresholds needed |
