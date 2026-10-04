# Startup admission ordering follow-up

Date: 2026-10-05. Follow-up to T11.1 and local T11.2 coverage.

The real source activates its generation before its synchronous startup callback. Mark the repository source active before invoking `start`, allowing terminal revision failure to quiesce it before publishing the reserved operational-failure fact. Cleanup after a thrown start remains idempotent; no exact stop-call count is a contract.

The real source/repository/admission seam passes at UInt32.max and max-minus-one: one terminal admission/completion, no subsequent running publication or mutation reentry, source already stopped at failure admission, no policy result, and no later Clear/Start/stale-generation facts. Callback-then-throw and normal lifecycle regressions remain passing. The nRF repository producer rehearsal passes; cross-profile and connected T11.2/T11.7 evidence remains pending.

[Raw validation](validation.log), [changed source identities](source-hashes.txt). Focused Swift Testing: 21 tests passed. Command: `giftui_swiftpm --package-path "$PWD" --scratch-path "$PWD/.build/iteration-002-focused" --cache-root "$PWD/.build/iteration-002-cache" --swift-flag -DGIFTUI_DYNAMIC_PROFILE -- test --filter 'realSourceStartupTerminalAdmission|SignalAcquisitionRepositoryLifecycleTests|SignalAnalyzerPresentationAdmissionAdapterTests|nRFRepository'`, after `scripts/format-swift.sh`.
