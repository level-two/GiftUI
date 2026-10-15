# P08 finite layout proof, measured sizing and resource validation

Eugene explicitly approved “Please proceed” to finite literal-proof support,
measured reservation completion, and complete stack/current linked-memory evidence
before a budget decision. Entry is `6e61eef3`. The narrow predicate fix1/1 and
rerun1/1, prior control-resident2/2 and all older allowances remain closed.

This new package permits one initial tooling/sizing pass and at most two grouped
tooling/sizing corrective cycles, stopping after two unproductive cycles or a real
contract/resource decision. Current measured sizing passes; resource preflight
rejects this realization. Corrections remain 0/2; no budget is reset.
[Current result](p08-measured-sizing-stack-preflight-result.md) preserves 25 selected
passes / 202 not-run, strict current layout and required stack lower bound 71,088.
Backing 138,880 plus that stack is 209,968 > RAM ceiling 196,608 before omitted
costs. Independent result review precedes cancellation of costly full controls/image
for this source; affected resource work stops at the genuine realization/contract
boundary. Unused tooling/sizing corrections do not authorize a source optimization
or resource-limit change. No current linked image or complete upper bound claimed.

Historical sizing source boundary:
[Sizing freeze](p08-layout-measured-sizing-source-freeze.md) records exact Swift/C
34,720-byte slots / 138,880 four-slot charge and fresh component qualification.
[Independent sizing source review](p08-layout-measured-sizing-independent-source-review.md)
PASS at `5e463e50`; fresh focused current-module/layout verification is next.
No current-source compilation or accepted layout is yet claimed.
[Source freeze](p08-layout-literal-tool-source-freeze.md) records the exact finite
proof and 50 passing compiler-free layout tests. [Independent source review](p08-layout-literal-tool-independent-source-review.md)
PASS preceded the completed same-object read: all 129 facts strictly decoded,
then old 32,000 reservation bounds failed truthfully. Raw facts remain diagnostic
and unvalidated. No compiler/build/runtime/image ran during tooling/sizing edits.
It authorizes no new representation/optimization variant, resource limit, ownership,
workload, capacity, core contract, compiler flag/toolchain or hardware change.

First: implement only exact eight-byte Thumb `LDR r0,[PC,#0]; BX LR; inline UInt32`
proof with alignment/bounds/relocation/ownership checks and finite compiler-free
regressions. Independent source review precedes use on the same recorded object.
No compiler/build/runtime/image invocation is authorized in this first source step.

Then: reviewed read-only extraction must retain actual facts and truthfully fail
old32000 reservation validation. Exact measured Swift/C34720 slot spacing and
138880 four-slot charge require a separate source freeze/applicability proof and
independent review before affected rebuilding. No guessed extent or decoder bypass.

Complete actual main/IRQ path bounds and current linked-memory accounting are
required before any budget decision. First use existing object evidence; stop
expensive follow-up if a required path conclusively cannot fit feasible RAM.
Registered full current nRF controls precede any current image under the existing
image guard. Native/Pi validation is selected by actual impact; unchanged full
matrices are not rerun solely for bookkeeping. Partial receipts cannot establish
complete acceptance. P08/R07/T8.1/HC-RD-003 remain blocked;27648 remains the baseline.

The [prior result](p08-control-resident-predicate-measurement-result.md) remains
immutable:128 strict roots plus one diagnostic literal, required stack lower
bound34560, no complete upper bound/current image. Existing input object is
`p08-counter-ap7tbjem/P08CounterRuntime.o`, SHA-256
`15ac2dea6836ec4c161903a4f98a65851bffe00fd4f2c000da284236d1f1ad59`.
No prior failed extraction is relabeled. Known generated pycache remains unrelated.
