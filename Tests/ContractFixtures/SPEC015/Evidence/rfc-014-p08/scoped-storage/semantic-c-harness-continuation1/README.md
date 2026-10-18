# Semantic C focused harness continuation — prepared proposal

Fixed source **f2325b85**, [initial result5105de84](../semantic-c-candidate1-result/README.md)
preserved. **Independent READY required before execution.** No source or sourcebudget
change; ONE1/1 fixed/ZERO automatic SOURCE repairs, all historical budgets unchanged.

Three fixture closures lack explicit typed throws, producing incidental anyError→
SemanticExpansionError errors at line16. Add only `(store) throws(SemanticExpansionError) in`
(the existing maintained factory callback form). Original closure bodies/signatures/
borrow/lifetime/negative intents unchanged. Pin the already observed internal-access
and Escapable diagnostics exactly, each one error; positive requires zero errors.
Corrected controls are proposed, not yet compiler-qualified. No source API change.

Initial86/87 body selection is a single noncanonical mangling prediction. Actual
root is `$s18GiftUISemanticCore19SemanticRecordStoreV9borrowingACyxGAEh_tcfC`, fresh
function546/offset4111261/kind1/1BB, exact initializer borrowed signature. The
[correction map](harness-correction-map.json) pins its full raw record; replaces
one name, no regex/closure/default/defer substitution. Remaining86 targets stay
exact. All87 must uniquely match nonzero serializedkind/positiveBB; corrected root
must additionally equal its pinned complete raw record. Original failure retained.

After review, execute once:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/semantic-c-harness-continuation1/run.py
```

Static `--validate` PASS; no compiler/tests/decoder/runtime or physical selection
continuation executed. New absent `.build/contracts/p08-semantic-c-harness-continuation1/`.
1293 frozen current inputs/artifacts qualify reuse of macro17/lower25/fourvariants/
prior70privacy/11decodes/interpreter/twocaptures/49macro+251provider seals. Run only
three corrected typed controls, same87 physical gate, then conditional fresh same42
SIL after both pass. No macro/module/variant/priorprivacy/decoder/interpreter/object
repeat. Compiler flags/source/import/plugin identical; cache/output/fixture paths
only move. Gather all three results; any failure blocks consumer collection.

No source repair/reset or acceptance weakening. Full actual C/cold/callback cost,
14loan/Optional/lifetime/provenance/exclusivity/failurecleanup/safety/strictcold/P08
remain unqualified. Protected external five/pycache untouched.
