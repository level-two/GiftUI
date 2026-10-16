# P08 constructor/caller — independent result and correction 1 approach review

**Current main-stack resource FAIL confirmed; correction 1 APPROACH PASS.**
Reviewed result/proposal `c7160f71`, source `8bd6c784`, SOURCE review `327f6f6d`.
The proposed correction is a private realization within the existing contract and
is ready for the already authorized source pass. It is not SOURCE PASS or a fit
prediction. Initial 1, corrections 0/2; older allowances remain closed.

The [current result](p08-constructor-caller-initial-result.md),
[receipt manifest](constructor-caller-initial-collections/result.json) and
[analysis manifest](constructor-caller-initial-analysis-manifest.json) accurately
separate functional success from resource rejection. The exact object hash is
`4c2bdc4a294a2315ac3b8cf7e0715b76ba60009576d00c649bbf2732bc66f66c`.
Independent read verification confirms receipt/source identities and partial
flags, all 139 collection and 85 analysis member hashes, and the current object.
nRF passes 25 with 202 not run; each Native route passes 42 with 384 not run.
Native assertions total 3,472,564 with zero failures. Actual metadata extent
16,584 plus donor tail 18,136 equals 34,720; all four slots remain charged 138,880.
No current image, full acceptance or total-RAM failure is established.

The sixteen selected fixed frames sum to **32,800**, exceeding main stack 27,648
by **5,152**. Actual ELF section/symbol-table indices, raw prologue halfwords
(including SUBW), thirteen direct BL relocation sites and seven callback
connections independently agree with the selected path. In particular, the
4025 model-lender call uses the callback targeting 12072→12076→4033, semantic
continues through 12363→4040, and the scoped closure through 12367→4044. The
original canvas and fourteen bank loans intervene; their omitted frames are
additional. The second-host early-0 path reaches old-origin sensitivity and its
first unchanged baseline match, then admission matching after earlier predicates
succeed. These callers retain their fixed frames until those BL calls return;
later comparisons, current controls and teardown still follow. No alternative
4029 or returned preparation/installer/join/factory frame is summed. The selected
cold 27,400 subset does not independently reject the candidate. This proves a
necessary failing subset, not a complete peak or IRQ upper bound, and justifies
holding full 202 controls and image work for this rejected realization.

One evidence-description erratum is material to reproducibility, not the verdict:
the three callback literals at 4025+608, 4033+540 and 4040+308 are **R_ARM_REL32
(type 3)**, not the `R_ARM_ABS32` labels in immutable `required-live-path.json`.
Their actual section/index-resolved targets match; the archived complete bodies
show PC-relative load/add formation. The immutable packet is retained unchanged.

The proposed private `P08HostRunFacts: ~Copyable` retains only the same owned
limits/audit/assembly fields. The pinned Swift 6.4 interface hash and exact
excerpt independently match: Optional accepts noncopyable values and its nil
comparisons borrow and switch on the actual tag. Thus existing vacant/installed/
destructor checks can retain their exact predicates without an invented state
bit. Nil assignment and destruction may still require physical temporary homes.
The observed 818-byte copy and second nil home at SP+820 are actual materialization
evidence, not proof of the saving this change will produce.

Passing the same actual inout plan through the original synchronous callbacks
and scoped construction seams removes only fixture by-value crossings. Individual
complete audit/report/assembly values must still be copied where core APIs own
them. Since those fields are owned, the cold returned host can retain the exact
original session/semantic/values/models/root/control/activation lifetime union
without depending on the plan loan. No plan reference, callback or scoped view
may enter that host; the constructor must not erase a genuine dependency merely
to omit facts from its annotation. Small completion/join facts remain owned.

The cold split preserves early 1 reset, early 2 inert retirement/reset, all eight
early 3 cleanup hooks before full join snapshots/checks, one Optional host and
its post-construction defer, early 4/5 and common origin retirement. Original
14/9 loans/token, setup timing, full baseline/64 records/four keys/backend facts,
custody/prefixes/48 groups/2,266 selections and 26 labels remain mandatory.
Source review must verify explicit noncopyable permissions and actual field
loans at every new seam. Fresh 160-root packing and complete cold/live/cleanup/
outer/lender/IRQ measurement must follow; neither recovering old frame sizes nor
the proposal's conditional subtraction establishes headroom.

Proceed with this single grouped correction 1, then independent SOURCE review and
the same three registered fresh focused collections. No contract/limit amendment
or new permission boundary is needed for that source work. No source, compiler,
test, runtime, image or agent was invoked by this review. Governance, whitespace
and affected links pass. P08 and all nine SO criteria remain open.
