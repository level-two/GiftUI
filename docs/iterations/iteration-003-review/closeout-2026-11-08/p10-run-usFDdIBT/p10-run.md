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
| SPEC-002 Pi and SPEC-014 Pi | The archived integrated run could not resolve the run destination SDK `linux`; those checks stopped before the intended compile/evidence assertions. | The runner configuration was corrected after this run. Focused post-run SPEC-002 and SPEC-014 ARMv6 profile drivers now pass with the project-local Swift 6.4 SDK. These results do not change the historical integrated P10 outcome, prove connected hardware behavior, or close transferred whole-composition stack/provider/fit work under I4-AC-013. |
| SPEC-003 and SPEC-004, all four profiles each | `GiftUIHostConfiguration` dependency declarations differ from the expected graph. | Retained I3 dependency-boundary failures. |
| SPEC-005, all four profiles | `generated-assets.tsv` contained stale hashes for the generator and three generated files. | The inventory was refreshed and its generation/provenance checkers pass. A focused macOS Dynamic run then advanced through compilation and all prior contract checks but failed the exact package surface check: 22 package declarations are emitted where the approved SPEC lists 20. The two additional declarations are `TextResourceValidationEngine` and `TextResourceManifestEngine`. They are consumed across package targets; removing them safely requires a bounded implementation restructuring or a contract decision, and no Specification was changed. The full P10 gate was not rerun; all four archived rows remain failed. |
| SPEC-006 through SPEC-012, all four profiles each | SPEC-006 required action/view fragments are absent; SPEC-007 finds two unapproved `GiftUILayout` consumers; SPEC-008 reports incomplete root foreground initialization; SPEC-009 reports captured action storage `[]`; SPEC-010 binding decorator imports differ; SPEC-011 task evidence keys differ; SPEC-012 direct compiler/fixture validation fails. | Retained I3 criteria remain unmet. SPEC-012 probes now pass the package's `LifetimeDependence`/`Lifetimes` flags; the declaration fixture still attempts the closure-based Canvas initializer, which conflicts with the approved RFC-014 amendment, and the value probe's partial source set lacks required declarations. These are not conformance passes. |
| SPEC-014 macOS Dynamic/Static | `macos-production-corpus` is blocked by `SignalAnalyzerView` compilation and shared semantic-core availability diagnostics. | Analyzer-specific portion transfers to I4; shared compiler/API portion remains an I3 failure. |
| SPEC-015, all four profiles | macOS-15-targeted compilation uses `InlineArray` APIs available only on macOS 26; invalid lifetime/`~Escapable` declarations also appear in SemanticRecordExpansion. | Retained I3 compiler/API compatibility failure. |

The 52-leaf SPEC-001 generated-workload freshness check passes. The separate
`spec-013-macos-static` precheck failure is not the same row as registered
`SPEC-013-macos-static`, which passed. `R1` compiler allocation-effect failure
remains explicit; the reviewed Native Static no-heap conclusion applies only to
its exact image and predicates.

The later targeted Pi profile runs diagnose two of the 59 archived failure
records and both now pass. The remaining 57 archived failures have not been
converted into post-run passes; their original results and per-owner dispositions
remain controlling for this P10 receipt.

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

## Post-run targeted profile checks

The following focused drivers were run after `run-usFDdIBT` to diagnose and
repair its Pi SDK-selection failures. Both are cross-compilation/evidence
checks; neither executes on hardware.

| Check | Result and identity |
| --- | --- |
| `scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6` | Passed, exit 0. Report: `.build/contract-reports/spec-002/434f163b44f10835acb1c27fc78c1536c301c73a-be71904ba3a2b547/raspberry-pi-armv6`; input-set SHA-256 `be71904ba3a2b5472afb3dbbf87f936da81b149c967dec804f0cb7cce5fcc089`; `metadata.txt` SHA-256 `17d63743f7d4684d7f3a907349c528e507966ef8a5895f691604a9f6b520c721`. The corrected command uses `--build-system native`, explicit `--target GiftUI`, the project `.build` cache, and `--skip-update`. |
| `scripts/contracts/run-spec-014.sh --profile raspberry-pi-armv6` | Passed, exit 0, `blocking_count=0`. Report: `.build/spec-014/reports/434f163b44f10835acb1c27fc78c1536c301c73a-d68a9b94db670db3-20261108T201245Z-24504/raspberry-pi-armv6`; input-set SHA-256 `d68a9b94db670db3e6374fdc5117862bc017fab7f93c89fdacefd2873d4869f5`; `metadata.txt` SHA-256 `6cfb1601062553370fce4754d34219b9d4c77bada0a18c4e27c1af7943fd9ceb`. |

The compact committed report receipts (metadata, command list, input-hash
manifest, report-hash manifest, and driver log) are retained in
[`post-run-targeted-receipts.tar.gz`](../post-run-targeted-receipts.tar.gz),
SHA-256 `36d58dc61057dd2d2e70d05e2faa8f33483af927528f398ac07c8ff729f8bd0b`.
The Pi runner source hashes used
by these post-run executions are `15adf2102a810abf3b2536703ce211d2cdaa2901937e31c31751b21a1d340e71`
for `scripts/contracts/run-spec-002.sh` and
`e6dbd490831d09240304943ad75a9a5be6bfa5e52bc2ad3658652fd832ca4d46` for
`scripts/contracts/collect-spec-014-armv6-evidence.sh`.

The SPEC-002 runner now uses SwiftPM's native build system and explicit target
selection for both compiler baselines; the SPEC-014 ARMv6 evidence collector
also requests the native build system. These targeted passes are recorded as
post-run diagnostics, not retroactive changes to the 83-check receipt. The
focused SPEC-005 failure is retained in
[`post-run-targeted-receipts.tar.gz`](../post-run-targeted-receipts.tar.gz)
(input-set SHA-256 `8d0e9bdf6929e98957550ca35fb8d5fc9a585d4cfb058ad9936f04c5ef3d643f`;
metadata SHA-256 `8f9f44f899f12df24d2cef893e9b6cf739a77a073771bda799f3c3cd082dbb0b`;
`run.log` SHA-256 `52d3f0cebce826ac94ffbe1e9380f4ce2f2f9a31821e8f6f178eb2a393b1b45b`).
It ran in the shared dirty worktree; only the reports and hash manifests are
archived, not a complete source snapshot. It shows the exact-surface failure
after 22 declarations; P10 and the affected criterion rows remain unmet.
