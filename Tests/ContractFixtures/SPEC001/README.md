# SPEC-001 Contract Fixtures

This directory is the governed evidence boundary for the Signal Analyzer
reference application. `fixture-registry.tsv` is ordered and exhaustive.
`criterion-evidence-registry.tsv` registers every `SA-AC-001` through
`SA-AC-045` criterion exactly once and assigns it to one evidence class.

The five transcript schemas are strict ordered field contracts. A producer
must emit every required field exactly once, use the registered schema version,
and emit no unknown field. `evidence-kinds.tsv` limits which criterion classes
each evidence kind may satisfy. Host-native and simulator evidence cannot
satisfy cross-build or connected-target claims, and cross-build evidence
cannot satisfy target execution, display, input, or runtime behavior.

`task-evidence.yaml` is the task-level implementation ledger. Completed tasks
must name checked-in implementation, checks, and evidence. The SPEC-001 driver
will own mutable run reports under `.build/contract-reports/spec-001/`; no
mutable report is accepted as checked-in evidence merely because it exists.
