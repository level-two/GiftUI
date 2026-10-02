# T10.7 — Independent dependency cleanup and final verification

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

## Selected-runtime closure validation — 2026-10-02

Each macOS executable now has one direct selected-runtime dependency and
constructs that owner's actual bounded interaction candidate storage using the
preset action capacity. The positive closure check requires that runtime; the
negative fixtures remove it or introduce the opposite runtime. Static still
excludes Dynamic conveniences and both exclude mixed TargetHost composition.
The combined comparison stays in explicit harness/test code.

The exact SPEC-002 graph is 84 targets / 375 direct edges. Both independent
executables pass with semantic checksum 360515885 and 2,400-event workload checksum
18300581, category high-water 20. The interface audit and closure negatives pass.
The six actual Dynamic/Static production failure rows also agree after the live
firmware join. This adds positive selected-owner evidence to the earlier absence
checks; it does not claim these preset executables are connected production hosts.
T10.7's final dependency prerequisite remains the outstanding T10.6 stack check.

## Final completion — 2026-10-02

T10.5 and T10.6 are complete, including connected stack validation. The final
actual package graph again passes positive/negative closures and the complete
interface audit (84 targets / 375 edges). Fresh builds in two independent
scratch directories execute each product, with semantic checksum 360515885,
workload checksum 18300581, 2,400 events at 80 Hz for 30 seconds, 120 frames
and category high-water 20. The explicit combined production fault comparison
remains equal. Actual firmware isolation is separately verified in T10.6.
`final-executable-isolation.tar.gz` retains this final graph and both run logs.
Earlier blocked dispositions above are historical and superseded by this check.
