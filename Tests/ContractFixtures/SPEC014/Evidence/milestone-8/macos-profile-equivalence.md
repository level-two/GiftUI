# SPEC-014 T8.3 macOS Dynamic/Static Equivalence

Date: 2026-09-13

The dynamic and static collectors each ran the complete maintained Surface
Core, Raster Core, Display Core, and Backend Integration test suites with the
corresponding explicit profile flag. Both passed from isolated build roots
under `.build/spec-014/t8.3/`.

Each run normalized the same 19 four-profile fixture IDs into canonical JSON fields
for descriptor, effective capability, header, ordered regions, encoded image,
offer and body results, health, high-water counters, and failure events. The
cross-profile comparator joined by fixture ID and reported zero differences.
The capability fixture check independently proves the paired 640 x 480 macOS
full-surface values are identical.

Run from the repository root:

```sh
scripts/contracts/collect-spec-014-macos-profile.sh macos-dynamic .build/spec-014/t8.3/macos-dynamic
scripts/contracts/collect-spec-014-macos-profile.sh macos-static .build/spec-014/t8.3/macos-static
scripts/contracts/compare-spec-014-profiles.rb .build/spec-014/t8.3/comparison.tsv macos-dynamic=.build/spec-014/t8.3/macos-dynamic/normalized-fixtures.tsv macos-static=.build/spec-014/t8.3/macos-static/normalized-fixtures.tsv
scripts/contracts/check-spec-014-capability-fixtures.rb
```

The comparator reports 19 identical stable fixture IDs.
