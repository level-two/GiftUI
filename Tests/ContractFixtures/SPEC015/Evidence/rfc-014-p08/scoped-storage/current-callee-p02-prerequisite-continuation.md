# P08 maintained P02 prerequisite — bounded continuation, 2026-10-18

Eugene explicitly authorized continuing after the [withdrawn candidate 1 STOP](current-callee-p02-prerequisite-candidate1/README.md): “Yes, allowed, please go ahead.”
This is **one new source candidate with zero automatic source repairs**, followed
by one staged validation attempt if static source inspection passes. Candidate 1
remains consumed (1/1); this separate continuation starts at candidate 0/1.
Historical E/F 1/1 with zero repairs and checked-State initial 1/1,
corrections 2/2 remain closed. No other source or validation budget is reset.

The reviewed source scope remains the original [21 selectors in four files](current-callee-safety-campaign1-result/grouped-correction-proposal.json).
The prior defect was in the test-family extension, not in a new production
contract. Independent Sol 6.1 High read-only review fixes the test construction
before source editing:

- `checkedSource` accepts an explicit `header` while keeping its existing
  field/helper assembly; `serializedSource(names: [String] = ["model"])` passes
  `names` directly and supplies the finite ABI host header. No post-construction
  replacement of a different host header is permitted.
- The original 17 test methods remain. A finite zero-State positive and ordinary
  zero-State negatives are added. The existing finite positive, ABI, generic,
  and enclosure matrices each run for `["model"]` and `[]` independently.
- Each negative replacement must match exactly once and change the intended
  tokens; every `[]` input must have no State declaration or checked helper.
  The zero-State expanded visitor must have no State visit. Existing private
  State and nonempty original-wrapper controls remain.

After a static four-file diff audit, update the derived checked-State design
note and commit the single source candidate. Freeze candidate-specific input
hashes, command list, output directory, and stop rules before execution. Run
the maintained macro family, then one fresh P02 producer with full
CounterPresentation, AnalyzerDeclaration and registered P04, then P07, schema-4
activation, and complete counter 384 controls. Stop at the first material
failure; dependent stages remain unrun. No compiler retry, source repair,
generated-output patch, broader lowerer support, resource limit change,
hardware operation, or P08 acceptance follows automatically.

Passing this prerequisite alone still leaves complete current-callee
interpretation, safety, strict cold, resources, and P08/R07/T8.1 open.
