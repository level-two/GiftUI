# SPEC-007 T9.1 Runtime-Bank Follow-up — 2026-11-11

This is a partial implementation/evidence update for the open T9.1 checkpoint.
It does not change SPEC-007, the plan status, any acceptance disposition, or the
P10–P12 gates.

`RuntimeDerived/LayoutProbe.swift` now checks that a candidate bank has exactly
one active reader during its scoped callback, that both banks have zero readers
after each callback, and that a failed layout attempt leaves the previously
published bank, revision, and root query intact before safe reuse. The probe
already covers sink begin/stage/publish refusal, scope/depth excess, and repeated
candidate reuse. The fixture uses `@testable import GiftUISemanticCore` to read
internal bank metadata inside the test module; the product API is unchanged.

Validation performed:

- Local Swift 6.4 formatting and strict lint for `LayoutProbe.swift`: passed.
- Local Swift 6.4 frontend parse for `LayoutProbe.swift`: passed.
- Fresh local Swift 6.4 SwiftPM debug build of target `GiftUI`: passed.
- The focused P05 bank-layout helper compiled, linked, and executed for macOS
  Dynamic and Static using current Swift 6.4 SPEC-006 GiftUI build receipts.
  Both profiles passed 286 layout assertions and the two expected escaping-view
  negative compiles. The exact 61-input result receipts and output artifacts
  are retained in [`runtime-bank-layout-followup-2026-11-11`](runtime-bank-layout-followup-2026-11-11/).

| Profile | P05 result SHA-256 | GiftUI core receipt SHA-256 | Retained P05 archive SHA-256 | Result |
| --- | --- | --- | --- | --- |
| macOS Dynamic | `8171a2048d6005cb167882b3c54cbda3cefb9f2bd4521a68f7cc70a99d1a1bc1` | `308ef6bcdb4c06f180c2545dabe38d511fb5d53b616bfa5abee2263814927292` | [`macos-dynamic.tar.gz`](runtime-bank-layout-followup-2026-11-11/macos-dynamic.tar.gz) SHA-256 `02065b0959fc04ca4ce87f570c76377525f4bba578801a8d59d3eedeb25c6756` | Compiled, linked, executed: 286 assertions; two expected escaping-view negative compiles. |
| macOS Static | `751e29f517d1df395c10154c8048d59705c2e49c845aa6ecd15bcbcd3b12318b` | `6ec4e9ee1a942ce73005a311c22358531ae22949b572b2a192044ff85db00a1d` | [`macos-static.tar.gz`](runtime-bank-layout-followup-2026-11-11/macos-static.tar.gz) SHA-256 `88b600fa4ad71aa57918b2c3acfe6209b665bcc2fd88cbda1df31bb14a14f608` | Compiled, linked, executed: 286 assertions; two expected escaping-view negative compiles. |
| Raspberry Pi ARMv6 | `29b360a9097acf2a78eeaed84b6233014d03085acadbab3b9eaa199f34c831ab` | `ca72f010dd95a57b8718d1e127f1855e93aa8dbb19d1d1a07ce0c04df5f6bbc4` | [`raspberry-pi-armv6.tar.gz`](runtime-bank-layout-followup-2026-11-11/raspberry-pi-armv6.tar.gz) SHA-256 `311f65f3ea88235da1298031d8edb92d17b29294824c4876e57f116e8be32339` | Cross-compiled; ARMv6/ABI checks passed; no target execution. |
| nRF52840 Embedded | `31358ed602c1276aa050c578b1c499c97cf835b2a89b18a4290905a592d34490` | `f7911f700330cdf9338b1bd84129b107e9b8604caf601d197dd9eaba28a36760` | [`nrf52840-embedded.tar.gz`](runtime-bank-layout-followup-2026-11-11/nrf52840-embedded.tar.gz) SHA-256 `7ae8856dffc721df8a9e87edded131fa9424ac1d41c190e64a66ec7746da4c35` | Cross-compiled; ARMv7E-M/VFP ABI checks passed; no target execution. |

The embedded P02 owner receipts are retained separately: Raspberry Pi 1 ARMv6
P02 passed 27 checks with input-set SHA-256
`b39b0efa2bcd6f1920175a8270b3f4af131885745974cbf5c0271cd0525ef08e`; its
`result.json` SHA-256 is `ca72f010dd95a57b8718d1e127f1855e93aa8dbb19d1d1a07ce0c04df5f6bbc4`,
and the full output archive is
[`raspberry-pi-p02-receipt.tar.gz`](runtime-bank-layout-followup-2026-11-11/raspberry-pi-p02-receipt.tar.gz), SHA-256
`7637217021ee4919ebc36baacc22aa741d9b8e3112944b3c69998c068d8fd6f4`. nRF52840
P02 also passed 27 checks with the same input-set SHA; its `result.json` SHA-256
is `f7911f700330cdf9338b1bd84129b107e9b8604caf601d197dd9eaba28a36760`, and
its full output archive is
[`nrf52840-p02-receipt.tar.gz`](runtime-bank-layout-followup-2026-11-11/nrf52840-p02-receipt.tar.gz), SHA-256
`a9b03d415e9097aa7261e3aa18b65a47f093dd4ee2e06120cb40ae6aaab1e9da`. Both P02
reports and P05 reports were generated at commit `b25e68e0` on a dirty
worktree using the project-local Swift 6.4 compiler (SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`). The
P05 result JSON includes full input hash maps and command ledgers; each helper
verified its P02 `GiftUI` source input hashes before compiling.

Both results are from revision `e30d82e2bad5aa422f8789b0d745f2cf2dc00e75` on
a dirty worktree. The result archives include the exact command transcripts,
input hashes, compiler outputs, logs, linked executable, and `result.json`;
the report binds the project-local Swift 6.4 compiler SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`. The
recorded 61 input hashes were rechecked against the current worktree with no
mismatches.

Still open: LY-RD-001 runtime-bank differential coverage for the baseline corpus
and both application layouts on all four configurations; LY-RD-002's complete
failed begin/lookup/finish and first-excess cleanup/reuse matrix across the four
configurations; P11 resource/connected dispositions; P12 conformance and
cutover. Pi and nRF P05 results establish cross-compilation and ABI only; they
do not execute the bank assertions on target, and no hardware was used. The two
macOS results execute the focused assertions but do not cover the four-profile
differential or cleanup matrices. No acceptance criterion closes here; T9.1
remains open.
