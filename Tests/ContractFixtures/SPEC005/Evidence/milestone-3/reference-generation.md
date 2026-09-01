# SPEC-005 T3.1 Reference Generation Evidence

T3.1 adopts the exact Inter 4.1 source and OFL text into a production-owned,
hash-pinned generation workflow. The checked-in generator was reviewed as a
fresh SPEC-005 implementation; SPIKE-005 remains evidence only.

## Reproduction

```text
scripts/text-resources/setup-reference-generator.sh
scripts/text-resources/verify-reference-generation.sh --verify
scripts/contracts/check-spec-005-reference-generation.rb
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```

The setup step installs only the two hash-pinned wheels into
`.toolchains/text-resource-generator/`. Verification generates twice in fresh
temporary roots, rejects any byte or name difference, and compares the result
with the checked-in generated directory.

## Adopted facts reproduced

| Fact | Result |
| --- | --- |
| Source SHA-256 | `40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82` |
| License SHA-256 | `262481e844521b326f5ecd053e59b98c8b2da78c8ee1bdbb6e8174305e54935a` |
| Derived name | `GiftUI Reference Sans` |
| Mappings / glyphs | `96 / 102` |
| Manifest bytes | `6218` |
| Bitmap bytes / digest | `1911 / 69cf6841d1ecd25079a63f3dcc6866c119cd11ca4c62115185af99781d13af68` |
| Outline bytes / digest | `13195 / 3d05ced8a32b17a45569b6650ea4fe88b1f2f0dc93493e79631a628d56df4c5f` |
| Resource identity | `bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910` |

The registered asset inventory hashes the production source, license,
generator, pins, setup/verification scripts, generated catalogue, both
generated payload sources, and generation manifest. The driver audit fails on
missing or extra generated output, changed hashes or sizes, tool/input drift,
count drift, missing descriptors, or incomplete tables/payloads.

This is host build-tool evidence. It makes no Raspberry Pi, nRF52840,
simulator, connected-hardware, deployment, service, or flashing claim.
