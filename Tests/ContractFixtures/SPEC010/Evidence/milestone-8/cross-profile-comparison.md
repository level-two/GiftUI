# SPEC-010 T8.4 Cross-Profile Comparison

Date: 2026-09-14

All four SPEC-010 reports share input digest
`9ed90617cd81f0d9a9574a25bbf18dc6b8b7cf9130dcc88c8c7867ffb88c115c`
and generated declaration digest
`02831ec5318c786ef899dcae52c0f82910981af79658f4e81bdb45e8645c862b`.
All four corresponding production-profile reports are byte-identical for:

| Artifact | SHA-256 |
| --- | --- |
| `audit.tsv` | `cee34740b22a573fa934dd6adb212230976b281cf2af7b3f9082828215e205d3` |
| `limits.tsv` | `65e16646401e3d8056787fe8bf656d75bb961118c6b3861fc6b5ebaa85fe1024` |
| `fixture-results.tsv` | `53e1803c9a9a6d1c09c0d391de6d057bd6a6e387182d4c1463f720f625a16774` |
| `storage-high-water.tsv` | `dcdbe06b908ccd773e152bdc05458abc773170123eea6bc1711edfaa9abd07f9` |
| `transcript-input-digests.tsv` | `f0dd99a33fe8b57be9a8353a0dc37bd5ffe8d2c5529d10be3a7ed2b2b0f61d7e` |

Compiler identity, ABI, allocation strategy, elapsed timing, sections, link
maps, and target attributes are intentionally profile-dependent and remain in
their individual immutable reports. The two macOS runs are host-execution
evidence. Raspberry Pi and nRF52840 are compile/link and inspection evidence
only. No simulator or connected-target evidence is claimed.

Reproduce by running the four SPEC-010 and four SPEC-013 standalone drivers,
then comparing the files above with `shasum -a 256`.
