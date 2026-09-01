# Inter 4.1 Reference-Resource Provenance

GiftUI checks in the unmodified `extras/ttf/Inter-Regular.ttf` member from
the official Inter 4.1 release as the source for SPEC-005's adopted reference
package.

- Upstream project: Inter, by the Inter Project Authors
- Upstream release: `4.1`
- Selected archive member: `extras/ttf/Inter-Regular.ttf`
- Source SHA-256: `40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82`
- License: SIL Open Font License 1.1, reproduced in `LICENSE.txt`
- License SHA-256: `262481e844521b326f5ecd053e59b98c8b2da78c8ee1bdbb6e8174305e54935a`
- GiftUI derivative family name: `GiftUI Reference Sans`
- Reproduction command: `scripts/text-resources/verify-reference-generation.sh --verify`

The generator subsets, renames, measures, rasterizes, and encodes the source
into the exact immutable reference facts adopted by SPEC-005. Generated
assets use the derived family identity; the upstream name remains only in
provenance and acknowledgement.

This record preserves reviewed engineering provenance and redistribution
materials. It is not legal advice. The authoritative license terms are in
`LICENSE.txt`.

Upstream references:

- <https://github.com/rsms/inter/releases/tag/v4.1>
- <https://github.com/rsms/inter/blob/v4.1/LICENSE.txt>
