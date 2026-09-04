# SPEC-006 Migration Baseline

Plan task: `T0.4`

Date: 2026-09-04

The machine-checked `migration-inventory.tsv` is derived from the immutable
`PoC` tag at `d5d6330432caa7c983d8dba35cf9f23c3800860b`, the same historical
baseline governed by SPEC-002. Its 23 rows cover every file and occurrence
count returned by four exact source scans:

- 49 `_visit`/`ViewVisitor` declarations, calls, conformances, and client
  overrides across 14 paths;
- 20 string-path/state-key occurrences across four dynamic-runtime/test paths;
- 14 wrapper initializer or storage exposures across four composition paths;
- nine `ViewBuilder` entry points in the former builder source.

Every row has one allowed disposition. Rank 0 declaration and builder shapes
are replaced only through SPEC-006's sealed surface; concrete stack, text, and
button hooks remain removed for their owning Specifications; old dynamic and
static expansion engines are already absent; client-authored traversal
witnesses and string identity are removed.

`check-spec-006-migration.rb` reproduces every PoC path/count map, pins the tag
revision, and rejects maintained `_visit`, `ViewVisitor`, `path: String`, or
string-backed `StateKey` compatibility code. The check is registered in the
SPEC-006 driver input identity and preflight. There is no compatibility shim
or second expansion engine in the current tree.
