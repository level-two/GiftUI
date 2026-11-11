# SPEC-007 Generic/Layout baseline differential — 2026-11-11

This follow-up closes the retained Generic/Layout portion of LY-RD-001's
baseline-corpus action. It records adapter equivalence evidence only; it does
not change any criterion disposition, close T9.1, or claim the transferred
application layouts, target execution, P11 accounting, P12 adoption, or human
lifecycle decisions.

`RuntimeDerived/LayoutT4T5Differential.swift` instantiates the retained
non-application T4 stack/modifier corpus, every T5 text vector (including
overflow results), and the T6 combined recording/profile-equivalence graph.
The Signal Analyzer application fixture is excluded because its layout work is
allocated to I4. Each fixture is evaluated once through the generic
`SemanticLayoutView` and once through the seeded `SemanticRecordLayoutView`
adapter. Baseline source identities are mapped to the corresponding canonical
record ordinals, then the result, summary, ordered begin/scope/line/glyph/
publish trace, scope bounds and clips, text-line bounds/baselines/clips, and
glyph resource IDs/IDs/baselines/clips are compared. The arithmetic-overflow
fixtures compare failure results and the absence of staged output as well.

The 32-case differential runs inside the existing P05 owner route. The T6 case
also asserts the exact eight-scope summary and canonical ordered transcript,
including reference glyph IDs `1` and `96`. Both macOS profiles execute 368
total assertions with zero failures; Pi and nRF compile
the same fixture and pass their target ABI checks. Those embedded profiles are
compile-only and do not execute on hardware. Each report binds the exact P02
core receipt, local Swift 6.4.0 compiler SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`, command
transcripts, fixture/source hashes, and output artifacts. The reports were
generated at source commit `4989723bb85a4310ad3bc557680e78eee63b4bf8` on a dirty
worktree; every helper input is individually hashed in each archived
`result.json`.

| Profile | Result JSON SHA-256 | Archive SHA-256 | Result |
| --- | --- | --- | --- |
| macOS Dynamic | `f9ed91c86c99058fc33624e2cefaf289328aa4647c2eb75f8b0b6aafce05f353` | [`macos-dynamic.tar.gz`](runtime-bank-layout-differential-2026-11-11/macos-dynamic.tar.gz) `ebcce36e113d1c16f37cfac02cda1f289dd5da789ecd3a1e06cdf4ab2b73f748` | Executed: 368 assertions, zero failures; two expected escaping-view negative compiles. |
| macOS Static | `ec02b2b6c853ba97c68bc4e47c603511cfae0512a1b01ba768e0347d70eaca8f` | [`macos-static.tar.gz`](runtime-bank-layout-differential-2026-11-11/macos-static.tar.gz) `537258c8e510876073e379d7d5a72ca3cc86dfd3d9dd0e263aa855efb927b252` | Executed: 368 assertions, zero failures; two expected escaping-view negative compiles. |
| Raspberry Pi ARMv6 | `878d2a6d9d175162e74d554802351a29ddc69cc2db865b2265575d337acde00d` | [`raspberry-pi-armv6.tar.gz`](runtime-bank-layout-differential-2026-11-11/raspberry-pi-armv6.tar.gz) `b7c833820e351e7df958bbf0188b9b961f15626ab6784fe29c730e6879d7e3af` | Cross-compilation and ARMv6/ABI checks passed; no target execution. |
| nRF52840 Embedded | `828ee33098d511eb0d14f18ee9018fa70a4382574b432c0a26718dc38117cbf8` | [`nrf52840-embedded.tar.gz`](runtime-bank-layout-differential-2026-11-11/nrf52840-embedded.tar.gz) `3037445b688d6657df83287ce64dc180499f04accf2dee48a51681111200fa49` | Cross-compilation and ARMv7E-M/VFP ABI checks passed; no target execution. |

The complete reports, commands, logs, module artifacts, and input manifests are
inside the four archives. The run reused the current four P02 core receipts
identified in each report; it did not rerun the aggregate root test gate, which
remains blocked before test execution by transferred analyzer-owned diagnostics.

Remaining LY-RD-001 work is the pair of analyzer-specific application-layout
differentials under the approved I4 transfer, plus any connected target
execution required by the final owner matrix. LY-RD-001/002 remain `UNMET` until
the complete criterion evidence and independent disposition are reviewed.
P10 remains the immutable 55/28 failed run; P11 evidence still lacks the
required connected/all-route accounting; P12 remains no-removal/no-cutover.
P08 remains FROZEN / UNMET, and no lifecycle or iteration status changes follow
from this evidence.
