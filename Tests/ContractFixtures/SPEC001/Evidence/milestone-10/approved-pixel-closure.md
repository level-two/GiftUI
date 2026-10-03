# T10.8 approved-pixel closure — 2026-10-03

Reviewer: Eugene, repository maintainer. After viewing all 24 state/target PNGs
in this chat, the maintainer explicitly accepted them:
> It's okay. Let's accept them and mark this task as closed.

The 24 corresponding RGB565 files are retained byte-for-byte from the
immutable `c0978177` review packet archive, not regenerated to bless new output.
`PixelReferences/reviewed-hashes.tsv` locks every reference identity. Pi logical
is 240×240, mapped display 480×320, and nRF landscape 320×240. The seven current logical states and Pi physical mapping (21 images) pass
exact comparisons. Three approved cleared-state images are older artifacts,
retained under HistoricalCleared. The current recording command does not
capture cleared, so T7.7 remains open for its current-source capture and T7.9
remains open on that prerequisite. No original registered state is removed;
Pi physical mapping comparison adds coverage to the existing gate.

The two registered SPEC-001 profile drivers pass with reviewed references:

| Profile | Immutable run ID | Result |
| --- | --- | --- |
| raspberry-pi-armv6 | `20261003T072252Z-10481` | pass |
| nrf52840-embedded | `20261003T073430Z-15010` | pass |

Both drivers also exercise the current production loop/fault cases, source and
binary identities, supported ABI and resource collectors. Pi's independent
comparison covers 120 workload frames, nine initial/action frames and 12 actions;
nRF's covers 818 ordered frames and 12 actions. All 21 current approved raw pixels match
exactly. Corrupting one byte of Pi stopped physical output or nRF diagnostic output
causes rejection and a diff image; both negative checks pass. The final nRF
full-layout fixture also checks exact canonical semantic revisions 1/2,
superseding its stale pre-join 3/4 expectations; all other assertions remain.

The complete registered gate originally recorded 62/72 passes; eight named
owner reruns then passed; these two final registered profile reruns now pass.
All **72 registered checks have passing recorded evidence**, using the original
gate and explicit reruns. This is not a claim that the whole 72-check invocation
was rerun at one uniform revision. Original failure statuses and input scopes
remain retained in the assembled packet. No gate is waived or removed.
The two expensive macOS reference corpora already passed in the full gate;
these reruns use the registered shared-reference reuse option and each passes
269 selected Swift tests, as recorded in the raw logs.

T10.8 is complete. All eight milestone-10 tasks are closed.
The plan remains active for T7.7/T7.9 current cleared-state capture/rehearsal
completion and T8.1/T8.2/T8.3: connected physical display/input,
all controls, sustained cadence and target costs, then connected/reference trace
comparison. The acceptance ledger retains 41 scoped passes and four blocked criteria
(SA-AC-005/023/024/039). SA-AC-005 still needs current cleared-state coverage;
this does not turn recording adapters into connected evidence. Specification
status remains implementing; no implemented transition is requested.

`approved-pixel-validation.tar.gz` retains the immutable report metadata,
commands, ABI/resource/profile reports, raster hashes, behavior/fault results,
checker sources and meaningful corruption negatives. No device was flashed,
remote artifact deployed or service restarted for this pixel-review closure.
