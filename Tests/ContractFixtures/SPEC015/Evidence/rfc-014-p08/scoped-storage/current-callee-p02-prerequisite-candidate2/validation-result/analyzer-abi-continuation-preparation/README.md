# Analyzer ABI continuation: static execution proposal

Prepared 2026-10-18 from `03df67669f458b75664154b61cc3179416663820`.
Static correction after independent Strong review of `7b940c93`: A4 now fails
first in Domain; private-init is explicitly omitted; an exact guarded wrapper
and four fresh macro stages replace unresolved wrapper/reuse choices.
**PREPARATION ONLY / STOP. No source or validation allowance is granted.**
Candidate 2 remains candidate 1/1 consumed, run 1/1 consumed, repairs 0/0.
This packet proposes one separate eight-selector candidate and one sequential
campaign, each listed cell once, zero retries and zero automatic repairs.
Historical allowances and stops remain closed.

The [inventory](../analyzer-abi-inventory-proposal.md) describes the dependency
closure; the [failed receipt](../README.md) and immutable diagnostic establish
only the existing AnalyzerSchema failure. The assigning request reports Astra
Medium and Strong agreement that the exact eight annotations preserve the P02
contract. That review agreement supplies no execution authority. Neither source
compatibility nor any fresh compiler result is claimed by this packet.

## Authority and current scope

This is P02 prerequisite preparation inside unfinished P08 under approved
ITERATION-003 revision 5 I3-04/I3-05. ITERATION-001 established the shared analyzer
presentation across four stacks; this work is post-MVP. SPEC-006, SPEC-010 and
SPEC-015 remain `implementing`, their owner plans active; ADR-036 is accepted.
Consulted: AGENTS.md, implementation-executor, deferred-work-curator, lifecycle,
AI/documentation/implementation rules, iteration scopes, CODE_STYLE, the feature
manifest, SPEC-006 compiled View/DV-RD-001, SPEC-010 model-read/ownership,
SPEC-015 HC-RD-001–004/HC-SO-001–003, ADR-036, current shared plan/task context,
and candidate 2's frozen runner and recipe.

The eight eligibility annotations preserve package access, authored expressions,
synthesized equality, inferred Body, typed indexed failure and all four enum
cases, including `.failed(SignalAnalyzerDiagnostic)`. Private diagnostic storage,
count, storage type, initializer and helpers stay private. No `@frozen`, new
`@inlinable`, public access, rewritten getter/equality, generated patch, lowerer
change, constructor change or ninth selector belongs to this candidate.

No lifecycle artifact or status is created or changed. Current uncertainty is
required for this prerequisite and stays visible below; no new optional deferred
work was identified. P09–P12, I4-07, strict cold, linked images, resource proof,
current-callee attribution, hardware, deployment and conformance remain open.

## Packet contents

- `selectors.json`: eight unique source anchors, baseline line/hash and proposed
  attribute insertion; four baseline and proposed **preformat** content hashes.
- `scratch-sources.json`: exact UTF-8 source texts/hashes stored as JSON data.
  It creates no maintained or generated Swift source. Positive Domain/probe texts
  contain exactly the proposed attributes. Eight ABI twins each remove one.
- `controls.json`: 20 controls per profile: three positives, eight ABI negatives,
  five same-package privacy negatives and four outside-package negatives. Semantic
  expected categories are fixed now. Nonzero status alone never passes a negative.
- `recipe.json`: exact registered command argv, compiler/flag arrays, module and
  cell order, lowering/link/readelf argv, output roots, deterministic token
  expansion, dependency conditions and execution preconditions.
- `execute-proposal.py`: exact proposed execution/receipt wrapper. Its only
  invocation requires `--execute-newly-authorized-campaign` and an absolute
  separately reviewed postformat freeze. It has only been parsed statically.
- `macro-stages.json`, `macro-outputs.json`, `macro-objects.txt`: four fresh macro
  stages with exact argv and output metadata, mechanically relocated from the
  prior working recipe. No historical macro test PASS is reused.
- `baseline-inputs.json`: current hashes of candidate 2's 529-input inventory and
  recipe/policy references. It is a **baseline**, not a post-source execution
  freeze; four changed source hashes must be separately frozen after authorized
  edits and formatting. Never change historical candidate 2 freezes.
- `provenance.json`: baseline HEAD/dirty state, prior failure/runner hashes and
  read-only compiler identities. Dirty TargetHost/CMake/build scripts and existing
  pycache are excluded from edits; their presence is recorded honestly. Any of
  those files used transitively by a producer remains an input requiring identity.
