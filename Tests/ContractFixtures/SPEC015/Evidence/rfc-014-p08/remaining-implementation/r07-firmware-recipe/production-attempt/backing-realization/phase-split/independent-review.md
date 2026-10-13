# Independent phase-split result and guard review — 2026-10-13

Reviewed clean6c0f116a/source63e717d1, sequential Sol6.1 High / Strong.
**Accept the narrowed four-route/link result; reject R07/P08 stack fit. Stop
further source variants: this review establishes remaining construction
transfers, but does not establish a specific safe transfer-elimination fix.**
No compiler, test, link, source repair or target execution ran. Read-only trace
used only the preserved linked bodies, outlined routines and current source;
no broader P11 or resource investigation.

The supported image retains ABI/GOT/heap qualification, RAM152320 and
flash299332. Both new helpers are actually called and have local frames4768/
8392. The actual construction closure0x17a48 still saves32 and reserves
58368+248=58648, exceeding27648 by31000 before any overlap. Its reduction
from72208 is meaningful; smaller helpers do not pass the enclosing path.
Graph and host are sequential; do not sum them or infer a complete peak bound.

## Finite remaining-transfer trace

The current source constructs supplied→owner, checks bindings through inout,
then consumes owner through the existing optional preset factory and unwraps
into a mutable full host. The construction closure's linked instructions
corroborate these residual owned-value transfers. Offsets below are relative
to SP after its fixed58616-byte reservation, not absolute RAM addresses:

| Exact current instructions | Observed transfer |
| --- | --- |
| 0x17c8e calls0x160e8;0x17c94 calls0x4178a | Enum-tag-store followed by7284-byte memcpy; outlined0x4178a sets r2=7284 and tail-calls memcpy. Destination r9 is SP31896. |
| 0x17d8e–0x17d94 and outlined0x41760 | r1=SP24+31872=SP31896; r0=SP128+348=SP476; r2=7807. Factory/full-host construction copies the owner-sized block into its host candidate. |
| 0x17d98–0x17d9c and outlined0x416ba | r1=SP128; r0=SP44+23680=SP23724; r2=8155. A further full-host-sized copy precedes lifecycle call0x17dcc. |
| 0x1809c/0x180a4/0x180d4 | The alternate construction arm uses the same outlined transfer routines and then calls the same lifecycle helper. |

The existing state and host source types explain what is being transferred;
no guessed aggregate total is used as evidence. The trace does
not partition every byte of58648 or prove which reservation belongs uniquely
to the optional unwrap, enum state initialization, an owned move, or required
scratch. Removing profile banks from stack and extracting assertions left
this construction materialization intact. This is more specific than another
generic split, but not proof that changing syntax removes it under Swift6.4.

## Guard and next boundary

The exact package rule stops after two consecutive repairs of the same blocker
with **no new passing check or narrowed cause**. This correction passes the
unchanged behavior/lifetime gates, proves the requested helper boundaries in
the linked image and reduces the failed frame by13560. The preceding backing
correction also narrowed root/profile placement. Therefore this packet does
not establish two consecutive unproductive repairs; do not declare that guard
exhausted, reset it, or reopen historical allowances. The dispatched single
phase correction/image allowance is nevertheless consumed. This review grants
no next automatic source correction, image run or optimization variant.

The original user authorization still permits local P08 implementation under
the existing contract. **No new human approval is required merely because a
review dispatch ended.** Missing evidence, rather than a contract conflict,
prevents selecting the next edit here: a concrete source/ownership plan must
identify which of the observed state→owner→optional/full-host transfers it
eliminates and why scoped lifetimes, inout exclusivity, factory validation and
the Static escape/provenance oracle remain unchanged. A consuming optional
switch, another helper or raw in-place host initialization is not already a
validated correction. Do not start a succession of those shapes to discover
one which happens to compile.

Two implementation directions remain possible, neither selected by this
review: eliminate avoidable full-value factory/unwrap intermediates while
preserving the existing factory; or redesign only fixture physical backing
for remaining inline state under the same caller-owned contract. The latter
requires an exact typed lifetime/layout and complete RAM account, and must
never store a nonescapable scoped host in untracked raw/global memory. Existing
disassembly lacks source-variable storage attribution sufficient to choose
between them or promise fit. Preserve that precise unresolved boundary.

A subsequent evidence-supported in-scope proposal may continue under original
authority after explicit independent disposition; it must name exact files,
one mechanism and finite validation, rather than renew this allowance. If it
requires larger stack/heap/RAM, fewer checks/corpus, different ownership/public
behavior/toolchain, or the package's actual two-consecutive condition occurs,
report the concrete options to the maintainer before affected work proceeds.
None of those contract choices is established by this failure alone.

**Recommended next action within existing P08:** collect one unchanged-source
optimized LLVM IR output for the selected `P08CounterRuntime` owner from its
captured current firmware compile command. Prepare an exact argument-array
receipt first: same source/import/macro identities, target, pinned compiler,
Osize/WMO/lifetime/features and C flags; change only output action/artifact paths
to isolated diagnostic IR/module outputs. One compiler invocation, no retries,
source edit, link, target execution or optimization/flag sweep. This is bounded
lowering evidence for the identified transfers, not another source-repair or
image allowance and not a new human gate. If that output action cannot preserve
the captured compilation's semantic settings exactly, stop before execution
with the mismatch; do not improvise another recipe.

The finite output is an ownership/alloca/lifetime table for this one construction
closure and its state/factory/unwrap transfers, correlating IR storage with the
7284/7807/8155-byte linked copies above. It must distinguish named owner/optional
result allocations from backend-only scratch or spills. Then record one
concrete fixture-only construction-flow design, or state precisely why the
output still cannot identify an avoidable allocation. Do not expand into other
modules or a full compiler/P11 study. Independent disposition of that exact
design precedes any source correction or validation; no next edit is selected
by this review. Changes to the actual contract/limits/scope remain the separate
maintainer boundary described above.

No source edits/builds follow this review automatically. Historical helper2/2+B031/1,
GOT diagnostic1/1 and consumed image/backing/phase allowances remain closed.
Mainstack27648, heap0, RAM196608 and flash1048576 unchanged. No hardware/P09–
P12 or current-source Pi image claim. SPEC-015 implementing/plan active;
P08/R07/T8.1/HC-RD-003 remain incomplete.
