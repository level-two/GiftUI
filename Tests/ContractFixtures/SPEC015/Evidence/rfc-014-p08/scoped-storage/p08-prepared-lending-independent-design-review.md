# P08 prepared lending — independent document review

**Design PASS; ready for a user execution decision. No allowance is approved.**
Reviewed draft design `4b662a58` and the current source/evidence it cites. The
[prepared-lending proposal](../../../../../../docs/implementation-designs/spec-015-p08-prepared-lending.md)
is one compatible private mechanism under accepted ADR-039, SPEC-013 S13.1/S13.2
and SPEC-015 S15.1/S15.2. SPEC-015 remains implementing; P08/R07/T8.1 and all full
SO criteria remain open. ITERATION-003 I3-04/I3-05 and the existing I4-07/P09–P12
allocation are unchanged. No blocking design finding remains.

The control flow is sufficiently explicit for a bounded implementation:

- Begin uses the actual owner inout, preserving idle/capacity validation,
  complete emptiness validation, checked serial increment, active transition
  and preparation order. Its returned preparation contains owned facts only;
  it does not acquire authority or become a second physical inventory.
- The thin outer factory keeps that one preparation noncopyable and passes it
  inout. Its immutable token still depends on the same actual owner's borrow
  and current identity/serial. The factory retains exclusive owner access;
  the prepared lender has no whole-owner capture. Nested callbacks use the one
  fact value without propagating nineteen separate captures. Native exclusivity
  and compiler acceptance of that nested inout shape are explicitly unproved.
- Static retains the exact original fourteen loans
  b0/b1/b2/b3/g0/g1/g2/g3/g4/c0/h0/r0/r1/h1; Dynamic retains its original nine
  g0/g1/g3/g4/c0/h0/r0/r1/h1. Access construction/body consumption remain inside
  the complete original typed-loan nest. Establishing the token earlier does
  not authorize access outside that nest. The same five complete entries,
  capacities, address checks and lifetime annotations remain; no raw replacement
  loans or scoped Result escape are proposed.
- After body/retirement/reset and typed/token/fact scope end, finish performs
  complete emptiness validation before restoring idle. The owned Result boundary,
  once-only synchronous body, logical cleanup, physical backing-last release,
  prefix initialization unwind and invariant-failure disposition remain intact.
  No throwing cleanup, trap recovery, changed first error or new reentry path
  is introduced. Shared state/host types, observations and resource limits stay fixed.

The measured target is supported by the current archived ELF: symbol 6515's
3,856-byte fixed frame includes two 1,006-byte receiver homes, and its recorded
call setup at +0x42/+0x86 targets the stated helper. The four selected byte-loan
forwarder frames are 552/536/520/496. These are observed costs; neither 2,012
receiver bytes nor their 2,104-byte callback subtotal is a promised saving.
Constructor 9,968, session/caller 5,960, factory 3,360 and uncounted enclosing
costs remain. The [current actual-image stack rejection](p08-current-firmware-independent-review.md)
of 28,560 > 27,648 is unaffected by document approval.

One reproducibility ambiguity is corrected in the design with this review:
the diagnostic's compiler/imported-module identities stay unchanged, while source
hashes must match the frozen reviewed candidate and its authorized source delta.
They cannot all equal the unchanged baseline when the candidate edits its one file.

The proposed diagnostic is appropriately bounded: one isolated counter-object
compile using actual firmware flags and pinned imports, with separate output/
module/cache destinations, after source and the existing three focused recipes.
It is a viability screen, not a linked image or complete acceptance. A later
normal image still requires complete current receipts through the unchanged
handoff guard. No acceptance guard is bypassed. Replacement frames, callbacks,
SP areas, cold/live/current/stale/cleanup and begin/finish paths must be accounted;
a smaller single prologue is insufficient, and the complete final ELF/IRQ/
allocation/Dynamic-cost obligations remain.

The user decision is **one initial candidate plus at most one grouped ordinary
correction of this same mechanism**, with the proposed validation sequence and
stop on persistent physical rejection. That is a new suggested allowance, not a
reset of any closed allowance or permission for a replacement mechanism. A source
or contract incompatibility requiring erasure, suppression, dropped dependencies,
changed cleanup or larger limits stops for upstream disposition. No such fallback
is approved. Hardware remains excluded.

This was a bounded document/source/evidence read, with only the identity wording
clarification, this review and navigation edits. No maintained source edit,
compiler/build/link/test campaign, hardware operation or large investigation ran.
Governance, whitespace and affected-link checks pass; existing pycache is preserved.
