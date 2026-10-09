# SPIKE-069 result

**Terminal: A's callback-only enforcement is refuted; B has bounded compiler
and lifetime-model support, but RFC-014 B1 is not closed.** No production or
authority-bearing contract changed. No connected operation occurred.

| Evidence | Result | What it establishes |
| --- | --- | --- |
| A, trials 01–04 | Compiles on all four configurations | Actual State/binder permits returning, outer-storing and closure-capturing a bound copy; replacing the closure getter with a fixed typed pointer route does not prevent outer storage |
| Initial B, trial 05 | Compiler rejection | Selected declarations need the experimental LifetimeDependence flag; repaired once |
| B, trials 06–09 | Positive compilation on all four | Scalar/indexed reads through the selected nonescapable capture view compile |
| B, trials 10–29 | 20 intended compiler rejections | Local-owner return, callback-to-outer storage, escaping closure, overlapping owner mutation and ordinary stored declaration controls reject with the expected diagnostics |
| B lifetime model, trials 30–35 | 16/16 cases execute in each macOS profile; Pi/nRF objects compile | Five-slot (R=1) protocol model preserves declared snapshot keys, replacement/failure, retirement, admission and explicit releases under the tested sequence |
| Actual GiftUI declarations, trials 36–39 | Owned scalar body compiles on all four | An owned View can be constructed from scoped reads; all 16 maintained GiftUI files compile unchanged |
| Actual Canvas, trials 40–43 | Borrowed capture rejected on all four | Directly capturing this nonescapable view cannot realize the existing escaping Canvas declaration |
| nRF reachability, trials 44–45 | Sectioned compile and relocatable GC link succeed | Both exported fixture roots remain; retained relocation/call evidence contains no allocator reference or indirect register call |

## Enforcement and compatibility

The A controls never dereference the escaped pointer; they demonstrate an API
enforcement gap, not an observed production use-after-free. They do not refute
all typed handles, stable owner storage or source-compatible generation. A
checked lowerer could reject unsupported escapes or transform captures, but
none was implemented or proved here.

B requires `-enable-experimental-feature LifetimeDependence`. Even with that
flag the pinned compiler warns “Unsupported use of @lifetime” and recommends
the underscored spelling. The experiment preserves those warnings; it does not
establish a supported production language contract or change deployment floors.
Only the one declared syntax/flag repair was made. No further syntax search is
authorized by the remaining invocation allowance.

Candidate B deliberately keeps the owner backing alive through an explicit
host precondition. Its view has no public unsafe pointer and the compiler
rejects the tested escapes/overlap, but a raw backing pointer retained by the
host could still violate that precondition. Span cannot prove external backing
ownership. Similarly, the pool explicitly tracks one application owner per
model; it does not prove arbitrary copied handles are retained/released safely.

The CanvasWork fixture stores a key and scalar, pins the selected snapshot,
then obtains a new read borrow at invocation. It does not capture the borrowed
view in an escaping closure. The actual GiftUI Canvas negative confirms this
distinction matters: adoption needs checked callable/model lowering or an
explicitly changed source/API contract. Hand-writing the fixture is not that
lowering proof. The scalar-body control is declaration compilation, not actual
Semantic Core expansion, body-once validation or layout/pixel parity.

## Resources and target limits

Native fixture strides: Transition 16, CaptureOwner 24, SnapshotKey 12,
CanvasWork 20, SnapshotPool 112 bytes. These are macOS 64-bit values, not
target codecs or complete resources. Five transition slots use 32,320 backing
bytes for this R=1 experiment; no production capture reservation changed.
The host test harness allocates backing explicitly and is excluded from the
target candidate object. Neither macOS flag variant is an implemented Dynamic
class-owner versus Static-owner equivalence test.

nRF objects report Cortex-M4/ARMv7E-M and VFP register arguments. The initial
object emits general Embedded Swift runtime helpers, with undefined allocator
symbols. The sectioned relocatable link discards the allocator implementations;
its symbol table still contains unreferenced allocator entries, while the raw
relocation and disassembly logs show no retained allocator call/reference.
Do not label the original `nm -u` list either a proved allocation path or a
whole-image zero-heap pass. External memory helpers are unresolved; no Zephyr
firmware image, full RAM/flash, full stack/IRQ bound, or target execution was
produced. Pi evidence is ARMv6 hard-float object compilation only.

## Residual gates and recommendation

- **B0:** three versus four-plus-retired snapshot slots still requires an
  architecture decision. Four means R=0, which this R=1 fixture does not prove
  for either maintained application.
- **B1:** select checked source-compatible lowering or explicit scoped API
  changes; establish the compiler support policy and full owner/callback proof.
  Void results and generation checks alone are not a sufficient resolution.
- **B2:** determine application ownership/cardinality, exact production payloads,
  complete paths/interaction keys and codecs; modeled slot exhaustion is not
  that accounting.
- **B3/B4:** complete integrated stack, Dynamic cost, generated-route coverage,
  real traversal and application parity remain unproved. The 4 MHz performance
  failure is unchanged.

Recommend the **scoped read plus delayed owned key mechanism** as an internal
design candidate. Keep source compatibility as an explicit, separate choice:
either specify enforceable lowering rules for the supported declaration
vocabulary, or review new scoped State/body/Canvas declarations. Do not infer
that the experiment selected either public contract or proved a general lowerer.

The bounded package ends here: **45/48 compiler/link/run invocations; 1/3 repair
rounds**. Documentation integration and commits remain within the original
90-minute ceiling; no further compiler trial is planned. Raw logs, exact input
snapshots, hashes and inspections are preserved. Initial failed trial 05 remains
in the ledger rather than being rewritten as success.
