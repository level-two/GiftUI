# RFC-014 P06 independent repair exit review — 2026-10-11

**Recommendation: PASS for the finite P06 package. P06-R1 is resolved.**
This supersedes the blocked recommendation in [the original review](exit-review.md)
for repaired implementation `431293f9`, without rewriting that historical report
or its reproduction. Parent package disposition is separate. T10.1, full
SPEC-012 acceptance and P07–P12 remain open. Counter remains **0/2**.

## Boundary and authority

Sequential independent Strong review (`gpt-6-astra` / `high`, C3/R3) began on clean
`ddf092a1`. Reviewed delta: `72438931..ddf092a1`, comprising implementation
`431293f9a11fdf7c48020520a37f8be1c31ce304` and evidence commit `ddf092a1`.
The original complete P06 review remains applicable outside this small delta.
Only 11 production lines in FiniteSourceLowering changed; the other changes are
the two registered fixtures and evidence/derived records.

Authority remains SPEC-012's approved RFC-014 amendment, especially lines 118–120
and 177–178, ADR-035/036/037, retained geometry/failure ADRs and approved scoped
Source correction `e6f10f67`. No contract, suppression, capacity, geometry,
ownership or package boundary changed. SPEC-012 stays implementing, plan active.
This review applies the same conformance/lifecycle review roles as the initial
review; it does not approve an exception or implemented transition.

## Repair assessment

`Sources/GiftUIMacros/FiniteSourceLowering.swift:296`–`:306` now prepends checked
facade construction for every model key in the current Canvas binding inventory.
The inventory is collected from the declaration's model-typed properties before
its body is rewritten (`:191`–`:205`). Sorting its property names makes the
validation sequence deterministic; `self.<name>` refers to the stored key even
when a local name appears in the authored body. No model-member use or branch
condition determines whether the prebinding occurs.

Each generated `_ = try Facade<D>(self.key, drawingRead: read)` uses the existing
typed drawing initializer (`:744` onward), which invokes the domain's checked
bind and maps failures through the existing DrawingError conversion. The facade
has no named retained binding; it is discarded at that statement. The enclosing
actual-owner read remains scoped to invocation and closes on success/throw.
Subsequent authored field reads may bind again within the same stable frame;
the repair does not retain a facade or change model ownership. Keyless Canvas
has an empty prebinding list; the generated EmptyCanvas witness remains empty.
The Counter and Analyzer saved generated outputs exhibit this placement.

The generated table still checks witness/payload agreement first. Producer
admission, complete identity/Layout ordinal checks and local bounds construction
still precede the draw witness. The new prebinding precedes every authored path,
read-free branch or client failure. Existing typed error mappings, no-suffix
behavior and release paths are unchanged. No remaining P06-R1 ordering defect or
new defect was identified in the repaired delta.

## Focused independent replay and registered controls

The original independently authored counterexample was replayed with the repaired
lowerer and current verified component objects. Its authored Canvas and real
P03 owner/staged-value driver are byte-identical to the old inputs; only the
driver's expected-result assertion changes in a separate `.build` copy. The old
report, source, scripts, logs and hashes remain unchanged.

The [new native log](repair-exit-binding/3.log) reports:

```text
stale-key draw: beginPathCalls=0 invalidModelAccess=true capacityExhausted=false releases=1
```

This directly reverses the original defective outcome and proves binding wins
before path admission for that stale key while cleanup remains exactly once.
[Replay script](replay-binding-repair.py),
[commands](repair-exit-binding/commands.txt) and
[identities/results](repair-exit-binding/result.json) preserve reproduction:

```text
python3 Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/replay-binding-repair.py
```

The registered CanvasStoreProbe modes 11/12/15 independently expect
invalidModelAccess for stale/wrong-owner keys before a deliberately failing
second path, including a read-free branch. They require only the first occurrence
to begin/stroke, no later occurrence, and three releases. Modes 13/14 verify valid
read-free capacity and success outcomes. Mode 16 combines malformed identity/order
and stale binding and preserves the prior invariantViolation. These run with the
actual P03 owner and both staged lenders; discovery afterward checks read closure.
The changed read-count expectation for mode 2 follows the changed authored source:
path admission now precedes its field getter, so failed path admission prevents
that getter. It does not weaken the new binding-before-path expectation.

## Evidence reconciliation

The reviewer inspected `verify-repair-evidence.py` before executing it. It checks
original/copied receipts, all P06/core inputs and artifact hashes/sizes, compiler
hashes, named negative diagnostics, native/target ABI logs, all measured layouts
against the old receipts, unchanged oracle/geometry sources and all original
independent-review files. The independent result is
[repair-exit-verification.json](repair-exit-verification.json).

- **602 input hashes and 812 artifact hashes/sizes match**, across four profiles.
  Seven baseline geometry/oracle controls and all historical review files match.
- Extra independent checks match index metadata/counts with receipts and confirm
  each core's macro-tool and SwiftSyntax library hashes. Reviewed implementation
  sources/fixtures/driver remain identical to `431293f9`.
- Static's dirty `72438931` receipt accurately captures inputs matching the
  repaired implementation. Dynamic, ARMv6 and nRF are clean `431293f9` runs.
- Each native profile has 43 checks, 13 negatives and **4,042 assertions**:
  364 staged/semantic, 13 mapping, 24 table, 17 geometry and 3,624 raster.
  ARMv6/nRF each have 42 checks and 13 negatives with target component/ABI/layout
  evidence. No board execution is claimed.

No broad or four-profile rerun was performed by this reviewer. The fresh saved
routes remain applicable; only the exact original binding defect was replayed.

## Resource and completion limits

All measured physical layouts are unchanged by the repair. The complete 196-slot
semantic payload reservation remains 7,056 bytes for Counter (+784 baseline),
7,840 bytes for native Analyzer (+1,568), and 7,056 bytes for target Analyzer
(+784). Selected complete Counter banks remain 30,616 bytes. Three Counter staged
slots plus metadata remain 112 bytes; five Analyzer slots remain 244 native/184
target. These full reservations must remain in P11's overlapping storage ledger.

The extra binding executes bounded finite checks; component layouts do not prove
complete timing, call-stack/IRQ overlap or linked allocator reachability. nRF's
11 selected bodies establish only the recorded direct-call allocation result.
The native staged-profile controls still use the actual Static model owner;
actual Dynamic coordinator/model-owner adoption is not inferred from them.

Finite P06 evidence now supports parent package PASS. It does not complete
DR-RD-001–004: actual coordinators and offer/replacement integration, complete
applications/hosts, integrated four-profile tests, full resource/workload and
target-execution dispositions, cutover and human implemented authorization
remain governed by P07–P12. No new deferred item or upstream decision is required.

Only review evidence and plan/conformance links are changed by this review.
Final record validation passed: `scripts/validate-governance.rb` and
`git diff --check`.
