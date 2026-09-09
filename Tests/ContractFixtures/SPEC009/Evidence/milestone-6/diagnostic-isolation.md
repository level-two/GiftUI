# SPEC-009 T6.5 Diagnostic Isolation Evidence

`ExecutionDiagnosticIsolationTests` runs the same completed execution snapshot
with diagnostics omitted, selected and accepted, saturated, dropped, and
failing. The snapshot retains the admission outcome, mandatory mechanical
effects, semantic and candidate revisions, presentation identity, offer count,
wake reasons, retry count, exact failure mapping, final summary, and
authoritative coordinator state. Every configuration compares equal to the
baseline; omitted diagnostics also prove lazy record construction.

The fixture enters a diagnostic-only phase before sink delivery. An attacking
sink then attempts both an authoritative semantic mutation and a client action.
Both attempts are rejected, the rejection count is observable, and mutation,
action, and authoritative-state counters remain unchanged. Production
`GiftUIFailureExecution` retains only its Failure Core and Execution imports;
Failure Diagnostics is a test-only dependency.
