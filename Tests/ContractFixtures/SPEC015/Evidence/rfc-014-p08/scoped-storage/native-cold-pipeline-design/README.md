# Read-only complete observed cold map — 2026-10-17

Supports the [revised design](../../../../../../../docs/implementation-designs/spec-015-p08-native-cold-pipeline.md),
not adoption or allocation conformance. Candidate `9c19a879` remains unaccepted;
current HEAD at analysis was `48eb1980`; corrective cycles0/2. No source edit,
restoration retry, compiler/profile execution or new build occurred here.

`emitted-map.json.gz` maps every1015 cold group/1465 observed allocations in the
immutable silent stream to a nearest non-compiler image caller and maintained
source origin. It retains exact symbol/return offset, group/count/bytes, allocator
route and observed runtime categories. Baseline `93f6ecc7` and candidate `9c19a879`
source hashes cover42 origins. Repeated generic thunks are skipped only to locate
an owner; no event/frame is removed from the original preserved evidence.

The source mapping is navigation, **not exclusive allocation attribution**:
standard-library InlineArray construction maps to the checked project call site;
Counter.swift is the authored origin of generated presentation. Compatibility,
negative controls and equality assertions stay in the map. No category exempts
framework work or claims that every allocation beneath that source is owned by
it. This map cannot prove absent/unexecuted paths or direct-zone/VM/temp coverage.

The input archive, its prepared executable identities/full frame dictionaries and
source-candidate counterexamples are preserved by the
[initial result packet](../p08-native-cold-static-candidate1-result.md) and
[independent review](../p08-native-cold-static-candidate1-independent-review.md).
`emitted-instructions.txt` adds15 bounded slices from the existing silent executable
SHA256 `77a11a4bf23a055d027369edd712888c5884d4d970d37d8747417bed20ed1152`.
A preceding BL and its observed return offset establish the emitted edge; outlined
helpers' full allocation chains remain in the original stack dictionaries. No
future specialization effect is inferred from these old slices.

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-design/map.py
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-design/extract-calls.py
```

Both pass. The first needs only committed history/input archive and Python; the
second reads the existing hash-pinned image with Xcode otool (optional explicit
image path). Neither executes Swift work. The manifest pins these derived files;
`--write` regenerates only this packet's derived map/slices. The complete observed
map and bounded disassembly support design review, not a complete resource proof.

The attempted restoration's elevated request was aborted elsewhere. No denied
file is edited here. The proposal is a reviewed correction overlay on current
failed source, not an alternate restoration or repair-budget reset. External five
working files and pycache remain untouched. The required next evidence is actual
specialization and structural-borrow codegen at every mapped boundary, followed
by the unchanged focused host-first protocol and lifetime/behavior controls.
