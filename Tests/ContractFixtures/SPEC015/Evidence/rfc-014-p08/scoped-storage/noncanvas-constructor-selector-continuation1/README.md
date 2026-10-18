# Ten static-root selector correction — proposed continuation

Fixed source **d65b127c**; [initial result](../noncanvas-constructor-candidate1-result/README.md)
retains66/76 selection and correctly blocked SIL. Every unmatched selector omits
the demangler's leading `static `. [Exact map](selector-correction-map.json) pins
all ten intended declaration identities, original source signatures/constraints,
full mangled names and current raw module records (kind1/positiveBB). Closure,
default and defer records are excluded. No source failure or absent body was found.

**Independent review before execution.** Proposed list changes exactly ten names
in the same76-target gate; the prior66 selectors and acceptance conditions stay
unchanged: exactly one root record, serialized_kind nonzero, positive basic blocks;
corrected ten must additionally equal their pinned complete physical records.
No original selector file/result is modified and no regex is broadened.

Focused command after review:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/noncanvas-constructor-selector-continuation1/run.py
```

Fresh absent output `.build/contracts/p08-noncanvas-constructor-selector-continuation1/`.
Reuse qualified macro17/lower25/fourvariants/privacy70/11decodes+interpreter/two
objectcaptures and exact49macro+251provider seals. No repeated compiler macro/module/
privacy/decoder/interpreter/object stage. Only76selection then conditional fresh
same42-source SIL. Compiler flags/imports/source list/plugin unchanged; only cache
and output paths move. Input/recipe freezes qualify every reused artifact/result.
No compiler/test/decoder/runtime or selection continuation executed in preparation.

This is reviewed harness qualification, not a source repair, new source candidate
or weakened acceptance. Candidate1/1 fixed/zeroautomaticSOURCErepairs; all older
budgets preserved. Consumer/safety/14loan/Optional/lifetime/strictcold/P08 remain open.
