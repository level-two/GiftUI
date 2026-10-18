# P08 Analyzer ABI diagnostic discovery sweep — raw result

This archive preserves the one authorized diagnostic-discovery run against the
reviewed packet at commit `6731bbeb81ecd2c3390f700703e960ed3a30dc1c`.
The run's terminal status is
`discovery_archive_complete_unqualified_review_required`. Its 56 cells and 118
compiler stages produced 50 target dispositions: 44 expected nonzero diagnostic
observations and six positive completions. Three repeated ARMv6 positives and
three isolated core producers account for the other six cells. No control was
qualified, no repair or retry was spent, and no campaign receipt was issued.

`result.json` contains the exact stage commands, result dispositions, input and
artifact identities, raw log references, and reviewed packet provenance.
`archive-manifest.json` lists 824 files from the original raw result root with
their byte lengths and SHA-256 values. The 118 `audits/` JSON files in that
manifest are stored byte-for-byte in `audits.tar.gz`; all other listed files
are present at their manifest paths. `payload-manifest.json` identifies the
portable archive payload. Every manifest-listed file was checked against the
raw result before this archive was committed.

The archive is discovery evidence only. A later exact diagnostic-policy batch
needs separate review and parser tests. A fresh sequential four-profile
campaign, under the normal first-material-failure rule, is required to qualify
controls and advance toward P07, schema-4, or counter stages. Target compiler
cache and object artifacts outside the primary raw result root remain in
`.build/contracts/`; their identities are recorded in `result.json` and the
stage audits.
