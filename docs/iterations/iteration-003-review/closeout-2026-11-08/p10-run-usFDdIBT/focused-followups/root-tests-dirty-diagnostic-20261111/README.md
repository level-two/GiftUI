# Focused root-test compile diagnostic — 2026-11-11

This is diagnostic evidence from the current dirty worktree, not a source-bound
P10 result. The invocation used the project-local Swift 6.4 toolchain, disabled
SwiftPM sandboxing, and reached compilation. It then exited with
`swiftpm-failure-class=compiler-or-test` on `SignalAnalyzerView.swift` schema,
Canvas/View errors and `SemanticRecordExpansion.swift` associated-type and
lifetime diagnostics. The worktree contains unrelated concurrent changes and
this capture has no complete per-file source manifest; do not attribute these
diagnostics to the approved Swift 6.4 baseline or use them as criterion-level
verdicts. No product or status change follows from this attempt.

The integrated gate remains `run-v8GRC8xq` (55/28). The raw log SHA-256 is
`d534a132410a0f6c68a3b3205d889a2303c367b8f2f74f2457417b8112b34fb3`.
