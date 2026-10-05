# Current reference provenance correction — 2026-10-05

The fresh aggregate `run-bmuwVkCK` failed its Pi comparison: frame3 historical
macOS count64 versus new Pi count60. Current canonical root output already
reported count60. The raster checker defaulted to immutable milestone-10
30s traces, despite the current root corpus passing. Historical bytes remain
unchanged; they cannot be the default oracle for the five-second contract.
The failed invocation/child log is retained here and under its original run.

The aggregate now publishes a current trace bundle from its successful root
log (120 Dynamic frames/9 other frames/12 actions, 818 Static frames/12 actions).
Source and trace hashes identify the bundle. SPEC-001 verifies current source
identity and copies the bundle into its retained staging report; standalone
SPEC-001 captures/publishes its own successful current reference test output.
Raster checks receive an explicit bundle and no longer default to history.
Missing/incomplete traces, changed sources or changed trace bytes fail closed.

Three fixture tests/nine assertions pass for current identity, stale-source/
byte refusal, incomplete publication and historical-only refusal. Shell syntax
and repository governance pass. Comparing the fresh root bundle with the
already collected Pi native trace passes: all120 workload frames,9 initial/
action frames and12 actions. Product source did not change. A fresh complete
gate follows this check-command/provenance correction; the preceding failure
is not reclassified as a pass.
