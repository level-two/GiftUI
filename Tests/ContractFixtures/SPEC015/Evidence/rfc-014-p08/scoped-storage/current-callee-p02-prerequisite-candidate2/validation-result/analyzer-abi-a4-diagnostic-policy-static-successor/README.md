# P08/P02 A4 diagnostic policy: static successor implementation

Status: **STATIC IMPLEMENTATION PREPARED; UNEXECUTED; NO CAMPAIGN AUTHORITY.**

Prepared 2026-10-18 under the user's bounded authorization to implement the
[reviewed successor proposal](../analyzer-abi-a4-diagnostic-policy-successor-proposal/README.md)
(commit `541a4cb9`). The assigning parent records Astra's classification as a
diagnostic acceptance policy issue, with no source or normative defect. That
classification is supplied review provenance. Independent review of this
implementation and separate authorization to run static checks remain open.

Campaign2's one execution allowance is consumed. Its terminal STOP, A4's
unqualified disposition, source candidate, freezes, outputs, invocation order
and dependent stages are preserved. This sibling has no campaign wrapper,
compiler invocation, build, producer, formatter, test gate or hardware step.

## Existing authority and current scope

SPEC-015 remains `implementing`, its plan active, and P08/R07/T8.1 open. The
existing authority context is accepted ADR-035/036/037 and ADR-039, SPEC-015,
and the approved RFC-014 contract amendments. This is evidence-local policy
maintenance within ITERATION-003 revision 5's runtime-derived analyzer/counter
path and P08's P02 prerequisite. The reference requirement is ITERATION-001's
Signal Analyzer four-configuration stack validation; full RFC-015 delivery
remains ITERATION-004 I4-07. No manifest, lifecycle status, architecture,
contract, source annotation or implementation plan changes here.

The implementation-executor skill's authority and evidence boundaries were
applied to this bounded maintenance step. No new deferred design or expanded
diagnostic dialect is introduced.

## Packet contents and behavior

- `diagnostic_parser.py`: standalone pure parser, importing only `hashlib` and
  `re`. It has no file, process, compiler, campaign, SDK or environment API.
- `policy.json`: the exact literal policy exposed by that parser, extracted
  with AST inspection without importing it.
- `inherited-cases.json`: byte-identical copy of the 22 frozen campaign2 static
  inputs, preserving every original oracle and field.
- `inherited-A4-control.json`: original A4 control object, serialized separately
  for review; the original controls file is untouched.
- `opt-in-control.json`: that A4 control with exact predeclared source paths
  and the narrow `display_only_note` opt-in. Category patterns are unchanged.
- `new-cases.json`: exactly 37 new concrete inputs under the proposal's 24 IDs;
  each contains its complete streams, control, trusted input mapping, context,
  mutation and unexecuted oracle. `fixture-map.md` lists the closed inventory.
- `inputs/`: byte-identical archived A4 source, stdout and stderr. No compiler
  source is generated or edited by the runner.
- `run-static-fixtures.py`: guarded runner importing only the pure parser
  after checking the freeze. It never imports the historical campaign wrapper.
- `invocation.json`: exact future argv, repository cwd, 59 parser calls at
  most, zero compiler/producer/campaign invocations, zero repairs/retries and
  one fresh static result destination.
- `preserved-inventory.json`: SHA-256/length inventory of all 150 existing files
  in the candidate2 subtree before this sibling; identity preservation only.
- `packet-freeze.json`: payload hashes, preserved file identities, source
  identity and exact invocation. It omits itself to avoid a recursive hash.
- `static-inspection.json`: syntax, fixture inventory and byte identity
  inspection results; it contains no classification outcome.

The parser retains exit `type is int` and value exactly 1, scans both complete
streams for existing crash markers before parsing, enforces exact primary and
declared located-note paths, isolates primary/stream evidence, applies every
category pattern independently to every primary and requires whole-token
symbol evidence. For named ABI dependencies it requires every named dependency
to equal the selector, making the proposal's stated invariant explicit (the
historical predicate allowed a matching name among multiple names).

