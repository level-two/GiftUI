# Grouped closure initial1 — source and command freeze

Initial1/1 is consumed; corrections0/2. Implementation follows the
[caller-amendment PASS](../p08-grouped-module-closure-caller-amendment-review.md).
The twelve-file [source diff](source.diff) contains exactly the reviewed 36
attribute-line removals (33 sites). Targeted repository-configured formatting
changed no bodies, access, signatures, hints, storage or lifetime annotations.
No compiler has run for this candidate.

Run from the repository root, once:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/grouped-module-closure-initial1/run.py
```

Estimated sweep time: 3–10 minutes, depending on early blockers and the actual
42-source host compile. The runner prints each owner disposition as it completes.
`--validate` checks the freeze without invoking tools; it has passed.

[prepared.json](prepared.json) freezes exact argv arrays from the established
Swift6.4 compiler JSON recipes, the current 25-owner source/import DAG and unchanged
policy flags. All project `-I` paths resolve only to the new output's qualified
module directory. Each owner emits into its own directory; only exit0 outputs
containing both module and object are published. Failed partial modules remain
unavailable. The runner attempts all independent owners, marks dependent owners
blocked and preserves complete logs plus source/output/import hashes. It never
edits source or retries. Output is `.build/contracts/p08-grouped-module-closure-initial1`;
its preexistence rejects execution.

The unchanged macro tool is reused from the accepted fresh `22589fec` rebuild,
17 maintained tests and actual lowerer regression. Its current binary, macro/test
sources, registered methods and prior test log are frozen; the macro sources match
that accepted receipt exactly. No old GiftUI/project module is admitted. Counter
is lowered afresh using the established command and full working macOS DYLD
framework/library paths, and all three generated files must match accepted bytes.
The 299-entry [input freeze](input-freeze.json) includes current sources, protected
five files/pycache, compiler/tool and recipe provenance; [recipe-freeze.json](recipe-freeze.json)
protects the runner, argv, input freeze and source diff.

This is the compile closure only. Fresh privacy controls still gate physical
42-origin/private-callee/concrete-host qualification; safety and strict host-first
cold follow only their prior complete gates. Default CMO, key-failure witness
costs, specialization, zero heap and P08 acceptance remain unproved. Source/API/
contract choices escalate; no correction is implicit in this prepared runner.