- `static-validation.json` and `packet-hashes.json`: static checks and packet
  byte identities. These do not constitute compile, runtime or conformance proof.

All paths and argv are repository-relative unless absolute in JSON. Brace tokens
are typed recipe substitutions, never shell expansion or literal compiler flags.
The proposed guarded execution entrypoint is frozen, not invoked. No new
registered test driver is installed; the packet wrapper orchestrates the existing
registered producers and its predeclared scratch controls.

## Execution order proposed for authorization

Before edits: approve the exact recipe and new allowance, confirm baseline inputs
and compiler hashes, and assert every output path absent. The proposed allowance
now explicitly includes the SDK identity preflight, four fresh macro stages,
four P02/P04 profile routes, 20 scratch controls per profile (80 total), and the
three dependent native stages, each listed invocation once. Repairs and retries
remain zero. `recipe.json` records B01–B03 as resolved preparation dispositions;
B04–B06 remain explicit execution preconditions and first-use uncertainties.

The exact wrapper is `execute-proposal.py`; it requires the reviewed postformat
freeze to have exactly the baseline path set and permits only the four selected
source hashes to differ. It independently checks exact fixture bytes and
formatting-only whitespace differences in the three maintained candidate files.
It records and hashes that external freeze before any compiler stage. The wrapper
never edits those sources or formats them.

The fresh macro compile, link, test-link and 19-method test stages precede the
first P02 route. `macro-stages.json` fixes the commands and native runner
environment, with new output locations. `macro-outputs.json` and
`macro-objects.txt` fix the output map and link list. Every other argument is
identical to candidate 2's working command shape. The old PASS is provenance
only. Maintained P02 still performs its normal macro target build/fixtures.
After authorization: add only the eight attributes; compare every source against
`selectors.json`; format exactly the three maintained Domain files with the
`formatting_argv` in `recipe.json`. This invokes the selected local toolchain's
`swift format` with the checked-in policy. `scripts/format-swift.sh` has no file
selector and would enumerate unrelated dirty sources, so it cannot safely be
used as-is for this restriction. Its equivalent restricted invocation is explicitly
proposed for approval. Never format the fixture, generated output, TargetHost,
or any other file. Freeze and review formatting-only deltas separately, then
freeze the full postformat candidate/input/compiler/recipe set before compiler
execution. Unexpected nonformat source changes stop before validation.

Serialize all campaign stages under `scripts/lib/serialize-validation.rb`;
inherit its lock owner for nested registered drivers. Set
`PYTHONDONTWRITEBYTECODE=1`. Run profiles **macos-static → raspberry-pi-armv6 →
nrf52840-embedded → macos-dynamic**, every later cell conditional on complete
prior PASS. Per profile, invoke registered `run-spec-006.sh --profile PROFILE
--compiler-baseline rfc-014` exactly once, including registered P04, qualify its
fresh receipts, then execute the frozen scratch positives and negatives in the
listed order. Stop at first material failure, including unexpected negative
acceptance, incorrect diagnostic category, or a missing positive twin.

Scratch positives compile the real copied Domain, actual separately generated
AnalyzerSchema, AnalyzerPresentation and unchanged DeclarationHost. The real
macro's `--lower-source` argv and module source ordering are fixed in the recipe.
Fresh P02 supplies GiftUI and Counter dependencies through verified same-profile
receipts. Each ABI negative uses its own source/module/cache directory and runs
Domain → lowerer → schema → presentation until its declared first diagnostic;
this is not a source repair or a generated-output patch. Privacy negatives compile
against the successful scratch Domain; outside-package negatives remove only the
`-package-name giftui` flag pair. No negative module may overwrite a positive.

On macOS, both the maintained P02 declarations and scratch declarations must
print `checks=120 failures=0`; the 18-check semantic positive must print
`analyzer-abi semantics=18 failures=0`. The existing oracle retains index-0 three
primitives, index-1 failure before traversal and count-0 two primitives. The
additional semantics preserve all acquisition cases, equal/different failed
payloads, transition channel/time/level equality and normal package constructors.

ARMv6 and Embedded cells compile their same-profile sources and inspect actual
objects: ARMv6/v6 and VFP registers, or armv7em/v7E-M and VFP registers. Native
macOS execution never supplies target runtime evidence. Cross-target Semantics
is compiled only; Main is neither linked nor executed. No target runtime,
firmware, hardware, heap or resource conclusion follows from these objects.

