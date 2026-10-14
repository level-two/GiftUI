# SO-03 correction-2 independent Strong review — 2026-10-14

Reviewed clean outcome `bb2029a7`, helper source/clean native entry `ef46dd4b`
and preceding review `7531e5c3`. Sequential independent Strong task
`p08_so03_helper_review`, C3/R3, inherits its parent configuration without a
model/reasoning substitution or subagent. The shared receipt records dispatch
before review inspection and documentation changes.

**PASS for exact helper scope, frozen evidence and the 42 native compiler
oracles. BLOCKED for SO-03 runtime acceptance: the sole execute exits -5 with
empty output; its cause and location are not established.** No source/driver
edit, compiler/test/build/probe, executable/debugger rerun, new experimental
artifact, repair, target/image or hardware action ran during this review.

## Authority and exact correction

Accepted [ADR-039](../../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
[S11.1–4](../../../../../../../../docs/specs/spec-011-interaction.md#s111-scoped-storage-and-state-declarations)
and [S13.1](../../../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
govern. The [SO-03 packet](../../so02-execution-proposal.md),
[physical design](../../../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md),
[task context](../../../../../../../../docs/iterations/iteration-003-review/rfc-014-task-context.md)
and shared/owner active plans are derived records. Specifications 011/013/015
remain implementing. ITERATION-003 I3-04/I3-05 requires finite-counter/runtime
derivation and four-stack resource validation, preserving closed ITERATION-001
analyzer/stack controls. Mandatory full RFC-015/analyzer integration belongs to
ITERATION-004 I4-07 with the separate P09 integration handoff.

The [source diff](source.diff) exactly matches the preceding review's
[helper proposal](../correction-1/independent-review.md#guard-disposition-and-smallest-proposed-handoff).
Only ScopedStorageProbe.swift changes: private so03InitialCount consumes the
same five independent scoped inputs, calls unchanged so03Union, consumes its
actual failable Optional, traps on none and reads committedRecordCount inside
the helper, returning only owned UInt16. The caller passes five temporary
mutableSpan accesses in the same expression and preserves the zero-count
assertion. It does not return scoped state or substitute common-session inputs.

so03Union/so03GenericUnion, all lifetime annotations, ten direct/generic
positive/omitted-input pairs, scoped-copy rejection, owned Optional copy/return,
move/failable-none controls and all 27 focused labels are unchanged. Both
initializer-only exchange traps remain unreachable from the real-operation
family by source construction. The closed actual-owner/token/private-descriptor
session, paired complete-role exchanges, typed reservation borrows and reset
defer are unchanged. All accepted/refused/generation/root/Canvas/gesture and
retained-owned assertions remain. There is no no-op exchange, disabled
exclusivity, lifetime erasure, public/arbitrary-conformer factory, mutable
capability copy or production/driver change in this correction. Compiler
acceptance now covers the finite fixture; production owner/full carrier,
cleanup/exclusivity and resource conformance are not supplied by that fact.

## Independent frozen-evidence verification

Read-only recomputation matches **122 source-freeze inputs, 128 driver inputs,
24 unaffected pins, 130 output artifact hashes/sizes and 84 historical evidence
files**. The compiler, macro tool, reused core receipt/GiftUI artifacts agree
with their pinned identities. Comparing the preceding driver's 128 inputs
finds exactly the authorized fixture change. Current source/driver bytes remain
frozen at `ef46dd4b`; the zero-context Git diff equals source.diff byte-for-byte.
Historical attempts, reviews and their receipts remain untouched.

All **43 planned argv, labels, expected causes and diagnostic contexts** match
the precompiler plan after only substituting the fresh immutable output
directory. The attempted command list equals the entire plan, once and in
order. Main.swift equals the precompiler bytes. All **63 retained text outputs**
match their immutable output counterparts byte-for-byte, including the raw
invocation output; binary modules/objects/executable stay in the original
output directory and match the artifact manifest. Raw logs are not normalized.

The [process receipt](attempt-1/invocation-process.json),
[invocation receipt](attempt-1/invocation.json), [result](attempt-1/result.json)
and raw logs agree: one driver invocation, exit **1**, **42 compiler cells
meeting their exact oracles**: **30 zero-exit compilations/link and 12 intended
negative rejections**. Independently rechecking every error occurrence and
required diagnostic context confirms the negatives reject only for the
registered ownership/lifetime causes. There are **27 focused cells: 15
positives and 12 negatives**. Prerequisites, real consumer source modules,
OwnedKeyProbe, the existing 14-value layout IR and link pass. Compared with
the preceding run's 13 passing compiler cells, OwnedKeyProbe, all 27 focused
cells and link are **29 newly passing compiler/oracle checks**. This is native
macOS Dynamic evidence for these exact inputs, not four-profile conformance.

## Runtime stop and limits of diagnosis

The only execute check is **-5 (signal 5)**, with zero-byte combined
[stdout/stderr](attempt-1/execute.log); result.execution is null. The
[driver](../../../../../../../../scripts/contracts/check-spec-011-owned-keys.py)
captures stdout/stderr and stops at that failed check. Its Python traceback
identifies the failed execute cell, not a Swift assertion or instruction.
The linked executable is the pinned **2,215,848-byte** `interaction`, SHA-256
`58eaf79ee44ae030de2c51ddfb1c23650337da05dc70f9a930f34b7b0aca8a48`.

Main calls giftuiP05Interaction, giftuiP03Root and giftuiSO03ScopedStorage before
its sole completion print. Those families include preconditions/forced
unwraps and nested helpers; no stage marker, trap PC, stack trace or runtime
diagnostic was retained. Therefore missing output cannot establish entry into
the new helper, the common session or any particular assertion. The helper's
none branch, session checks/exchange, old Interaction/root checks, runtime
exclusivity or a compiler/runtime defect cannot be selected as the cause from
this record. Source inspection supplies no uniquely established failing path.
Signal 5 alone does not prove a source precondition, a compiler bug, an
environment problem or an approved-contract defect. No upstream contract change
is justified by this unexplained stop; an implementation cause is also unproved.

All runtime assertions remain executable source, but no completion/count or
individual runtime acceptance follows. The two legacy analyzer factories remain
unchanged and unresolved under the recorded applicability disposition. Counter/
Cycle full graphs, physical fit, four-profile compatibility and target execution
are not established by the successful focused compilation or link.

## Guard disposition and smallest proposed next observation

This is **productive correction 2**, because it yields 29 new passing checks
and removes the preceding initializer lifetime rejection. It does not establish
two consecutive unproductive repairs. The new runtime stop remains unresolved;
it is not a second repair attempt or grounds to invent a cumulative 0/2 budget.
The historical helper **2/2**, B03 **1/1**, GOT/image/backing/phase/IR allowances
and SPIKE-075's seven closed experiments stay closed, with no reset. Original,
correction-1 and correction-2 native allowances each remain **1/1 consumed,
0 remaining**; total fixture corrections **2**, automatic follow-up repairs **0**.
Productive classification supplies no additional source/compiler/run authority.

**Proposed only, NOT AUTHORIZED:** one bounded diagnostic launch under the
existing native debugger of the exact frozen executable above, with unchanged
inputs/source/flags and hashes checked before and after. Launch **once**, halt
at the first trap/failure, retain raw stop reason, all-thread backtrace, PC,
loaded-image identity/address mapping and a small instruction window around PC;
then terminate without continuing/relaunching. No compiler, rebuild, source or
driver edit, probe, repair, repository suite, target/image or hardware action.
If debugger launch is unavailable, no failure occurs, or optimized frames cannot
identify the cause, record that exact inconclusive outcome and stop; no fallback
or second launch. Freeze the diagnostic and obtain separate independent Strong
review before proposing any repair. This obtains the missing failure location
without guessing a source correction or recompiling the already passing matrix.
It would be a new explicit one-launch diagnostic allowance, never a reset of
the consumed native-driver/repair budgets. Remaining stopped is also valid.

Concrete prospective command, from the repository root; **not run by this review**:

```sh
/usr/bin/xcrun lldb --batch \
  -o 'settings set auto-confirm true' \
  -o 'process launch' \
  -k 'process status' \
  -k 'thread backtrace -c 32 all' \
  -k 'register read pc' \
  -k 'image list -o -f' \
  -k 'image lookup -a $pc' \
  -k 'disassemble --pc --count 16' \
  -k 'process kill' \
  -- .build/contracts/spec-011-owned-keys/tmpiggjdqn4/macos-dynamic/interaction
```

The batch has exactly one process-launch command and no continue/restart. The
on-crash commands observe the first abnormal stop, bound backtraces to 32 frames
per thread and disassembly to 16 instructions, then terminate the stopped process.
Preserve full raw debugger/stdout/stderr and exit status in a fresh diagnostic
receipt outside the immutable native-output directory; do not overwrite it. An
unavailable debugger, denied launch, clean exit, non-crash stop or absent crash
details is an inconclusive stopped result, never permission to relaunch or add
instrumentation. Verify the executable hash/size above plus the existing 122/128
source/input manifests and 24 unaffected pins before and after; record debugger
identity without a preliminary target launch. Address mapping is diagnostic
evidence, not permission to weaken an assertion or claim runtime acceptance.

All nine SO criteria, HC-RD-003/P08/R07/T8.1 and the **58,648 versus 27,648 stack
failure** remain open. SO-04–09 stay proposed/unapproved. I4-07 integration/owned
returns and separate P09/P10–P12, hardware and timing obligations persist. The
runtime stop is a required current-path blocker and is not deferred; no new
Future Work/Exploration/Spike, manifest/status or authority change is needed.
Documentation checks and the separate review commit are recorded in the shared
receipt. No action follows from this proposal without new maintainer authority.
