# Checked State corrective1 — presentation syntax STOP

**Corrections1/2 consumed; initial1/1 consumed. Source unaccepted.** Historical
Native pipeline2/2 stays closed. No retry or later gate ran.

Under reviewed amendment `328092d2`, source changed only by adding `@inlinable`
to existing package `DrawingError.init(accessFailure:)`; its mapping is verbatim.
After formatting, all six fresh matching invocations ran once: macro compile/link,
actual lowering, GiftUI and schema compile PASS; first presentation compile FAIL.
The schema's earlier checked-mapper visibility blocker is resolved in this attempt.

The presentation compiler reports exactly two syntax errors at generated lines72
and76: `consecutive declarations on a line must be separated by ';'`. Both point
to `}@usableFromInline`: the finite lowerer's appended projection/key declarations
lack separating leading trivia after evaluation and after the projection. The
actual generated helper bodies/attributes are unchanged from candidate1. This is
a source-emission separator defect, not evidence of ownership or heap infeasibility.
No presentation module/object exists; private/macro tests, original-wrapper yield,
physical bodies, actual consumer, safety and cold behavior remain unproved.

Read-only emission audit identifies both boundaries: `Lowerer.visit(StructDeclSyntax)`
appends `MemberBlockItemSyntax(decl: helper)` without leading trivia; each
`checkedStateHelpers` template starts at `@usableFromInline` and ends at `}`.
Thus existing evaluation→projection and projection→key concatenate. The Domain
member's earlier insertion already includes a trailing newline; no third helper
or other appended declaration is involved in this actual output. Preserve the
helper AST and add declaration-separating trivia at their append boundary.

Existing macro tests join helper strings with explicit newlines, so they do not
exercise the lowerer's actual member assembly. Existing `lowerGiftUISource` checks
`source.hasError` before rewriting but does not parse-check emitted presentation;
the contract driver's later presentation compile catches this defect. A focused
positive lowerer test that parses actual emitted multi-State/nested presentation
(and asserts no parser diagnostics) would catch all these assembled boundaries
before an expensive provider chain. That test belongs in the already allowlisted
macro test file. No test/assertion or generator is changed after this failure.

The smallest next correction is separating trivia on the already allowlisted
helper emission/append operation, retaining exact parsed helper structure, privacy,
State schema, checked key operation and all existing flags/semantics. No source
fix is applied here. One correction remains; independent disposition precedes it.
No full suite, image, runtime or decoder ran.

`source-boundary.json` records pre-edit HEAD/hash and exact one-line amendment;
`result.json` records all six commands/exits and preservation checks. The immutable
archive contains compiled GiftUI/macro source, generated outputs, compiler argv/raw
logs, fresh successful GiftUI/schema outputs and no-retry provider script. Initial
candidate evidence remains immutable. Offline verifier:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/checked-state-correction1/verify.py
```

Formatting, offline byte verification, governance, local links and whitespace pass.
Five external edits and pycache are preserved. P08/R07/T8.1 remain open.
