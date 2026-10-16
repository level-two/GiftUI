# P08 donor metadata — independent final result and exit review

**Independent result review PASS; resource FAIL and STOP supported at `c20ba51b`.**
Source remains `6449093d` (SOURCE PASS `dbb4cc5b`). The
[final result](p08-fixture-metadata-final-result.md) accurately separates successful
focused behavior/layout from a necessary RAM failure. Correction2/2 is closed;
there is no automatic third variant. P08 and all nine SO criteria remain open.

The [collection packet](fixture-metadata-cycle2-collections/result.json) verifies
against all three exact archived/current receipts and wrapper hashes, exit0 and
the frozen manifest argv. Fresh focused results truthfully retain
`focused_passed=true`, `collection_complete=false`, `passed=false`, no predecessor
collection replay, and 202/384 omitted controls. nRF has 25 passes including all
160 current strict layout facts; Dynamic/Static each have 42 passes including all
23 selected controls. Their actual execute logs report 1,736,167 and 1,736,243
assertions, zero failures (3,472,410 total), all 13 reuse observations per route,
five exclusivity controls and both projection controls. Expected negative compiler
rejection/exclusivity trapping remains a successful negative control, not a failed
positive hidden by the totals. Current fixture/compiler/module, Native executable
and critical layout hashes verify. Metadata extent15,760 occupies the existing
donor slot; its 18,960-byte tail stays charged inside 138,880, with no double charge.

Independently read the actual ET_REL object
`dd79863da870e9b78fedbfd140d5b60d77f9da0cddf974da349a4c752384c257`,
verified the [bounded packet](fixture-metadata-cycle2-screen/result.json) and its
member hashes, exact function bounds/table/index identities, and compared recorded
critical-body instruction bytes to the object. Raw Thumb immediate decoding,
including SUBW, confirms this fixed-entry subset:

`21968 + 12664 + 1528 + 2688 + 6072 + 9208 + 4944 + 2672 + 4360 = 66104`.

Actual relocation sh_link/symbol-index resolution confirms the seven direct BL
edges from session3874 through host3866, reuse3789, old-origins3749,
sensitivity3666, fingerprint3654 and field3626 to runtime baseline3630. The
4152→root-lender/callback→main-root3916→semantic3923→original owner.withStorage
3441→session-adapter3927→3874 connectivity also matches the exact recorded
relocations. Callback REL32 references are not treated as calls: the synchronous
root/semantic/canvas/withStorage bodies at CounterScopedStorage.swift:2461–2507
establish their invocation while the two-host leaf remains live. The second host
has a nonnull transcript and hosts==1; once-only capture precedes sensitivity's
first full positive match. Entry frames remain allocated at the selected calls.
The 13938 tail hop adds no separately counted frame. Returned cold frames,
recording comparison alternatives and mutually exclusive host/failure paths are
not summed. Dynamic alignment, extra outgoing stack, omitted synchronous lenders,
outer custody/dispatcher, other callees, globals and IRQ can only add costs.

Thus **138880 + 66104 = 204984**, exceeding RAM196608 by **8376**, even before all
omissions. The fixed subset also exceeds main27648. This is sufficient to reject
this realization and stop current full202/image work; neither a current linked
image nor a complete maximum is proved or needed for that rejection. Merely
increasing the stack allocation cannot satisfy the unchanged total RAM ceiling.

Concrete remaining materialization costs are the 21,968-byte two-host leaf,
12,664-byte original session construction, 9,208-byte sensitivity frame and nested
full-comparison homes. The runtime-slot seam's 2,652-byte copy is independently
confirmed by section3626's call to14754, whose sole relocation tail-target is
`__aeabi_memcpy8`, before the baseline-match call. Recording has separate memcpy4
paths; it is not added to this bound. These are physical costs, not proof of a
second logical owner. Another implementation requires a bounded, reviewed
ownership/materialization design addressing those homes while preserving the
complete oracle, custody and corpus. No particular fix or contract amendment is
proved necessary; no limit change or new implementation allowance follows from
this review. Historical successes and stops remain valid at their recorded sources.

Only bounded existing artifact/source/hash/arithmetic checks and document checks
were performed. No maintained source, compiler, disassembler, test, runtime, image,
hardware, repair or delegation ran. Full current profile coverage, complete peak/
allocator/IRQ/Dynamic accounting and current images remain unproved.

Whitespace and affected local file-link checks pass. `scripts/validate-governance.rb` remains
blocked by missing YAML front matter in the unchanged
`docs/implementation-designs/spec-015-p08-physical-representation-assessment.md`;
this bounded review does not repair or reinterpret that document.