Exact repeats of located diagnostics are processed first. Only the opted-in
macOS Static / negative-A4 / SignalAnalyzerDomain primary at 22:17 with the
exact frozen message can consume the one declared display gutter. An immediate
numbered excerpt at line 1 must match both fixed declaration text and the
SHA-256 verified trusted input bytes. Exact raw gutter spacing and marker are
required. Header, stream, warning/remark, intervening line and gutter boundaries
clear the immediate excerpt context; duplicate display notes stop.

The caller passes `context={profile,module}` and `trusted_input={path,bytes}`
as explicit trusted arguments. Stderr cannot choose a file to read. The opt-in
binds policy ID, exact source path and the policy's immutable source hash.
P01 uses the historical logical cell path with archived bytes; P02 consistently
remaps that logical cell to a fresh path under this packet's `synthetic-cells/`
namespace. Those names are static fixture identities, not materialized compiler
cells, filesystem reads or historical receipt reuse.

Display notes record stream, enclosing primary identity, raw excerpt/gutter,
declared source path, input hash and explicit absence of a located note header
or dependency evidence. They change neither active primary nor source/located
note collections. Only the primary message, its target line and allowed
located notes contribute to the separately exposed `dependency_evidence`.
After ordinary dependency checks, a primary carrying this display note must
have exactly the frozen primary target line as source evidence.

Unknown diagnostic-like error/note/warning/remark lines (including malformed
located headers and unsupported gutters) raise an explicit rejection. Ordinary
numbered excerpt rows and the archived omission row remain display syntax.

## Guarded static runner; invocation remains unexecuted

The only predeclared future invocation is the exact argv array in
`invocation.json`; its script arguments and cwd must match. Python must use
`-B` and no optimization, so assertions remain active and imports create no
bytecode. No execution authorization is conferred by the flag or this file.

Before import, the runner verifies every frozen payload and all 150 preserved
files. It combines the 22 inherited and 37 new inputs, checks the closed
counts/IDs, and calls only the pure parser. Each expected reject must raise
`AssertionError`; other exceptions are unexpected failures. Each expected
accept must satisfy its additional evidence assertions. P01/P02 require one
display-only audit record, empty located notes, only line 22 primary source,
and exact primary message/target-line dependency evidence. P03 requires the
same qualifying evidence with zero display notes. Inherited accepts gain no
display allowance. First unexpected result stops; no repair or retry exists.

Only after all 59 inputs meet their frozen expectations may the runner create
`.build/contracts/p08-a4-diagnostic-policy-static-successor/static-result.json`
with exclusive creation. This fresh output root is for static fixtures only.
It is not a campaign output root and changes no existing campaign roots/order.
No result file exists from this preparation.

## Verification performed and remaining uncertainty

Preparation performed source inspection, `ast.parse` of the two new Python
sources without import/execution, JSON structure/count inspection and SHA-256
identity comparisons. The 22 inherited inputs, archived A4 files, all listed
proposal identities and 150 preserved candidate2 files are unchanged. No
parser import/call, runner, compiler, producer, formatter, test gate, build,
campaign or connected hardware operation ran.

Every fixture expectation remains an oracle, not an observed result. Syntax
inspection cannot establish parser behavior, complete guard behavior or the
correctness of every mutation; independent review and separately authorized
static execution must resolve those uncertainties. Assertion-based rejection
requires an interpreter without optimization; the runner enforces that gate.
The system `python3` binary/version is not frozen as campaign toolchain evidence.

The exact observed form comes only from the archived macOS Static A4 output.
No ARMv6, Embedded, Dynamic, A5–A8 or privacy dialect coverage is inferred.
The complete historical 541-input source freeze is preserved as provenance;
this packet does not requalify its applicability, producers, plugin, SDK,
compiler, target or flags for any new campaign. Source movement requires a
reviewed policy identity change. Static success, if later observed, establishes
only these parser fixture expectations, never compiler/P02/P08, strict-cold,
resource, safety, target, privacy or conformance completion.

A future campaign still requires its own reviewed candidate/source freeze,
complete compiler/SDK/flags/plugin/producer identities, stage inventory,
storage preflight, fresh output roots and explicit new human execution
allowance with STOP at first material failure. Campaign2 cannot resume or be
retroactively marked passed.
