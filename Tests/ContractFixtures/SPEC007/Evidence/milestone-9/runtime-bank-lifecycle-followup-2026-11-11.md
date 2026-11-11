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

| Profile | P05 result SHA-256 | GiftUI core receipt SHA-256 | Retained archive SHA-256 |
| --- | --- | --- | --- |
| macOS Dynamic | `8171a2048d6005cb167882b3c54cbda3cefb9f2bd4521a68f7cc70a99d1a1bc1` | `308ef6bcdb4c06f180c2545dabe38d511fb5d53b616bfa5abee2263814927292` | `02065b0959fc04ca4ce87f570c76377525f4bba578801a8d59d3eedeb25c6756` |
| macOS Static | `751e29f517d1df395c10154c8048d59705c2e49c845aa6ecd15bcbcd3b12318b` | `6ec4e9ee1a942ce73005a311c22358531ae22949b572b2a192044ff85db00a1d` | `88b600fa4ad71aa57918b2c3acfe6209b665bcc2fd88cbda1df31bb14a14f608` |

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
configurations; fresh Pi and nRF P05 owner routes; P11 resource/connected
dispositions; P12 conformance and cutover. These two macOS P05 results do not
close an acceptance criterion. T9.1 remains open.
