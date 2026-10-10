# SPIKE-071: Canvas Embedded and escape continuation

**Terminal: supported recommendation for the bounded mechanism.**
[Results](evidence/result.md) and [scope](../../docs/spikes/spike-071-canvas-embedded-escape-continuation.md)
record the precise boundary. This disposable follow-up preserves SPIKE-070's
terminal evidence and makes no production or approval change.

## Changes from SPIKE-070

`evidence/provenance.json` identifies copied sources and their original hashes.
The candidate's owner, source transformer, generated declarations, Canvas
protocol and finite visitor are unchanged. Driver assertions now evaluate the
two typed throwing scalar reads before combining nonthrowing Bool values.
The exported entry/module/output paths use SPIKE-071 identities.

The original nested-helper negative had an additional borrowed-value consumption
error. It now returns `copy read`. Four positive controls compile the same helper
returning a view tied to a live caller owner; four corrected negative controls
return it from a dead local owner. Their only error is the intended lifetime
escape. Preserve the four original, confounded diagnostics as superseded test
controls, not independent evidence of nested-helper enforcement.

## Scope inherited unchanged

See [SPIKE-070 source boundaries](../spike-070-protocol-canvas-versioned-access/README.md).
The finite Swift-shaped source grammar is not a complete Swift parser/checker or
macro implementation. Only frozen reads are lowered; mutation is handwritten.
The root becomes a throwing descriptor without View conformance, and the target
Canvas draw gains a FrameRead parameter. Actual child View/Canvas traversal and
GraphicsContext run through a fixed visitor/recorder and a synthetic Layout
boundary. Actual State reconciliation, class-owner equivalence, production
context injection, model pool/C-P3, whole firmware and hardware are untested.
Caller-supplied raw backing must remain initialized, disjoint, exclusive and
alive; compiler scope checking does not establish these host preconditions.

## Reproduction and evidence

Run from the repository root. The historical sequence was `generate.py`,
`generate.py check`, `run.py positive`, `run.py negatives`, `run.py reachability`,
and, after the recorded control repair, `run.py helper-controls`.
The ledger is authoritative for exact commands, flags, inputs and logs. It
contains 40 compiler/link/executable invocations. Content-addressed Swift
snapshots preserve every compiled source version. Compilers and SDKs are pinned
by inventory hashes; both target doctors passed.

`python3 experiments/spike-071-canvas-embedded-escape-continuation/inspect.py`
verifies logs, snapshots, diagnostics and native transcripts and re-inspects
existing objects. It does not compile/link/run fixtures. Generated output can
be compared in memory through `generate.generate`. Stored generator controls
contain all seven rejection samples and three source-dependent perturbations;
perturbed outputs are not separately compiled or executed.

The compiler runner refuses trials after `evidence/result.json` exists. Keep
that marker and these evidence files intact. A later experiment requires its
own authorization/scope/budget. Successful object hashes and exact `.build/`
locations are recorded in `evidence/inspection.json`; binaries are not tracked.
The relocation/disassembly evidence is inspectable without retaining a full
firmware or invoking the compiler again.
