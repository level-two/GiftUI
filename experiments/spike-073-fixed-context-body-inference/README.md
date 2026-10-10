# SPIKE-073 — fixed-context Body inference

Disposable language evidence for [SPIKE-073](../../docs/spikes/spike-073-fixed-context-body-inference.md).
[Terminal result](evidence/result.md); [exact invocation ledger](evidence/ledger.json).
No production module or source transformation is implemented here.

The final fixture has no `typealias Body`. A non-generic requirement takes
`borrowing FrameRead`; Root/Nested implementations return `some View` through a
result builder, including a conditional and opaque helper. Only explicitly marked
leaves receive the Never default. Generic evaluation invokes the associated Body
witness and checks output, so a wrong Never witness cannot pass the native runs.
Pair/Choice use simplified fixture inspection rather than production traversal.

Owner stores one pointer to two caller-owned scalar entries, plus a phase bit.
FrameRead borrows a Span over those same entries. No second bank exists. Bodies
return owned scalar output; Canvas returns scalar surrogate geometry on a later
read. Mutation is rejected during deriving even between read borrows. Later
mutation changes the next evaluation and leaves earlier owned output unchanged.
The caller must retain exclusive initialized storage for Owner's lifetime;
production owner tickets, generation checks and allocation policy are absent.

## Reproduction

From the repository root, the original commands were:

```sh
python3 experiments/spike-073-fixed-context-body-inference/run.py positive
python3 experiments/spike-073-fixed-context-body-inference/run.py negative
```

The first positive failed because an unannotated do/catch inferred `any Error`.
One recorded source repair added explicit typed do scopes and Equatable, then the
positive command was repeated. All invocations and exact input snapshots remain.
The runner refuses further trials after terminal `evidence/result.json`. Do not
remove the terminal evidence or reopen this study to rerun it. A maintainer can
reproduce exact commands from the ledger into a separate scratch output directory;
that is a new run, not an extension or replacement of this evidence.

Pinned project-local Swift 6.3.2 and ARMv6 SDK hashes are in the ledger. Both
lifetime feature flags remain experimental. Build outputs are ignored under
`.build/spike-073`, `.build/raspberry-pi/spike-073`, `.build/nrf52840/spike-073`.
No global selection, installation, target execution or connected device changed.
Compiler version/SDK readiness was checked with the two repository doctor scripts.

## Limits

This fixture is intentionally small and handwritten. The native profile flags
compile identical logic; they do not exercise the actual Dynamic/Static runtimes.
The result does not prove arbitrary result builders, application-specific schema
abstraction across modules, unchanged authored syntax, real child State discovery,
full graph/layout/draw integration, escape completeness, target linking/execution,
or heap/stack/firmware budgets. The escape negative checks storage in an Escapable
struct; the overlap negative checks ending Owner's phase while a read remains live.
