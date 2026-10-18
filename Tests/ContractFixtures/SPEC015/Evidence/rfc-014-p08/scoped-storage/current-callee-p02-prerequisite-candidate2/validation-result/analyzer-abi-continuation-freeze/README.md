# P08/P02 Analyzer ABI postformat freeze

The user authorized one new eight-annotation source candidate and one sequential
validation campaign on 2026-10-18, with zero automatic repairs and no retries.
This freeze records the 541 declared input hashes after the exact source edit and
restricted three-file `swift format` invocation. Only the four selected source
paths differ from the preparation packet's `baseline-inputs.json`.

`postformat-freeze.json` SHA-256:
`0cb2c32520e4344940c4801c9bfea21206e828dd2d6db07dfb8ae06dd4840333`.

The candidate is exactly the eight `@usableFromInline` insertions in
`analyzer-abi-continuation-preparation/selectors.json`. The formatter made no
additional source change. This record does not claim compiler or contract PASS.
The guarded campaign wrapper must check these inputs again before every stage.
