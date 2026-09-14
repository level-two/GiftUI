# SPEC-010 T8.1 macOS Profile Evidence

Date: 2026-09-14

The pristine Dynamic and Static drivers published the shared SPEC-010 run ID
`f76656e188855f67d5c72170c29167a55f8d6c90-9ed90617cd81f0d9` with Apple Swift
6.3.3, target `arm64-apple-macosx26.0`, and whole-module `-O`. Both compile the
same generated observable host bytes (SHA-256
`02831ec5318c786ef899dcae52c0f82910981af79658f4e81bdb45e8645c862b`), pass
the positive and negative ownership fixtures, and expose the same generated
traversal/declaration symbols.

The paired SPEC-013 production reports under run ID
`f76656e188855f67d5c72170c29167a55f8d6c90-31230e742780694f` reproduce equal
canonical transcripts, all 16 storage high-water families, workload timings,
and bounded stack/layout data. Their inspection keeps forbidden facilities out
of the optimized binding entry point; the Static report records zero heap
allocations and peak heap bytes. Neither run used a simulator or connected
target.

```sh
scripts/contracts/run-spec-010.sh --profile macos-dynamic
scripts/contracts/run-spec-010.sh --profile macos-static
scripts/contracts/run-spec-013.sh --profile macos-dynamic
scripts/contracts/run-spec-013.sh --profile macos-static
```
