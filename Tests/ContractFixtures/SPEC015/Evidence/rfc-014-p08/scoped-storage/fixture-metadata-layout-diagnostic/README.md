# One-shot existing fixture metadata layout diagnostic

Prepared at `63bf7808`, after the focused independent design PASS. This is the
single 31-root diagnostic authorized by the structural memory assessment, **not
an implementation candidate or acceptance receipt**. No compiler was invoked
during preparation. Prior closed allowances remain closed.

From the repository root, Luna executes exactly once:

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/fixture-metadata-layout-diagnostic/run-once.py
```

Only after successful compilation, read the existing object (no further compiler):

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/fixture-metadata-layout-diagnostic/decode.py
```

`run-once.py` is copied unchanged from the earlier physical-representation
diagnostic. It verifies pinned inputs and creates an invocation marker before
the one subprocess; it has no repair/retry loop. Scratch and cache already exist
at `.build/nrf52840/p08-fixture-metadata-layout-diagnostic/`. Stdout/stderr,
invocation argv, result and artifact hashes are retained there. Report failures;
do not edit the suffix and retry under this allowance.

`baseline.argv.json` is the exact current `P08CounterRuntime` command from
`p08-counter-nl16wjri/result.json`. `compile.argv.json` changes exactly four token
values: CounterScopedStorage source copy, module-cache path, module output and
object output. Compiler, semantic flags, module/package names, every other source
and all imports remain unchanged. The copied source is the exact original bytes
plus `accessors.swift.txt`; `source-append.diff` records the entire diagnostic
change. `prepared.json` pins the receipt/object/layout, actual receipt inputs,
compiler/plugin, all actual source tokens, imported module/object artifacts and
strict helper/diagnostic scripts. The frozen baseline is untouched.

`roots.json` defines exactly 31 exported roots: size/stride/alignment and offset
for each of seven existing types, then cursor/maximum alignment/rounded extent.
The suffix uses scalar checked addition and alignment arithmetic only. It creates
no metadata object, array table, alternate runtime or linked image. Packing uses
one complete stride per object, with alignment before each and final roundup.

The decoder records actual root binding, visibility, symbol table/index and body
proof. Valid global defined function exports may be DEFAULT or PROTECTED;
weak/undefined/data/hidden roots are rejected. The unchanged maintained strict
helper proves each root's executable Thumb bounds, complete constant body and
any admitted tail/relocation or finite inline literal. No new byte grammar is
introduced. Independent host checked arithmetic must reproduce all seven offsets
and three summaries. Facts are preserved even when the pack does not fit the
existing 34,720-byte/eight-aligned donor interval.

This measures the **existing** full P08ReuseFingerprint and other six existing
types. It does not measure the proposed future linear mutable baseline, caller
custody/phase/header stack bytes, constructors or compiled stack paths. A fitting
pack proves only this declared metadata layout; it is not permission to omit any
of those costs or claim P08 fit. `diagnostic_only=true`,
`acceptance_receipt=false` remain unconditional. No linking, target execution,
images, maintained source changes, compiler retries or resource-limit changes.

Preparation checks and exact hashes are in `preparation-checks.json`: Python AST,
all input hashes, 31-root inventory, seven types, exact argv substitutions/imports,
exact appended copy and precreated output directory. These checks did not compile
or decode an object.
