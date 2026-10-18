# P08/P02 A4 diagnostic-policy successor proposal

Status: **PROPOSED, non-authoritative; documentation only.**

Prepared 2026-10-18 from static inspection of the frozen campaign2 packet and
its archived A4 inputs/output. This is an evidence-local maintenance proposal,
not a new lifecycle Proposal, Specification amendment, executable packet,
execution allowance, or campaign2 continuation. It creates no feature or
lifecycle status transition and does not supersede campaign2 evidence.

## Problem and disposition

The [campaign2 result](../analyzer-abi-continuation-campaign2-result/README.md)
is terminal
`STOP_first_material_failure_dependents_unrun_no_retry_zero_repairs`.
The one authorized fresh campaign is consumed: one source candidate, zero
automatic repairs, zero retries. A4 is unqualified; dependent work stays unrun.
The assigning parent reports Astra Medium's disposition: diagnostic-acceptance
policy correction within the P02 prerequisite, with no normative/source defect.
That disposition is supplied review provenance, not a new independent review
or execution authority created by this document.

The frozen [`classify_negative_diagnostics`](../analyzer-abi-continuation-campaign2-preparation/execute-proposal.py)
accepts a diagnostic gutter only when severity and message exactly repeat its
current located primary/note record. A4 has a located primary error, followed
by a same-file declaration excerpt carrying an unlocated declaration note:

```text
SignalPrimitiveValues.swift:22:17: error: type referenced from a '@usableFromInline' property must be '@usableFromInline' or public
 1 | package struct SignalChannelID: Hashable, Sendable {
   |                `- note: type declared here
 2 |     @usableFromInline
 3 |     package let rawValue: Int
   :
