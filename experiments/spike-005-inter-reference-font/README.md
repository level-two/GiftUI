# SPIKE-005 Inter Reference Font Experiment

This disposable experiment derives a bounded SPEC-005 reference package from
the official Inter 4.1 `Inter-Regular.ttf` release member. It does not define a
production outline provider or authorize reuse outside the normal lifecycle.

## Source acquisition

The checked-in `source/Inter-Regular.ttf` and `source/LICENSE.txt` were
extracted without modification from:

```text
https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
```

The generator rejects a source font whose SHA-256 differs from the pinned
value. `generated/PROVENANCE.json` records the archive member, hashes,
copyright, license, derived name, and tool versions.

## Reproduction

From the repository root on Apple-silicon macOS with Python 3.9:

```text
experiments/spike-005-inter-reference-font/run.sh
experiments/spike-005-inter-reference-font/run.sh --verify
```

The runner installs hash-pinned fontTools and Pillow wheels into a temporary
environment, generates the complete result twice, rejects any byte-level
nondeterminism, and either refreshes or verifies the checked-in outputs.

## Spike-specific outline format

`GiftUIReferenceSans-Regular-16px.outline-v1` is a feasibility payload, not an
accepted provider format. Each gap-free glyph record begins with version,
units-per-em, and fixed pixel size, followed by decomposed move, line,
quadratic, cubic, close, or end commands with big-endian signed Int16 source
coordinates. SPEC-005 review must confirm or replace this format before any
production adoption.
