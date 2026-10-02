# T9.1 carrier implementation — 2026-10-02

Implements the approved 18b86799 amendment. All fallible common stage values,
the returned failure record, both active profile bindings, Execution wrappers
and first-failure storage preserve the configured finite owner sum. The host
instance and scheduled opportunity forward the same specialization. Existing
framework consumers explicitly specialize with RuntimeOwnerFailure.

Mutation rejection includes actual progress; the runner uses it rather than
its initial false local value. Existing test owners report prior mutation when
a subsequent application or dispatch fails. Runtime Core imports no application
or Failure Core module. No store ceiling or stage order changes.

Validation: scripts/format-swift.sh passed.
`swift test --disable-sandbox --filter 'completePipeline|FocusedFailure|profileEquivalent|everyInjected|SignalAnalyzerIntegrated|SignalAnalyzerHostFact|HostConfigurationSurface'`
passed 20 tests (including two integrated profile cases). The first compile
exposed a missing test import, repaired before this pass. This is framework
regression evidence; generic application fault and resource proofs are T9.2
and T9.3, not discharged by compilation.
