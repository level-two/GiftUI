# P08 control-resident correction 2 — focused independent source review

**SOURCE PASS at `999de5f9`.** The sole Swift change closes the missing scoped
extension bounds behind the eight preserved compiler errors. No additional source
blocker is found in this bounded reassessment. Compiler acceptance remains pending.

At CounterPipelineOwner.swift:754–755, the private cleanup extension now repeats
the original type's concrete protocols, ~Copyable/~Escapable permissions and three
SemanticCompleteIdentity equalities exactly. The scoped constructor extension
already has these bounds. The owned returnWorkspaces extension intentionally keeps
its explicit Copyable/Escapable bounds. The cleanup helper body, borrowing/access
annotations, callers, state, field loans and quiescent exactly-once clear are
unchanged. No wider capability, escaping value or ownership erasure is introduced.
The exact Swift diff contains only this clause and its explanatory comment.

The [freeze](p08-control-resident-cycle2-source-freeze.md),
[source manifest](control-resident-cycle2-source/manifest.json), exact patch and
three changed file hashes verify. The current qualification hash is
`9fb75756c6a148cfda414a0518ff9373721ce010b1a243b31089d154b4d2532f`;
the driver pins that path, hash and activity without changing verification logic.
All eight current candidate hashes match. Seven predecessor receipt entries and
exclusion metadata are unchanged from the just-reviewed qualification; their
receipt hashes verify. The 895/180 unchanged input proof was not repeated.

The [immutable failure packet](control-resident-initial-measurement-failure/failure.json),
compressed failed source and archive member hashes verify. All eight primary
errors concern the same implicit Copyable/Escapable helper specialization. The
failed invocation remains failed: 23 preparations passed, counter-model failed,
layout was blocked and 202 cases were not run; no counter object or raw target
facts were produced. Driver Python AST checks pass. The source author's 77
compiler-free test results are recorded in the freeze, not rerun here. This review
performed no compiler, build, runtime, image or source mutation.

Correction **2/2 consumed**, with productive cause-specific narrowing; historical
allowances remain closed. Proceed with the one affected fresh measurement below.
Any decoded layout facts remain diagnostic and accepted=false until reservation
validation succeeds. The unchanged old 32,000-byte reservation may require the
already planned exact measured Swift/C sizing completion and independent review;
this does not authorize a third optimization variant or another repair loop.
P08/R07/T8.1/HC-RD-003, current runtime behavior and complete resource fit remain open.

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures --fresh-focused --select-family so07-layout-facts
```