20 | package struct SignalTransition: Equatable, Sendable {
21 |     @usableFromInline
22 |     package let channelID: SignalChannelID
   |                 `- error: type referenced from a '@usableFromInline' property must be '@usableFromInline' or public
23 |     package let timestamp: Duration
24 |     package let level: DigitalLevel
```

The complete absolute header and all bytes remain in the
[archived stderr](../analyzer-abi-continuation-campaign2-result/logs/macos-static-negative-A4-SignalAnalyzerDomain.stderr).
The note is not a located diagnostic and is not an exact repeat of the primary.
The parser therefore stopped at its gutter assertion. The exact primary target
line 22 already contains `SignalChannelID`; accepting the declaration excerpt
as dependency evidence is unnecessary.

## Lifecycle and scope

This supports the existing Signal Analyzer four-configuration stack-validation
requirement in ITERATION-001. Current work is the post-MVP ITERATION-003
revision-5 runtime-derived analyzer/counter path, P08's necessary P02
prerequisite. SPEC-015 remains `implementing`, its plan remains active and
P08/R07/T8.1 remain open. Full RFC-015 delivery remains allocated to
ITERATION-004 I4-07.

The manifest continues to identify `giftui-mvp-architecture` and
`external-application-integration`; accepted ADR-035/036/037 and ADR-039,
SPEC-015 and the approved RFC-014 contract amendments supply the existing
authority context. This proposal changes none of those contracts. It needs no
new lifecycle ID or manifest transition. Parent evidence can link this new
sibling without editing the frozen packet/result.

## Exact proposed parser delta

Propose one opt-in **display-only gutter-note form**. No unlocated primary
error becomes acceptable and no new text becomes dependency evidence.

The future successor packet would predeclare this opt-in only for
`macos-static / negative-A4 / SignalAnalyzerDomain`, category
`serialized-ABI-access`, required symbol `SignalChannelID`. It would bind the
following facts before any invocation:

| Fact | Fixed proposed value |
| --- | --- |
| Primary path | Exact resolved `{cell}/inputs/SignalPrimitiveValues.swift` |
| Primary location for this opt-in | `22:17` |
| Primary message | The complete exact error message shown above |
| Primary source evidence | Source line 22, exactly `    package let channelID: SignalChannelID` |
| Declared display excerpt path | Same exact primary path; no path is inferred from a symbol |
| Excerpt location | Line 1 |
| Excerpt text | Exactly `package struct SignalChannelID: Hashable, Sendable {` |
| Following gutter | Exactly `   |                ` plus a backtick plus `- note: type declared here` |
| Occurrence | At most one such display note per primary record |
| Input identity | Exact materialized input SHA-256 from the reviewed source inventory |

The source identity for the archived A4 input is pinned in the
[identity map](identity-map.md). The successor would bind its own materialized
path to the same byte identity. Paths are exact resolved paths from the packet,
never basename, suffix, substring, guessed imported path or diagnostic content.

The recognizer would perform these steps in order:

1. Retain exit `type is int` and value exactly `1`; scan both complete streams
   for all existing crash/fatal markers before accepting any record.
2. Parse located headers exactly as today. A primary starts its own record;
   every primary remains at the declared exact primary file. Located notes
   remain associated only with their preceding primary in the same stream and
   at an exact declared note/primary path. Warnings/remarks clear association.
3. Track the immediately preceding numbered excerpt row as display context
   within the active located record. Any intervening line, new located header,
   warning/remark, stream change or record boundary invalidates that context.
   An excerpt row is not itself dependency evidence unless it meets the
   existing exact primary/note target-line rule.
4. On a diagnostic gutter, first apply the existing exact-repeat rule. If it
   fails, permit only the predeclared A4 display-note form above, with the
   active section still the exact primary and all opt-in identities matching.
   Require the immediate excerpt row to match its predeclared line/text and
   the actual frozen input line. Require the complete gutter bytes, including
   marker and spacing, to match. Reject duplicate display notes.
5. Record the display note separately for audit, retaining stream, enclosing
   primary identity, excerpt row, raw gutter, declared source path and input
   hash. Its lack of a located note header remains explicit; do not fabricate
   a located note, column, source location or dependency relation from it.
6. Consume it without changing `current`/`section` or the primary's existing
   evidence collection. Never append it or line 1 to the record's `notes`,
   primary `source`, or evidence used for symbol matching. Later line 22 and
   the exact error repeat are processed under the existing rules.
7. Apply all current per-primary category and dependency checks. Each primary
   independently matches every fixed `primary_message_patterns_all` pattern;
   any named ABI dependency must match the declared selector. Only that
   primary message, its exact target source line and its own allowed located
   notes/target lines may establish the whole-token required symbol. A4's
   symbol comes from its primary target line 22, not the display note.

For this proposed form, display-row equality against the input is a bounded
identity check, not permission to read arbitrary paths supplied by stderr.
The packet supplies the path/hash and source text. A source-row mismatch stops
even if the symbol is present in another excerpt or display note.

All other unlocated note diagnostics, note messages, marker spellings, paths,
line numbers, columns, compiler dialects, categories and profiles remain outside
the opt-in and stop. Unknown diagnostic-like forms must stop explicitly; the
implementation must not let an unrecognized `note:`/`warning:`/`remark:` or
malformed located header fall through as harmless text. Ordinary excerpt rows
and the demonstrated omission row `   :` remain display syntax; neither can
supply symbol evidence. Exact located repeats continue to work as before.

This avoids a blanket “ignore gutter notes” rule or a search through all output
for the symbol. A valid ABI diagnostic followed by an unrelated error, crash,
unlocated error, orphan note or unfamiliar diagnostic form still stops.

## Bounded static fixture plan

No parser or fixture was executed for this proposal. The future implementation
would freeze the 22 existing
[synthetic cases](../analyzer-abi-continuation-campaign2-preparation/diagnostic-synthetic-cases.json)
as regression inputs with their original expectations, then add exactly the
following 24 cases. Expected outcomes below are proposed oracles, not observed
test results. Each mutation is applied independently to the byte-exact archived
A4 stdout/stderr/input/control identities unless a row specifies otherwise.

| ID | Input or single bounded mutation | Proposed oracle |
| --- | --- | --- |
| A4-P01 | Exact archived A4 pair, exit 1, matching opt-in and source identity | Accept one independently qualified primary plus one display-only note |
| A4-P02 | Consistently remap the one A4 cell root in header/control/input inventory to a fresh successor cell; retain input bytes and opt-in | Same classification; no historical receipt reuse |
| A4-P03 | Remove line 1 and its immediately following display-note gutter; retain line 22 and exact error repeat | Accept by existing primary evidence; display note count zero |
| A4-N01 | Exit 0, 2, -11 or Boolean true (four fixed subcases) | Reject before classification |
| A4-N02 | Append `Stack dump:`, `LLVM ERROR:` or `fatal error: unexpected` (three fixed subcases) | Reject even with exit 1 and expected error |
| A4-N03 | Change located primary file to an undeclared sibling file | Reject wrong primary path |
| A4-N04 | Remove file/line/column from the primary header | Reject unlocated primary |
| A4-N05 | Add a second located unrelated error at the allowed primary file | Reject independently unrelated category |
| A4-N06 | Replace primary message with a different ABI dependency named `OtherChannelID` | Reject different named dependency |
| A4-N07 | Remove `SignalChannelID` from primary target row 22; retain it only in line 1/display note | Reject missing own permitted dependency evidence |
| A4-N08 | Put the symbol only in neighboring line 21 or 23; omit it from row 22 | Reject neighboring excerpt evidence |
| A4-N09 | Put one generic error without symbol before a separately qualifying primary | Reject first record; evidence cannot cross primaries |
| A4-N10 | Put the primary/header in stdout and its excerpt/note/symbol target row in stderr | Reject; no cross-stream association/evidence |
| A4-N11 | Emit the display note before any primary | Reject orphan/unlocated note |
| A4-N12 | Insert a located warning between primary and declaration excerpt/note | Reject lost association |
| A4-N13 | Insert an ordinary line between declaration excerpt and note gutter | Reject non-immediate display context |
| A4-N14 | Change display excerpt line number from 1 to 2 while keeping symbol | Reject wrong predeclared excerpt identity |
| A4-N15 | Change declaration excerpt text or gutter spacing/marker by one byte (two fixed subcases) | Reject unknown form/source row mismatch |
| A4-N16 | Change note message to `type declared elsewhere` or severity to `error` (two fixed subcases) | Reject; no broad note/error allowance |
| A4-N17 | Duplicate the exact display note and its excerpt | Reject repeated opt-in occurrence |
| A4-N18 | Keep diagnostic bytes but omit opt-in, change control ID, change profile, or change input hash (four fixed subcases) | Reject identity mismatch |
| A4-N19 | Change primary line/column to `21:17` or `22:18` (two fixed subcases) | Reject opt-in location mismatch |
| A4-N20 | Append unparsed `note:`, malformed located note header, or unknown `remark:` (three fixed subcases) | Reject unknown diagnostic-like form |
| A4-N21 | Use a located note in an undeclared imported/virtual file after the otherwise valid A4 block | Reject undeclared note path |

There are 24 table cases, 37 concrete new inputs after expanding the listed
finite subcases, plus the 22 preserved historical cases: **59 total static
inputs**. The fixture plan is closed: new forms are findings for review, not
permission to tune a matcher during execution. Acceptance must also inspect
that P01's display note contributes zero text to dependency evidence and that
P03 qualifies without that note.

## Proposed future gate; no authorization here

A possible new campaign would require the following explicit sequence:

1. Human disposition of this exact policy proposal and its scope. If accepted,
   authorize a separate, bounded static implementation/preparation step in a
   new sibling packet. No campaign2 file, source candidate or freeze is edited.
2. Prepare the parser change, metadata opt-in, frozen fixtures, identity map,
   invocation inventory and new output roots in that successor packet. Review
   the actual diff and run only the separately authorized static parser checks;
   archive exact results. Require independent static review to confirm the
   primary/category/dependency invariants and fail-closed unknown-form handling.
3. Identify every execution change separately: new packet/wrapper/control hashes,
   source applicability, compiler/SDK/flags/plugin identity, storage preflight,
   producer identities, total stage/invocation bounds and fresh output roots.
   The eight-selector source candidate can only be reused as explicitly reviewed
   bytes; campaign2 receipts cannot count as new campaign stages. A new source
   freeze must be reviewed if applicability differs; do not silently rebase it.
4. Obtain fresh explicit human campaign authorization naming the reviewed packet,
   candidate, complete stage inventory and one execution allowance, with zero
   automatic repairs/retries and first-material-failure STOP. If the intended
   budget is different, it must be stated explicitly; this document grants none.
5. Only that new authorization could allow a fresh sequential campaign. Do not
   resume campaign2 at A4/A5, reuse its output directories or retroactively mark
   A4 passed. Newly reached unknown output stops and preserves all evidence.

The current proposal performs none of those preparation/execution steps. No
parser import/call, compiler, producer, formatter, repository gate, build,
hardware operation or test was run. Static inspection and identity hashing
support the text only. No source or generated output was edited.

## Uncertainties and current blockers

- This exact note is observed only for the archived macOS Static A4 invocation.
  No ARMv6, Embedded, Dynamic, A5–A8 or privacy diagnostic dialect is inferred.
- The proposed recognizer has no implementation or executed static result.
  Fail-closed handling of malformed/unknown diagnostic-like lines requires
  concrete review, especially because the current parser's generic fallback
  explicitly rejects unlocated errors but does not comprehensively parse every
  note-like string.
- Pinning the display form to line 1, `22:17` and exact bytes is deliberately
  narrow. Any future source or formatting movement requires a reviewed opt-in
  identity change; it does not invite automatic matcher adjustment.
- Successful future static checks would demonstrate parser policy behavior,
  not compiler success or full P02/P08, privacy, target, resource, safety or
  conformance completion. First-use forms and dependent stage outcomes remain
  unknown and retain the campaign STOP boundary.

These are blockers/limits of this candidate, not postponed architecture or
additional work commitments. Wider note dialects and private-initializer
coverage stay outside it; the existing packet's explicit omissions remain
binding. No new valuable deferred design is introduced by this bounded fix.

## References

- [Immutable evidence identity map](identity-map.md)
- [Frozen campaign2 preparation](../analyzer-abi-continuation-campaign2-preparation/README.md)
- [Campaign2 result](../analyzer-abi-continuation-campaign2-result/README.md)
- [Archived A4 source](../analyzer-abi-continuation-campaign2-result/negative-A4-inputs/SignalPrimitiveValues.swift)
- [Existing authoritative context](../../../../../../../../../docs/specs/spec-015-host-configuration.md)
