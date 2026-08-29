# SPEC-002 PoC Baseline Record

This record is the reproducible provenance evidence for implementation-plan
task `T0.1`. It does not make the proof-of-concept tree authoritative.

## Immutable identities

| Evidence | Value |
| --- | --- |
| Annotated tag | `PoC` |
| Tag object | `2b2837a66b94df38c7b74ead33ebbb54aa08a06d` |
| Dereferenced commit | `d5d6330432caa7c983d8dba35cf9f23c3800860b` |
| Complete root tree | `305e3cd4226c14873204a4711e0b5fd1a7fd9d1f` |
| Tracked blobs | `215` |
| Tracked blob bytes reported by `git ls-tree -r -l` | `735192` |
| Durable remote | `https://github.com/level-two/GiftUI.git` |

On 2026-08-29, `git ls-remote` reported the exact tag object and dereferenced
commit above for `refs/tags/PoC` and `refs/tags/PoC^{}` on `origin`.

The root tree object is the complete tracked-path and content checksum for the
PoC commit. It covers the historical root manifest, `Sources/`, `Tests/`,
firmware, scripts, and legacy documents selected for disposition by Milestone
0.

## Retrieval and verification

Run these commands from the repository root:

```sh
git fetch origin refs/tags/PoC:refs/tags/PoC
git cat-file -t 2b2837a66b94df38c7b74ead33ebbb54aa08a06d
git rev-parse 'PoC^{}'
git rev-parse 'PoC^{tree}'
git ls-tree -r -l PoC
git archive --format=tar --output=/tmp/giftui-poc.tar PoC
```

The expected type is `tag`; the expected dereferenced commit and root tree are
the values in the table. The archive command reconstructs the complete tracked
tree without depending on the active working tree.

The following checks prove that the tree contains every required removal
category before any active-tree cut:

```sh
git cat-file -e PoC:Package.swift
git cat-file -e PoC:Sources/GiftUI/Geometry/Point.swift
git cat-file -e PoC:Tests/GiftUITests/GiftUITests.swift
git cat-file -e PoC:firmware/nrf52840/applications/ili9486/CMakeLists.txt
git cat-file -e PoC:scripts/nrf52840/compile-layer.sh
git cat-file -e PoC:docs/GiftUI_Framework_Spec.md
```

All checks succeeded on 2026-08-29. A missing object, mismatched identity, or
failed required-path check invalidates this evidence and blocks the clean cut.
