# One optimized-IR capture failure — 2026-10-13

[Independent capture/package review](independent-review.md) atff2d5d3a
verifies the three argument differences and accepts the finite failed-capture
record. No lowering/construction design or new source/compiler allowance is
supported. Existing P08 authority permits a precise ownership-preserving design
proposal; broader compiler investigation or actual scope/contract changes need
their own explicit disposition. Capture1/1 remains closed, package repair guard
is neither exhausted nor reset, and P08/R07 stop incomplete at the proven58648
stack failure. No compiler/source/variant ran in that review.

**STOP: authorized capture1/1 consumed; compiler actualexit-5, emptystdout/stderr.**
Dispatchd2200978 undered985668; unchangedsource63e717d1. No retry, source edit,
build/link, alternative output/optimization recipe, target action or compiler
failure diagnosis followed. No cause is inferred from the exit alone.

The exact148-element original/diagnostic argv arrays and captured cwd are in
[invocation-receipt.json](invocation-receipt.json). Only indices7,105,108 change:
-c→-emit-ir, isolated output-file-map path and isolated emit-module-path. All
other options/identities remain unchanged. The per-source39object outputs map
to isolated llvm-ir paths; ancillary paths also redirect. Both exact maps are
preserved. No output-key probe or second compiler invocation occurred.

[Actual exit](capture-exit.json), [empty log](capture.log), start/time metadata
and output hashes are adjacent. Full recorder tool walltime0.436902583seconds
includes pre/post hash work; compiler-only duration was not separately measured.
Do not infer that duration from file timestamps or retry to measure it.

All482frozen semantic/input files match after the invocation;364prior firmware
object/archive identities were verified before it. The isolated output manifest
contains only the precreated output-file-map input: zero emitted IR/module
artifacts there. This is no lowering/ownership/stack evidence and no new image.
Previous four current source routes/link pass and58648-byte construction stack
failure remain unchanged; this capture does not invalidate or improve them.

[Attribution/design boundary](allocation-attribution.md): without emitted IR,
no alloca/lifetime/source-variable table or avoidable-allocation design can be
supported. Preserve the prior7284/7807/8155linkedcopy observations as machine-
level facts, without labeling them named source variables or backend spills.
No next implementation is selected. Independent read-only review and package
boundary disposition precede further affected work; no new human gate inferred.

Capture budget1/1 exhausted. Phase correction/image and all historical
allowances stayclosed; package guard neither exhausted by this compiler failure
nor reset. Main27648/heap0/RAM196608/flash1048576 unchanged. P08/R07/T8.1 open,
SPEC015 implementing/planactive; P09–P12 and hardware untouched.
