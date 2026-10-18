# Explicit-return escape control — proposed focused continuation

Fixed source **f2325b85**. [Frozen result ea83fb76](../semantic-c-harness-continuation1-result/README.md)
qualifies87 bodies and checkedborrow/internalnegative. Escape stderr explicitly
warns the view expression is unused; callback discarded it as Void, so it never
exercised an escaping result. This is a harness flaw, not lifetime defect evidence.

**Independent READY before execution.** One exact control pair replaces only the
reader callback: positive explicitly declares `-> UInt32` and `return 0`; negative
explicitly declares `-> SemanticRecordView<UInt32>` and `return view`. Both retain
valid typedthrows outer factory/borrowedStore setup. Explicit result/value prevents
Void inference and expression discard. Positive requires zeroerrors; negative
requires exactly the existing Escapable Result diagnostic. No Copyable violation,
new constructor, ownership/lifetime API edit or speculative compiler variant.
No compiler pretest; the pair remains unqualified until the reviewed run.

After READY, execute once:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/semantic-c-escape-continuation1/run.py
```

Static `--validate` PASS;1305 current frozen inputs. Only the explicit-return
positive/negative pair then conditional fresh42SIL;87physical/prior72privacy and
macro17/lower25/fourvariants/index11/interpreter/captures/seals are retained without
repeat. Prior87 result is pinned and verified, not reselected. Same compiler/source/
import/plugin flags; only cache/output/fixture paths move. New absent output
`.build/contracts/p08-semantic-c-escape-continuation1/`. No redundant archive.

ONEsourcecandidate1/1 fixed/ZEROautomaticSOURCErepairs, oldbudgets unchanged. No
source/compiler/tests/decoder/runtime executed during preparation. Any failed
control blocks SIL and freezes evidence; no automatic source repair or fixture
retry. Actual C/cost/safety/14loans/Optional/lifetime/strictcold/P08 unqualified.
