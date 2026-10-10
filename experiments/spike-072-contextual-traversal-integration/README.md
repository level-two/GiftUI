# SPIKE-072 contextual traversal integration

Disposable evidence for [SPIKE-072](../../docs/spikes/spike-072-contextual-traversal-integration.md).
Production sources and build flags are unchanged. See the [terminal result](evidence/result.md)
and [application coverage inventory](application-coverage.md).

## Inputs and reproduction

Run from the repository root with the existing project-local Swift 6.3.2 tools:

```sh
python3 experiments/spike-072-contextual-traversal-integration/prepare.py
python3 experiments/spike-072-contextual-traversal-integration/generate.py
python3 experiments/spike-072-contextual-traversal-integration/run.py positive
python3 experiments/spike-072-contextual-traversal-integration/modules.py
python3 experiments/spike-072-contextual-traversal-integration/run.py negative
python3 experiments/spike-072-contextual-traversal-integration/modules.py --app-only
python3 experiments/spike-072-contextual-traversal-integration/inventory.py
```

These describe the recorded workflow, not permission for further trials. The
terminal marker prevents new compiler/execution trials. Historical intermediate
sources live in `evidence/inputs/`, indexed by each ledger entry. Commands,
diagnostics and failed attempts remain in `evidence/ledger.json`. Historical
inspection commands are also recorded there; no network, hardware or global
compiler selection is needed. The two doctor commands verified the local pins.

`prepare.py` copies actual framework sources and records every source hash and
unified diff. It mechanically threads a separate session, changes contextual
View witnesses, adds typed access outcomes, and supplies a separate drawing read
argument. Ordinary semantic work/path validation, body-binding orchestration,
Canvas occurrence validation, invocation order and release paths come from the
real framework files. Unrelated protocol-support files are exact source slices.

`generate.py` parses the small checked Swift-shaped corpus into an AST, then
emits model handles, root/nested host conformers, generic read helpers and Canvas.
It is not SwiftSyntax, a macro or a general Swift frontend. Both custom associated
Body types are explicitly derived from the finite source shapes. A universal
leaf default originally made Swift infer Never for the custom types; the failed
native result and SIL witness excerpt are retained. Leaves now have a separate
marker. Source defaults outside the fixture's fixed 0/7 model ABI are rejected.

`modules.py` builds seven real adapted module boundaries and a separate test
application on all four configurations. It adds the exported ModelKey initializer
and drawing-read convenience method needed across modules, with no Runtime import
or runtime module on the search path. All builds use package name GiftUI to test
existing package SPI; this is not external-consumer eligibility or packaging work.
The later `--app-only` pass adds the final behavioral controls without recompiling
unchanged framework modules. Target objects are under their normal `.build/`
roots. Native binaries link all seven module objects.

## Fixture boundaries

- Session owns no allocation: its two initialized scalar entries use exclusive
  caller-provided backing. That pointer lifetime/disjointness is a fixture
  precondition, not a proved application owner. Model keys contain index/epoch;
  full owner/generation identity, K=2/F=1 tickets and retained replacement are absent.
- The actual SemanticCore state-binding callback receives a fixture Binding;
  the generated hosts carry keys. The production State wrapper, macro and
  observable reconciler are not exercised or changed.
- GraphWorkspace uses bounded nibble paths and a common nominal-role tag. The
  independent path/count checks cover this corpus, not the production exact
  nominal type codec or complete graph publication.
- LayoutFixture supplies resolved painter order and geometry. It is not the
  Layout algorithm. DrawingWorkspace invokes the real GraphicsContext but records
  scalar/path observations; it is not a complete immutable geometry plan store.
- Native Dynamic/Static flags select the same scalar Session. They do not prove
  Dynamic class ownership or profile resource equivalence.
- Frame is pinned for the tested derive/draw sequence and current writes refuse
  during it. Session teardown, post-finish read creation, owner destruction,
  generation exhaustion, association rollback and independent retention are not
  a complete phase/owner proof. Session is a test adapter, not a safe public API.
- `Negative.swift` is one new integration-specific borrow/discovery rejection,
  not another general escape matrix. Source rejection controls do not establish
  complete source-language safety.
- No target execution, linked firmware allocation/stack/timing, connected hardware
  or five-bank resource conclusion follows from object compilation.
