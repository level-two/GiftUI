# P08 candidate A — focused independent reassessment

**SOURCE PASS at `9cac6bfa`; B01 closed; screen 0/1.** This reassessment follows
[the preserved blocked review](p08-stack-candidate-a-independent-source-review.md)
and checks only the [mechanical correction freeze](p08-stack-candidate-a-review-correction-source-freeze.md),
[manifest](stack-candidate-a-review-correction/manifest.json), exact diff and
[refreshed qualification](p08-stack-candidate-a-review-correction-applicability.json).

Against `e33f57ea`, CounterScopedStorage.swift is the only changed Swift path.
Its bytes equal the prior frozen source after exactly five replacements of
`transcript.pointee.runtime.admission` with `transcript.pointee.admission`
at 1605, 1608, 1609, 1610 and 1628. The four stale submissions and original
retained handle assignment are restored; no current-host handle is substituted.
The other 30 valid Control projections and all previously reviewed changes are
unchanged. No additional blocker is found within this focused scope.

Five current/baseline Swift hashes, two glue hashes and the exact source diff
verify. Manifest SHA-256 is
`cc405f6c34ed6f218f27a10321f1b551aebd88cf31441c878877143fe9329528`;
qualification SHA-256 is
`cda1a6e231fa50509f8d709b10ecd3f8a3c99cbb86e244f3b3d8c717c09af335`.
All seven original receipt entries are unchanged. Independently checked receipt
hashes, old metadata hashes, argv-derived input counts/digests (53, 53, 112, 173,
173, 159, 172) and all five candidate-file exclusions. Only the corrected source
hash changes in the candidate-source map. The driver changes only the
qualification path; guards remain unchanged. AST and 384/202 scoped inventories
plus 26 reuse labels verify. No old compiled counter result is promoted.

The same candidate remains **1/1**, with one explicitly recorded mechanical
pre-execution correction; screen **0/1**, historical 2/2 closed. No optimization
variant, resource limit, capacity, contract or execution allowance is changed.
No compiler, test gate, build, runtime or image was run. Source readiness permits
the single registered diagnostic screen below; target code-generation effect,
full coverage and P08 fit remain unproved under the 27,648-byte baseline.

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --fresh-focused --select-family so07-layout-facts
```
