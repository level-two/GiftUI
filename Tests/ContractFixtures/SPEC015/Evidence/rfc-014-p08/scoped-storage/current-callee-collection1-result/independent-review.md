# Independent Strong result review — P08 current-callee collection 1

Reviewed 2026-10-19. Verdict: **PASS for collection evidence only** at commit
`d1117295ed2bdee56f819bac57945de0b5ab202d`. No blocking finding remains within
the [requested review boundary](independent-strong-review-handoff.md).
The evidence supports exactly
`PASS_collection_only_current_callee_interpretation_pending`.

## Method and identities

This independent review read the frozen recipe, controller implementation,
prior controller review, archive, original claims/start/exit receipts, raw
streams, serialized indexes and required-body records. Independent standard
library file/JSON/hash checks and static raw-record comparisons verified the
facts below. Read-only Git queries and Git blob hashes tied the archived bytes
to the reviewed commit. No controller, compiler, build, test, decoder,
demangler, qualification interpreter, counter/schema4/P07, or application
runtime was launched. The inspection code did not import collection code.
Its resulting facts and complete hashes are retained in
[`independent-review-inspection.json`](independent-review-inspection.json).

- All **795 raw files**, totaling **145,304,398 bytes**, match exact archive
  manifest membership, byte counts and SHA-256 values. No raw symlink exists.
  Every raw file also matches its Git blob at the reviewed commit and the live
  original collection. The terminal's pre-terminal inventory matches **794
  files and two directories**; adding `terminal.json` accounts for all 795
  archived files. The archive manifest itself is outside that raw inventory.
- `raw-file-manifest.json`: 140,691 bytes, SHA-256
  `8532be63e94df9f65a4b2eb7cfeb6fd224022c12fa165d29ba08b13b764398fd`.
  `raw/terminal.json`: 680,851 bytes, SHA-256
  `41c38e4ececed6f5cbd91d6eb2387642e316752ff61d7928a7b1633302a8cf2a`.
- The live `.build/contracts/p08-current-callee-collection1` directory retains
  device/inode identity **[16777234, 29640436]**. Launch, detach, worker claim,
  worker start and every stage agree with this identity and the reviewed pins:
  commit `4b33eecc1763867b00d59ccbb843df40ca39fa93`, repository tree
  `903499d41840b626fc10028527631512212cff78`, preparation packet tree
  `851bc71165e472ca98f1fbe6a46c140114bcc6fd`. The latter two Git identities
  resolve from that exact launch commit.

## Collection findings

There are exactly **156 unique stages**, in the recipe's order: 93 privacy
commands, 11 serialized-module captures, one body-index interpretation,
50 object symbol/disassembly captures, and one actual-host SIL command.
There is one claim, start and exit receipt for each stage. Fixed argv,
environments, PIDs, marker/pins and raw stream hashes agree with the terminal
records. All 156 stages have integer actual exits; all stages passed their
applicable collection predicate. The compiler count is exactly **94 actual
`swiftc` exits and 94 claims**, including the sole SIL command. This count does
not describe 94 exit-zero commands: the negative privacy controls must fail
compilation with their prescribed diagnostics.

The **93 privacy classifiers** were independently reapplied to the archived
standard streams, preserving the original expected text or regex and exact
error count. All match: **32 positive controls exit zero with no errors; 61
negative controls exit nonzero with exactly the expected diagnostics**. The
classifier fields match the original qualification packet, and the executed
argv match the frozen collection recipe.

All **11 complete serialized indexes**, containing **4,796 functions**, match
the raw module-dump metadata, identifier/name/hash-bucket inventories,
function-ID coverage, header records, offset lists and basic-block counts.
Every indexed name's hash is correct; each raw prefix at its recorded bit
offset matches the corresponding retained module bytes and header. Those
module hashes match the input freeze. No decoder or demangler was rerun.
All **92 required targets** match the original target list and their complete
index: **91 exact mangled names and one exact recorded demangled identity**.
Each has exactly one match, nonzero serialized kind and at least one basic
block. The recorded interpreter argv, authenticated source bytes and complete
environment also match the frozen recipe. This checks the retained demangled
identity; it does not claim a fresh demangler execution.

All **50 symbol/disassembly commands for 25 matching objects** have actual
exit zero and nonempty captured stdout. Commands and environments match the
recipe, and the retained object input bytes match the frozen hashes. These
are captures of object observations; the archive does not claim to contain
newly built object files.

The single SIL command has actual exit zero, the exact reviewed argv and
**42 ordered source operands**. Its regular nonempty archived output is
**62,139,693 bytes**, SHA-256
`6cc9e7b6cecbeb46dd71b2ac8b6e023182354e7fcc08c814374b9c23303c71ed`,
matching the terminal and live output.

The terminal records **one collection attempt**, **zero source candidates**,
**zero automatic source repairs**, **zero automatic tooling repairs**,
**zero retries**, and an empty termination-request list. The finite stage
inventory and receipts agree; no collection error or manifest error is
recorded. The five preexisting dirty files still match their preservation
hashes. This review did not alter them or the untracked Python cache.

`progress.json` retains the worker's initial `STOP` status and lacks the final
SIL `passed` addition. This is consistent with the reviewed worker's write
order: progress is written inside command execution, before the caller sets
that predicate and final status. Its other retained fields and stage data
agree with the terminal. It is an intermediate snapshot, not a contradictory
terminal failure. No archive repair is needed.

## Next interpretation handoff and remaining gates

Use these frozen receipts, complete indexes, object observations and SIL as
the inputs to independent **complete current-callee and safety
interpretation**. Reconstruct the actual adopted consumer paths, transitive
callees and safety obligations against current source and the retained input
identities. Distinguish ordinary ABI calls, serialized bodies, metadata,
callbacks, ownership/lifetime operations and any unresolved edges. Record the
actual limits and evidence coverage before drawing a cost or safety result.
This review has performed no transitive callee-cost interpretation and grants
no new execution, source, repair or retry allowance. The sole collection
allowance remains consumed; preserve its marker and closed receipts.

Complete independent current-callee and safety interpretation remains required
before strict-cold preparation. `strict_cold_eligible` remains false and
`current_callee_review` remains pending. **P08, R07 and T8.1 remain open**, as
do all still-unmet SO criteria and resource, ABI, zero-heap, four-profile,
conformance and later exit obligations. This packet makes no strict-cold,
allocation, stack, physical-fit, P08-acceptance or lifecycle-approval claim.

The governing SPEC-015 amendment remains **implementing**, under accepted
ADR-039 and the approved/applied scoped-storage contract packet. This is
post-MVP ITERATION-003 P08 evidence for its necessary finite scoped-storage
dependency; the Signal Analyzer's constrained static target and stack/resource
validation explain that dependency. Closed ITERATION-001 gains no commitment.
Full RFC-015 delivery remains allocated to ITERATION-004 I4-07. No new
architectural decision, contract change or deferred-work item is introduced.
