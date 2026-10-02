# T10.7 — Independent dependency cleanup; final join verification blocked

The only profile-specific code in `SignalAnalyzerHost` was its two action
dispatcher factories. They now belong to the existing
`SignalAnalyzerTargetHost` composition module. Shared fact admission remains
in `SignalAnalyzerHost`, whose direct dependencies are Execution, Host
Configuration, Domain and Presentation. Four obsolete direct edges were
removed, including both runtime profiles. No new target or product was added.
The approved logical ownership and inward graph remain intact.

`check-spec-001-executable-closures.py`, registered in the interface audit,
checks the actual package graph. Neither independent macOS preset executable
reaches the other runtime, the mixed target composition module, or (for Static)
Dynamic conveniences. Deliberately added opposite-profile edges fail the same
closure predicate. The exact SPEC-002 allow-list and SPEC-011 consumer/source
registries reflect the relocation; historical evidence remains revision-scoped.

Validation: interface audit passes for 84 targets / 373 direct edges and
positive/negative executable closures. Nine action dispatch/integrated-cycle
tests pass, including six typed action codes, stale generations and profile
replacement/refusal parity. Both independent executables report the same
semantic checksum 360515885 and sustained workload checksum 18300581; their
profile storage differs as expected (Dynamic 41376, Static 39696). Existing
mixed comparison remains an explicitly selected test/harness. The SPEC-013
downstream integration check now reads the actual target composition owner.

Limitations: these executables validate presets and application scenarios;
their dependency closure is not production firmware isolation or evidence that
the missing production common-runner joins execute. Final T10.7 remains
blocked by T10.5/T10.6, as the plan requires its final check to consume both
joins. The wider SPEC-011 integration audit also reports its existing allocator
construction-count assertion; it is not waived by this dependency check.
