# P08 collection setup — focused independent Strong rereview

**Current readiness: PASS for baseline collection after the final parser addendum below.**
The initial focused assessment and its remaining parser finding are preserved here.
Independent Sol 6.1 High review of `f9a8034f` against the
[initial findings](p08-suite-collection-source-review.md) and
[current batch activity](p08-suite-collection-activity.md). Only changed guard
paths and regressions reviewed; no broader redesign, source fix, compiler, suite,
probe, actual runtime or subagent. Parent owns the coherent setup completion.

| Original finding | Focused disposition |
| --- | --- |
| B01: legacy dependencies | Corrected. Current generator/preparation Swift and schema inputs must match `cab1c415`; exact core/runtime/host receipts, compiler, macro and SwiftSyntax identities are pinned. All 19 normalized preparation commands are checked and must succeed before any legacy control import. Historical control commands/source/log hashes and original failed status remain guarded. |
| B02: target claims | Corrected. `target_compilation` removes a copied/stale objects.list, requires all declared preparation checks to pass and every declared object to exist, and reports unavailable evidence otherwise. Driver supplies the explicit preparation object family. No failed/blocked module is described as current compiled evidence. |
| B03: observation drift | Corrected. Schema 2 rejects old schema-1 focused receipts. Observations now use finite helper-owned oracle data, prerequisites/evidence identity, verified log content and changed-family selection; unselected failures cannot upgrade. Runtime-summary belongs to runtime. Exact single-occurrence labels and positive-count/zero-failure summary criteria remain. |

**Remaining parser issue:** `p08_check_collection.py:39–41` compares all textual
`error:` occurrences to parsed primary error headers. The
[preserved actual closure-negative log](compiler-compatibility2-counter/controls/so06-erasure-static-generic-active-host-closure-negative.log)
has **two** filename:line:column primary errors and **four** occurrences, because
Swift's rendered source gutters repeat `| ... error:` for each message. An exact
structured oracle for the intended borrowed-consumption/lifetime-escape messages
at the generated probe site therefore returns False. The original tuple matcher
is unchanged, so this does not reclassify the historical 192nd failure; it blocks
the intended later structured correction when applied to real rendered output.

The same setup bundle should distinguish primary diagnostic headers from their
rendered gutter/source annotations. Preserve strict rejection of additional real
or unlocated errors, trusted-prefix/wrong-site errors, crashes and invalid exits;
do not simply remove error validation or accept arbitrary nonzero compilation.
Add a regression using the actual rendered two-error/gutter pattern alongside
the existing unexpected-error/crash tests. This is a local parser fix, not a
contract/matrix reduction or another per-barrier user approval.

Checks: **20 compiler-free tests pass**, shell syntax and scoped whitespace pass.
The extra read-only matcher reproduction confirms the real log's 2-header/4-text
mismatch; it uses a representative nonzero exit class, not an invented historical
numeric compiler exit. No actual compiler or suite invocation was consumed here.

This is productive setup progress. Current grouped cycle **1/2 consumed** remains
the same coherent pre-run bundle; cycle 2 remains available for grouped collected
suite fixes under the existing authorization. Complete this parser fix and its
focused assessment, then proceed to baseline collection without another user
permission stop. Historical budgets/guard, all nine SO criteria, P08/fit and
separate target/hardware/timing/lifecycle obligations remain unchanged/open.
Only this compact review document is committed.

## Final parser addendum — `b592c31d`

Independent Strong narrow assessment closes the remaining parser finding.
The parser recognizes primary diagnostic headers, ignores numbered source
gutters only within a rendered diagnostic block, and permits repeated error
annotations only when their message exactly matches the associated primary
error. Unrecognized/unpaired error lines still reject. Site/message alternatives,
prefix/wrong-file errors, additional real errors, crashes and invalid exit checks
remain; the legacy tuple branch is unchanged.

**22 compiler-free tests pass**, including the exact preserved two-primary/
four-rendered-error closure log and mutations for wrong site/file/message,
unexpected/unlocated errors, unpaired gutters and crash/exit cases. The intended
structured oracle accepts that real log, while baseline `('escaping',)` still
rejects it. No compiler, suite, probe, source fix or subagent in this assessment.

B01–B03 remain closed. The coherent productive setup cycle is still **1/2
consumed**, with no baseline invocation yet; cycle 2 remains for grouped
collected-suite fixes. Proceed with the existing authorized baseline collection,
preserving known matcher failures and complete coverage, without another user
permission stop. This PASS establishes harness readiness only; P08/SO/runtime/
target/resource/fit acceptance remains open. Only this review addendum changes.
