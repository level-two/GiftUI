# Pinned root-test compile diagnostic — 2026-11-11

This bounded `swift test` attempt explicitly pinned the SwiftPM driver and
compiler to the project-local Swift 6.4.0 toolchain (compiler SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`), used a
fresh scratch path, and disabled SwiftPM sandboxing. It reached compilation and
failed in `SignalAnalyzerPresentation/SignalAnalyzerView.swift` with analyzer
`Schema` inference and dependent `View` conformance diagnostics. There were no
`SemanticRecordExpansion.swift` diagnostics in this pinned log. The earlier
unpinned root-test attempt is retained separately and its Semantic Core errors
are not attributable to the approved Swift 6.4 compiler.

The worktree remains dirty and this focused capture does not include a complete
per-file source manifest; it is diagnostic evidence, not criterion-level
conformance or a clean-source P10 result. The root test failure does not alter
the latest completed integrated run `run-v8GRC8xq` (55/28). The log also
contains sandbox warnings during cached dependency resolution; the command
explicitly passed `--disable-sandbox` and proceeded to source compilation, so
those warnings are not treated as the compile failure's cause.

Raw `run.log` SHA-256:
`35a807002395d427e89b79940f9d304a744cca69f3cba14f891b21cd2702d7eb`. The
exact log and invocation are stored in `report.tar.gz`, SHA-256
`0d2e00c807118c45d0d1e3e9a14ead37230fb46f0c1db871c24cd92dd103dcc4`.
