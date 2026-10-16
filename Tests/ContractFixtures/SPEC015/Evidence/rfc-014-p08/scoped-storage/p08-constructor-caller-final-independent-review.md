# P08 constructor/caller — independent final result / exit review

**STOP supported: current focused behavior/layout PASS; required main-stack resource FAIL.**
Reviewed result `2989adbe`, source `51cfc960`, SOURCE review `ee10d2f1`.
Initial 1 and corrections 2/2 are closed; no third automatic variant. Source and
all limits/contracts remain unchanged. P08 and all nine SO criteria remain open.

The [final result](p08-constructor-caller-final-result.md),
[receipt manifest](constructor-caller-cycle2-collections/result.json) and
[analysis manifest](constructor-caller-cycle2-analysis-manifest.json) preserve the
right evidence boundary. Independent reads verify the exact current object
`e1ff7e1457e18857f4f562731fe12b10d50f84ed54062270846a8cf9f4056062`,
all 83 analysis-member hashes, and three exact current receipt/source identities.
nRF passes 25 with 202 not run; each Native route passes 42 with 384 not run.
Native assertions total 3,472,564 with zero failures. All receipts are fresh and
focused-passed, with aggregate passed/collection-complete false. The named output
union now compiles in all three profiles. Metadata extent 16,584 plus donor tail
18,136 fills one 34,720-byte slot; all four slots remain charged 138,880.

Actual ELF section/symbol-table indices, raw prologue halfwords including SUBW,
direct BL relocation sites and callback connections support the required cold
path. The twelve previously selected reservations total **27,416**. On that same
route, owner.withStorage 3433 installs first-bank callback 11852 through its actual
R_ARM_REL32 at +1056, loaded and added to PC before the byte-slot borrow call.
11852 allocates **552** (36 saved +516), BLs b0 body 3437 at +576/0x240, and restores
its frame only afterward. Body 3437 allocates **320** (16 saved +304), BLs the next
original byte-slot loan at +0x126 and restores SP only on return. Source keeps the
remaining original loan chain within this first b0 callback. These frames
therefore remain live through scoped callback 4048, session 3994, constructor 3983
and factory 3990; they are not an alternative route or returned helper.

Thus **27,416 +552 +320 =28,288 >27,648 by640**. Further bank callbacks/forwarders,
outer/custody/corpus/dispatch, factory callees, alignment and IRQ are omitted
additional costs. The 640 is not the complete remaining gap. Namespace helper
4316, preparation, installer and join checker have returned before the factory;
alternative callbacks and later live/reuse operations are excluded. The live
22,856 subset is not fit evidence. This necessary failing subset justifies holding
full 202 controls and image work without proving a complete peak or total-RAM
failure: backing plus this subset alone is 167,168, below RAM 196,608.

One immutable ledger correction is recorded here: `required-cold-path.json` gives
12088→4037 as BL offset 234. Actual SHT_REL and complete body show **244/0xf4**.
The section/index-resolved target, synchronous route and frame sum are unchanged.
The current result carries this erratum; the archived packet remains immutable.

The namespace helper's 5,240-byte frame returns before inventory/host work on
success. Its actual missing-ID branches retain the previous boundary sequence:
copy owner 1,006 bytes, owner destructor at +0x40, copy outer 1,596 at +0x4c,
outer destructor +0x52, then trap +0x56. Relocations target the original destructors;
the two scratch alternatives are not summed as simultaneous paths. This closes
the narrow failure-boundary question, not a complete deep-destructor peak or
hardware failure-path test.

The destination signature fixed no proven language failure, and the compiler now
accepts it. It still creates physical Optional homes: caller nil initialization
copies 2,128 bytes; constructor factory output at SP+3408 is cleaned/assigned with
another full 2,128-byte copy. Constructor 9,960 and caller 5,960 remain simultaneous
with required factory 3,360; mandatory owned fields and owner argument transfer
also remain. These are materialization costs, not evidence of duplicated logical
ownership. Namespace/prepared caller reductions are productive, but insufficient.

The remaining decision is a separately bounded, concrete ownership/materialization
approach addressing these measured homes and complete paths, or an explicit
resource-authority decision. The evidence does not prove that accepted contracts
must change. Do not resume blind annotation/helper variants, enlarge a ceiling or
spend full-suite/image work on this rejected realization. Historical passing
evidence remains preserved; no current full acceptance/image claim follows.
No source, compiler, test, runtime, image, hardware or agent ran in this review.
Governance, whitespace and affected links pass; existing pycache is untouched.
