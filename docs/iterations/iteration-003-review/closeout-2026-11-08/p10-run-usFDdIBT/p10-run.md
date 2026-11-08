# P10 all-hardware-free run — `run-usFDdIBT`

## Disposition

**P10 remains FAILED / UNMET. Iteration 3 remains active; P08 remains FROZEN / UNMET.**
The required `scripts/test.sh all-hardware-free` command completed all 83
serialized checks and exited 1: 24 passed and 59 failed. The aggregate result
does not prove any of the 189 owner-plan rows. Failure destinations remain split
by actual cause; I4 transfers do not waive the P10 gate.

## Run identity and retained receipt

- Run: `run-usFDdIBT`, recorded revision `c7c7da31c245b7a5afb68ee64d5f57bf2cab12a7`.
- Host selection: `/usr/bin/swift`, Apple Swift 6.3.3; SDK 26.5.
- Command: `scripts/test.sh all-hardware-free`.
- Detailed identity: [run-identity.txt](run-identity.txt).
- Raw report directory at execution: `.build/test-reports/all-hardware-free/run-usFDdIBT`.
- `metadata.txt` SHA-256: `a07a8906380a9555c22303deb3b38ae7342b189c808b1e119cb03d1e6b396716`.
- `results.tsv` SHA-256: `a140241b389f3cde526ee5c755659b2db12e079480c897d387e065164d4e821c`.
- `child-reports.tsv` SHA-256: `f4dd1bb71a09265b167e74f71bdd56f12ba3ace27a15245cfe65090e4c22a72b`.
- [Archived logs, metadata, results and child-report ledger](receipt.tar.gz), SHA-256 `17b8347c1ff26440fc8becfb1029e186da41fa47f9630e61c5684067b1c7292e`.

The result records a dirty worktree at the stated HEAD. The outer runner does
not capture a complete source-tree snapshot; each published child report has
its own declared input and artifact identity where supported. Do not treat this
receipt as clean-tree conformance evidence. Post-run focused checks described
below use the shared dirty working tree, not a reconstruction of the run tree.

| Check group | Passed | Failed | Total |
| --- | ---: | ---: | ---: |
| Fixed checks | 12 | 3 | 15 |
| SPEC-001–015 registered profile rows | 6 | 54 | 60 |
| RFC-014 SPEC-002 and SPEC-006 profile rows | 6 | 2 | 8 |
| **Total** | **24** | **59** | **83** |

The fixed failures are the SPEC-013 macOS Static precheck, `root-tests`, and
SPEC-003 diagnostic-buffer. All four registered SPEC-013 profile checks pass.
The passing registered rows are SPEC-002 nRF and SPEC-014 nRF; RFC-014
SPEC-006 passes on all four profiles and RFC-014 SPEC-002 passes on Pi and
nRF. The exact row ledger is in the archive.

## Failure classification

| Failed rows | Observed trigger | Disposition |
| --- | --- | --- |
| `spec-013-macos-static`, `root-tests`, `spec-003-diagnostic-buffer`, and all four SPEC-001 profiles | Compilation reaches `SignalAnalyzerView.swift` and fails generic `Schema` inference/property-wrapper conformance; some reports also show shared lifetime and `InlineArray` availability errors. | Analyzer-specific integration is transferred under the approved I4 allocation. Shared semantic-core compiler/API errors remain visible I3 failures. No tests that failed to build are reported as passing. |
| SPEC-002 macOS Dynamic/Static and RFC-014 SPEC-002 macOS Dynamic/Static | Foundation interface check reports package SPI exposed in the public interface. | Retained shared/API conformance failure. |
| SPEC-002 Pi and SPEC-014 Pi | SwiftPM cannot resolve the run destination SDK `linux`; the Pi report is blocked before the intended compile/evidence assertion. | Validation configuration failure remains open. Pi whole-composition stack/provider/fit work remains transferred under I4-AC-013; this SDK error does not prove that transfer. |
| SPEC-003 and SPEC-004, all four profiles each | `GiftUIHostConfiguration` dependency declarations differ from the expected graph. | Retained I3 dependency-boundary failures. |
| SPEC-005, all four profiles | `generated-assets.tsv` contained stale hashes for the generator and three generated files. | Post-run, `verify-reference-generation.sh --verify`, `check-spec-005-generated-assets.rb`, and `check-spec-005-reference-generation.rb` pass after refreshing the four inventory hashes. The full P10 gate was not rerun; the archived row remains failed for the state at execution. |
| SPEC-006 through SPEC-012, all four profiles each | SPEC-006 required action/view fragments are absent; SPEC-007 finds two unapproved `GiftUILayout` consumers; SPEC-008 reports incomplete root foreground initialization; SPEC-009 reports captured action storage `[]`; SPEC-010 binding decorator imports differ; SPEC-011 task evidence keys differ; SPEC-012 direct compiler/fixture validation fails. | Retained I3 criteria remain unmet. SPEC-012 probes now pass the package's `LifetimeDependence`/`Lifetimes` flags; the declaration fixture still attempts the closure-based Canvas initializer, which conflicts with the approved RFC-014 amendment, and the value probe's partial source set lacks required declarations. These are not conformance passes. |
| SPEC-014 macOS Dynamic/Static | `macos-production-corpus` is blocked by `SignalAnalyzerView` compilation and shared semantic-core availability diagnostics. | Analyzer-specific portion transfers to I4; shared compiler/API portion remains an I3 failure. |
| SPEC-015, all four profiles | macOS-15-targeted compilation uses `InlineArray` APIs available only on macOS 26; invalid lifetime/`~Escapable` declarations also appear in SemanticRecordExpansion. | Retained I3 compiler/API compatibility failure. |

The 52-leaf SPEC-001 generated-workload freshness check passes. The separate
`spec-013-macos-static` precheck failure is not the same row as registered
`SPEC-013-macos-static`, which passed. `R1` compiler allocation-effect failure
remains explicit; the reviewed Native Static no-heap conclusion applies only to
its exact image and predicates.

## Post-run focused checks

- `scripts/format-swift.sh --lint`, changed shell syntax checks, and
  `git diff --check` passed before the final P10 run.
- `scripts/governance/test.sh` passed all 28 tests and 200 assertions after the
  runner's selected Swift identity was recorded without mutating `PATH`.
- `scripts/text-resources/verify-reference-generation.sh --verify`,
  `ruby scripts/contracts/check-spec-005-generated-assets.rb`, and
  `ruby scripts/contracts/check-spec-005-reference-generation.rb` passed in the
  shared dirty working tree after refreshing the stale SPEC-005 asset inventory.
- The focused SPEC-012 declaration/value checks still fail on the current
  protocol/fixture and partial-module boundary; their post-run outputs are
  retained under `.build/check-spec-012-*`.

These focused checks do not replace the archived P10 result. The 180 P10
owner-matrix rows and nine scoped-ownership rows remain dispositioned in the
[189-row criterion index](../criterion-dispositions.csv). P08 remains frozen;
affected I4 reuse stays blocked under the approved S1–S3 restriction. P11/P12,
the independent overall freeze acceptance, final handoff, and a human
iteration-3 closure decision remain separate gates.
