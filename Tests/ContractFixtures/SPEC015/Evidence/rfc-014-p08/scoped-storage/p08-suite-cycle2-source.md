# P08 grouped suite correction — cycle 2 source freeze

2026-10-15; input `0f9a7256`. The maintainer explicitly requested whole-suite
failure collection, grouped routine corrections and focused reruns. The
[diagnosis](p08-suite-collection-diagnosis.md) establishes the grouped causes.
This source freeze **consumes current cycle 2/2**; historical budgets and the
two-unproductive guard remain unchanged. Independent Strong assessment and actual
validation follow sequentially under the parent. No compiler/suite/runtime,
formatter, hardware/image operation or delegation occurred here.

The [manifest](p08-suite-cycle2-source-manifest.json) pins all ten implementation,
qualification and design files. Four Swift fixtures change: native Static G4
receives one private UInt32 tail field around its existing Optional; the direct
Interaction import fixes Embedded generic associated-type lookup; the two
quiesced consuming extractions become `let`; four implicated constructor calls
use unambiguous parentheses. Ownership, logical capacities and destruction order
remain the same. The native wrapper has no universal hard-coded byte extent:
size/stride/alignment and actual slot-within-wrapper bounds must hold on the
current ABI. The full wrapper and original Optional loans enclose the synchronous
reservation. Original stride/disjointness/inventory assertions remain; the complete
reservation metadata formula charges wrapper/tail/outer-layout bytes once. Added
locals, captures and frames still need emitted resource attribution. Embedded
raw regions and constants remain unchanged. A G4/G3 reorder was not adopted
because existing evidence did not establish G3's size versus stride.

The driver uses finite primary-error alternatives with exact generated filename
and a boundary derived from the trusted source's newline count. Closure and Task
oracles require the lifetime-dependent input escape primary; a sending/data-race
error alone cannot pass Task. Every primary must still match a permitted form;
unlocated, trusted-prefix, unrelated, wrong-site and crash output fails. The async
positive calls a synchronous consuming helper inside actual `withP08Storage`;
the negative attempts `await` of an async consuming helper from the same callback.
Its finite alternatives classify the synchronous-versus-async boundary at the
generated site; actual compiler output is pending. All **384/202** scoped labels,
five native controls and thirteen reuse labels per selected route are retained.

The new `--fresh-focused` option is explicitly separate from exact predecessor
reuse. It accepts complete named families, runs fresh preparation/current counter
module and every selected positive/negative control, and records other labels as
`not-run`. Failed prerequisites and positive twins block selected dependents.
Runtime and exclusivity groups are explicit selections. Process success means the
selected subset passed; receipt `collection_complete=false`/`passed=false` remains
unconditional, with separate `focused_passed`. Partial receipts cannot qualify as
complete predecessors. Existing full collection and strict `--resume-from`/legacy
identity checks are unchanged; no old compiled-source coverage is relabeled.

The [new applicability qualification](p08-suite-cycle2-applicability.json) pins
seven exact untouched component receipts, their original CounterScopedStorage
metadata hash, complete recorded Swift argv inventories/counts/digests, and the
new source hash. All seven excluded this source from compilation. They support
unchanged prerequisite applicability only; current counter modules and selected
controls are freshly compiled. Old qualifications/receipts remain immutable.

After source assessment, native fresh focused command (substitute matching Static
runtime/host receipts for the Static run):

```sh
scripts/contracts/run-spec-015.sh --profile macos-dynamic --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic --host-build .build/contracts/p08-scoped-host-ezcy1qan --fresh-focused --select-family so06-erasure-closure --select-family so06-closure-erasure --select-family so06-task --select-family so06-async --select-family runtime --select-family so06-native-exclusivity
```

ARMv6 uses its matching recipes with the four compiler families only. nRF uses
normal `--collect-failures` with its matching recipes, freshly collecting all
202 previously blocked controls. Native/ARMv6 focused output is **partial current-
source coverage**, even if every selected check passes. It does not close P08 or
make the old omitted controls current. Any further routine failures are collected
and dispositioned within this coherent correction's review/validation boundary;
no automatic third correction cycle is created.

Checks: `python3 scripts/contracts/test_p08_check_collection.py` passes **29
compiler-free tests**; Python AST, `bash -n scripts/contracts/run-spec-015.sh`,
qualification/source hash verification and `git diff --check` pass. No current
Swift syntax acceptance, behavior, complete suite, platform image, emitted resource
or fit result is claimed. All nine SO criteria, HC-RD-003/P08 and the historical
58,648-byte failure against 27,648-byte stack ceiling remain open.