Only after all four P02/P04 and scratch cells pass, run the three dependent
macOS Static argv from candidate 2's working command shapes, once each:
P07 with the **new** Static core receipt → schema-4 with `--activation-join` →
complete counter with `--collect-failures`. Schema-4 includes registered activation
negatives. Counter must be a complete collection of 384 unique planned controls,
passed with `fresh_focused` false; no resume/selection/import shortcut. Retain the
collector's independent-control policy and dependent blocking inside that one
invocation; campaign dependencies remain unrun after a failed stage.

## Receipt provenance and output rules

Each stage records exact argv/environment, monotonic duration, start/end times,
actual exit, raw stdout/stderr and their SHA-256. Producer directories are
fresh driver-created paths, discovered from exactly one matching stdout record;
never infer a path from a latest pointer. Copy the resulting immutable receipt
and relevant diagnostics into the campaign's result archive with original path,
size and SHA-256. Never overwrite this preparation or candidate 2's STOP archive.

`recipe.json` fixes stdout/stderr paths. Registered drivers select unique output
suffixes beneath `.build/contracts`, `.build/raspberry-pi/contracts`, or
`.build/nrf52840/contracts` as implemented. Scratch roots use the corresponding
profile-specific root in `output_roots`. Driver-created paths remain dynamic
until discovered; that is producer behavior, not an unresolved guessed pathname.

The wrapper freezes source locations and semantic diagnostic regexes for each
negative. A4 targets `SignalPrimitiveValues.swift` during Domain compilation;
A6 targets the associated payload use in `AcquisitionState.swift`. The removed
private-initializer test is excluded from sources, invocation count and privacy
claims. Private-initializer negative coverage remains unproved; any future
addition needs a separate reviewed source/matcher and allowance.

Before accepting a receipt, require its mtime at/after that stage start, real
path under the appropriate `.build` root, expected package/profile, all source
input hashes equal the postformat freeze, compiler identity/flag identity, and
all artifact hashes. No path traversal or symlink escape is accepted. Require
all recorded checks to pass; expected failures must retain nonzero statuses and
the declared diagnostic. Reject absent/incomplete receipts, contradictory logs,
duplicate discovery or stale artifacts. Hash and verify every scratch input,
generated artifact, module and transitive imported dependency.

P02 qualification must include AnalyzerPresentation source/object,
DeclarationHost object, native-execution or target-abi and the complete declaration
and privacy negatives. P04's `core_receipt_sha256` must equal its same-profile
P02 receipt. P07's core hash must equal the new macOS Static receipt. Schema-4's
runtime hash must equal that P07 receipt and include activation-join/copy/callback/
constant-callback/backing/execute. Counter must identify that same runtime and
host, have `collection_complete`/`passed` true, `fresh_focused` false and exactly
384 distinct planned labels. Verify all checks, not merely those named examples.

P07, schema-4 and counter retain the baseline driver provenance and source
applicability rules. Never manually edit their receipts or generated outputs to
make a mismatch pass. A newly reached unrelated diagnostic freezes the complete
stage log/source/module/input inventory and leaves dependent stages unrun.

## Boundaries requiring a disposition before execution

B01 is resolved by the frozen guarded wrapper, whose lock, source materialization,
argv expansion, stage stops, diagnostics, freshness, receipt discovery/hash joins
and result writes are reviewable in `execute-proposal.py`. It is not claimed to
have executed successfully. B02 is resolved by explicitly omitting the one
unsettled private-initializer negative, leaving 20 declared controls per profile.
B03 is resolved by the four explicit fresh macro stages; their new execution
allowance remains ungranted. No historical PASS qualification is asserted.

B04 pins the SDK to the prior working transcript and verifies discovery before
a compiler. B05 proposes restricted formatting for the exact three maintained
files. B06 preserves first-use compiler/source/diagnostic uncertainty. The
prepared sources and matchers are immutable for the proposed campaign; an
unexpected error, unexpected acceptance, wrong stage or source location stops.
The wrapper has been syntax/structure checked only; no compiler run was used to
invent or tune this correction.

No automatic ninth selector, extra enum/helper visibility, alternate compiler,
flag, source variant, diagnostic reclassification, setup retry, lowerer repair,
new package or generated patch is allowed. Preserve material failures and return
for review. Static validation grants no execution allowance or P08 acceptance.
