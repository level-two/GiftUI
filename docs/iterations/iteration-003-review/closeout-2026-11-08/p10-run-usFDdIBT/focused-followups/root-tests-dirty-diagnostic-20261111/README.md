# Superseded unpinned root-test compile diagnostic — 2026-11-11

This first manual invocation did not export the project-local Swift variables.
Although `swiftpm-command` used the local Swift 6.4 driver, SwiftPM's build
description selected Xcode Swift 6.3.3 for compiler jobs. The dirty-worktree
run reached compilation and logged analyzer errors plus Semantic Core
associated-type/lifetime errors, but the latter are not evidence under the
approved Swift 6.4 compiler. The run has no complete source manifest and is
superseded for current compiler applicability by the explicitly pinned attempt
in [`root-tests-pinned-20261111`](../root-tests-pinned-20261111/).

The raw log SHA-256 is
`d534a132410a0f6c68a3b3205d889a2303c367b8f2f74f2457417b8112b34fb3`. Neither
root-test attempt changes the integrated `run-v8GRC8xq` 55/28 result.
