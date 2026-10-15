# P08 remaining-work boundary — independent Strong exit review

**P08 NOT COMPLETE — FIT FAIL independently confirmed.** Independent Sol 6.1
High review of `47b57eb8` full-collection evidence and `7b1f8033` image/resource
reconciliation, with implementation source unchanged from `0d3e3c7d` and source
review `51544daa`. The [resource result](p08-remaining-images-resource-result.md)
and [activity](p08-remaining-completion-activity.md) correctly preserve a failed
acceptance gate despite successful tests and image builds. No material evidence
contradiction, contract waiver or implemented transition is found or approved.
This is a bounded P08 assessment, not whole-Specification conformance closure.

## Independently verified blocker

The actual nRF ELF SHA-256 is
`66ca1113d997c6424aedb258c1477692ce4bf5b42ed77f42bb1d5cba66339da9`.
I verified that binary and the pinned objdump hash, reran only the four existing
read-only symbol-range disassembly commands, and matched all output hashes.
Actual ELF STT_FUNC records match the [entry/frame identities](remaining-early-images/entry-and-frame-symbols.json);
nearest printed Swift labels are not used to attribute functions.

Independent decoding of raw Thumb bytes confirms C main's call at `0x322d6`
reaches `0x5c206`, its whole tail branch reaches Swift entry `0x5c20a`, and the
Swift call at `0x5c230` reaches counterExerciseScopedStorage at `0x214f4`.
Main's successful initialization path supplies the actual nonnil backing and
128,000-byte extent; the accepted workload requires the preceding graph phase
to return, after which this call is direct. This is the current image's required
route, not a disconnected negative probe. No target execution is inferred.

The prologue's raw encodings `e92d 4ff0`, `f5ad 4dea` and `b09b` respectively
save nine registers (36 bytes), subtract 29,952 and subtract 108. Therefore this
one reachable frame needs **at least 30,096 bytes**, exceeding the unchanged
**27,648-byte ceiling by 2,448 bytes**, before 16-byte alignment, caller frames,
callees or IRQ overlap. The lower bound alone proves failure. Larger reported
frames need not establish an upper bound for this conclusion. The historical
58,648-byte failure remains preserved; neither measurement is a passing bound.

## Evidence and acceptance limits

| Evidence | Disposition |
| --- | --- |
| Four full collections | All 2,897 archived member hashes and exact current receipt inputs verify. Dynamic 424, Static 424, ARMv6 409 and Embedded 227 checks are complete and passing: 1,484 total, with 3,472,240 native assertions and zero failures. Existing qualified component applicability remains bounded. Targets supply compilation/object evidence. |
| Images/layout/ABI | Both pinned ELF identities and four doctor/image wrapper exits verify. The object/ELF layout proofs and exact C reservation establish 25 regions, cursor 31,993, alignment 8, slot 32,000 and 128,000 retained bytes. Linked ABI/layout success does not discharge target runtime or stack fit. |
| Linked sections/warnings | Independently summed actual ELF LOAD segments: FLASH 396,660 / 1,048,576 and RAM 159,744 / 196,608 pass their individual checks. All 454 archived warnings are orphan .swift_modhash warnings. Its actual 3,632-byte allocated, non-executable section lies in a flash LOAD segment and is already charged; no warning-free result or uncharged-RAM inference is made. |
| Provenance/callers | Documentary verification passes 25 packet files, 33 image archive members, both binaries, 681 compiled source/object/tool identities and all 176 current caller hashes. Source/build files remain unchanged. Refreshed token hits and dispositions support the impact audit, not compiler resolution of every retained analyzer factory. |
| Open proof | Complete feasible construction/body-return/helper/retirement/IRQ stack upper bounds, Static allocator reachability, matched Dynamic headers/transient peaks, all physical/carrier temporary costs and every target cleanup path remain unproved. Zero heap configuration and a trapping allocator stub cannot substitute for reachability proof. Native cleanup/lifecycle/reuse/exclusivity successes retain their actual scope. |

All nine SO criteria remain formally open. IN-SO-001/HC-SO-001 have current
four-profile matrix support; IN-SO-002/RP-SO-001/RP-SO-002/HC-SO-002 have the
recorded native physical/lifecycle controls and target compilation/layout facts;
IN-SO-003 retains unresolved owned analyzer/factory and full reconciliation duties.
RP-SO-003/HC-SO-003 are blocked by the demonstrated fit failure plus missing
resource proof. No partial row is promoted to full RFC conformance. P08, R07,
T8.1 and HC-RD-003 remain open; SPEC-011/013/015 stay implementing and plans active.
Accepted ADR-039 and approved Specifications retain authority. I4-07 residuals,
P09–P12, connected hardware and timing retain their existing boundaries; required
P08 safety/fit cannot be hidden in deferred work. FW-038 changes no current gate.

## Maintainer decision at the exhausted boundary

Both corrective cycles are consumed (**2/2**), with productive compiler/layout
progress and immutable failures preserved. This review does not authorize a
third correction, source variant, compiler/image retry, capacity/workload change
or larger stack. The next decision is whether to authorize a **new separately
bounded resource-realization diagnosis/design/correction activity under the
unchanged contracts and limits**, or hold P08 at this failed boundary. A new
activity should first attribute the demonstrated frame and simultaneously live
objects/copies, then freeze a concrete reviewed change and affected validation.
Successful unchanged evidence should be retained under exact applicability;
missing or changed proof must not be waived to save execution time.

No specific source fix is proven by this report. If satisfying the unchanged
contract requires an architectural, scope or limit change, return that concrete
decision through the RFC/ADR/Specification process before implementation.
P08 cannot close or unlock its dependent package merely from renewed work
permission. No whole-Specification implemented transition is supported.

Review operations were evidence hashing, archive/receipt comparison, direct
read-only ELF/symbol/disassembly inspection and documentation updates, followed
by governance (199 authority nodes / 2,024 edges), 549 local Markdown links
and whitespace verification, all passing. No compiler, test suite,
runtime, image build, debugger, hardware action, source fix or subagent was used.
The existing untracked scripts/contracts/__pycache__ directory was left untouched.
