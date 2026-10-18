# Candidate 2 validation STOP — P08 current-callee P02 prerequisite

This receipt records the single maintained validation attempt for candidate 2.
The prepared runner README and frozen inputs remain at `../validation/README.md`;
the immutable run result and selected artifacts are copied here from the sole
output directory `.build/contracts/p08-current-callee-p02-prerequisite-candidate2-validation1`.

## Outcome

Candidate 1/1 was consumed; automatic source repairs 0/0. No retry or repair
followed. Historical closed budgets remain closed. The runner stopped at
`fresh-core-and-registered-records`; all dependent stages were unrun.

Exact stage sequence from `runner-result.json`:

1. `macro-compile` — PASS, exit 0.
2. `macro-link` — PASS, exit 0.
3. `macro-tests-link` — PASS, exit 0.
4. `macro-tests` — PASS, exit 0.
5. `fresh-core-and-registered-records` — FAIL, exit 1.
6. All later P02 producer, registered P04, P07, schema-4 activation join and
   negatives, and 384 counter controls — NOT RUN (blocked by runner stop).

The failed stage compiled core modules and generated `AnalyzerSchema.swift`;
that generated schema compile failed. `AnalyzerSchema.log` is the compiler
diagnostic; the copied generated source is the exact failing generated input.
`CounterPresentation.log` is empty (successful compile); it is retained only as
corroboration that CounterPresentation compilation completed before the schema
failure. No contract, scope, or repair conclusion is made by this evidence receipt.

## Provenance and hashes

Source commits recorded by the runner: `778233fc`, `34601caa`. Copied from these
repository-relative paths:

- `runner-result.json` from `.build/contracts/p08-current-callee-p02-prerequisite-candidate2-validation1/result.json`
- `AnalyzerSchema.log` and `AnalyzerSchema.swift` from `.build/contracts/spec-006-rfc-014-swift64/a8a3a315f9ee95ca-s9gcp7qu/macos-static/`
- `CounterPresentation.log` from the same `macos-static/` directory
- stage stdout/stderr from `.build/contracts/p08-current-callee-p02-prerequisite-candidate2-validation1/logs/`

SHA-256 values below are for these copied bytes; sizes are recorded to detect
truncation.

- `runner-result.json` — SHA-256 `1fe685148784644e60c294bda8be45d514161582789fc9577c4e0d73e120295c` (12629 bytes)
- `AnalyzerSchema.log` — SHA-256 `de911941bbf7fcb6aee9739b745906a4641be2a5eb5d2d325a1f8bba299a067f` (7360 bytes)
- `AnalyzerSchema.swift` — SHA-256 `421e09a47b2d1f117f6a752681943a386345d078fcbf7a19af05797d1e3e3b85` (3247 bytes)
- `CounterPresentation.log` — SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes)
- `fresh-core-and-registered-records.stderr` — SHA-256 `d7b15de9872dabb8264ddbae64206c2420f4c4b46b766b4775b94a1787766d67` (4154 bytes)
- `fresh-core-and-registered-records.stdout` — SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes)
