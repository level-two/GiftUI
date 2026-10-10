# P01 compiler and Foundation baseline receipt — 2026-10-10

**P01 passed. P02 is next; P02–P12 remain pending.** No scope change or remaining
P01 criterion failure. This receipt covers SPEC-002 PF-006/PF-007's refreshed
compiler/measurement seam and SPEC-013 RP-RD-003's compiler-selection portion;
it does not establish runtime/application conformance or complete T7.1.

Input commit: `b05e22870f4493c11cf8b662fdd4614e7fdf1c9f`.
Initial implementation commit: `bb61d4ef`; ARMv6 path correction: `b77d85f7`
(full final identity in the [baseline snapshot](baseline.json)). Validation ran
against the staged inputs before each implementation commit. The snapshot
records changed files, source/recipe/route hashes, all exact commands, compiler
executable hashes, SDK/target/optimization identities and linked artifacts/maps.
The implementation and this evidence receipt are separate attributable commits.

## Delivered boundary

- `run-spec-002.sh --compiler-baseline rfc-014` selects only project-local Swift
  6.3.2, LifetimeDependence and Lifetimes. The actual target configuration checks
  required features and the internal lifetime annotation before production compilation.
- Historical omission retains Swift 6.3.3 on macOS and the original cross-target
  pins. Historical/migration reports and counterpart comparisons are disjoint;
  migration immutable inputs additionally include the selected compiler bytes.
- The top-level runner explicitly registers the compiler controls and the new
  Foundation invocation for each selected profile, alongside the old commands.
- The [finite route inventory](../../CompilerBaseline/route-inventory.tsv) freezes
  26 analyzer/counter/syntax families for subsequent packages, not occurrence
  topology. The counter is a requirement inventory awaiting P02/P08.

## Validation

All four commands passed with exit 0:

```text
scripts/contracts/run-spec-002.sh --profile macos-dynamic --compiler-baseline rfc-014
scripts/contracts/run-spec-002.sh --profile macos-static --compiler-baseline rfc-014
scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6 --compiler-baseline rfc-014
scripts/contracts/run-spec-002.sh --profile nrf52840-embedded --compiler-baseline rfc-014
```

Every configuration reports the same eleven layouts. Sizes include Point/Size 8,
Rect 16, ProposedSize 13 (stride 16), NormalizedPointerEvent 28; all ceilings pass.
Native semantic transcripts are byte-for-byte equal at checksum 28. ARMv6/nRF
optimized target IR agrees; it is cross-build evidence, not target execution.
Native Foundation operation probes each report allocation_count=0. Cross-target
operation IR checks find no forbidden allocation facility on the exercised path.
Both linked ARMv6 images pass CPU/hard-float verification; both nRF images report
`Tag_ABI_VFP_args: VFP registers`. Native linked images report arm64.

| Profile | Code delta | Read-only delta | Initialized delta | Zero-initialized delta | File delta |
| --- | ---: | ---: | ---: | ---: | ---: |
| macOS Dynamic | 292 | 0 | 0 | 0 | 80 |
| macOS Static | 292 | 0 | 0 | 0 | 80 |
| Pi ARMv6 | 272 | 8 | 0 | -288 | 368 |
| nRF Embedded | 248 | 0 | 0 | 0 | 532 |

These are descriptive matched baseline/candidate Foundation deltas. They are
neither whole-application resource budgets nor evidence for P11's linked Static
zero-heap/stack/workload obligations. Production Foundation code is unchanged.

`python3 scripts/contracts/check-spec-002-compiler-baseline.py` passed all 17
controls: four positive selections, eight individual missing-feature rejections,
unknown/missing baseline, absent compiler, compiler drift and unknown profile.
The historical `run-spec-002.sh --profile macos-dynamic` also passed using Apple
Swift 6.3.3 (`swiftlang-6.3.3.1.3`). Its distinct report is in the snapshot.
Formatter/lint, shell syntax, explicit driver registry, governance/authority/task
evidence validation and `git diff --check` pass. The broad gate remains P10.

One nRF build failed because CMake deduplicated repeated feature switches and
left bare feature-name inputs. The single repair grouped each switch/value with
`SHELL:`; the subsequent complete nRF driver passed. Native/ARMv6 reports precede
that CMake-only repair: their effective compiler recipes and sources match the
implementation commit and do not invoke that CMake branch. Their input inventories
retain the earlier CMake hash rather than falsely claiming a uniform input set.
The failed staging log remains generated evidence under
`.build/contract-reports/spec-002/rfc-014/.tmp-nrf52840-embedded-63497/run.log`.

## ARMv6 output-root correction

After the initial receipt in `6add7f4b`, review found that the inherited driver
placed generated ARMv6 builds beneath the report directory. `b77d85f7` moves
migration scratch builds, IR and linked artifacts under `.build/raspberry-pi/`,
retaining immutable evidence copies in the report. Historical reproduction is
unchanged. The complete ARMv6 migration driver was rerun and passed; generated
images and report copies match byte-for-byte and every linked delta above is
unchanged. The snapshot preserves the superseded ARMv6 report separately.
Native/nRF effective build branches were unchanged, so their earlier reports
remain applicable with their original full input hashes. No broad rerun was
needed for this path-only correction.

## Remaining boundary

P02–P12 retain their existing dependencies, exits and footprints. T7.1 remains
unchecked until P10–P12 disposition Foundation's full migration criteria and
resource/cutover obligations. Other eight owner Specs/plans have not started.
No connected operation, full conformance claim, Spec implemented transition,
production cutover or iteration closure occurred. No optional discovery required
a new deferred item; no package or approved bound was added.

- [Shared bounded sequence](../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md)
- [SPEC-002 owner plan](../../../../../docs/implementation-plans/spec-002-implementation-plan.md)
- [SPEC-002 conformance record](../../../../../docs/conformance/spec-002-conformance.md)
