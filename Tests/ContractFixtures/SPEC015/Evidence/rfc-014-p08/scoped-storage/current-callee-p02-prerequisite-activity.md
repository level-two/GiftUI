# P08 maintained P02 prerequisite correction — 2026-10-18

The [first maintained safety campaign](current-callee-safety-campaign1-result/README.md)
stopped at P02 with 32 primary ABI diagnostics. Its input provenance excludes
the E/F source changes from that compile. This activity addresses that newly
identified prerequisite; it does not reopen the E/F candidate (1/1, zero repairs)
or the earlier checked-State activity (initial 1/1, corrections 2/2).

Eugene's 2026-10-18 instruction to execute P08 authorizes **one candidate and
zero automatic source repairs** for the exact [21-selector, four-file proposal](current-callee-safety-campaign1-result/grouped-correction-proposal.json).
Independent Sol 6.1 High design review found that proposal ready with a fresh
recipe and one P02 producer run. Astra Medium classified the zero-State guard as
a replaceable implementation choice within SPEC-006/010 and ADR-036/039, and
confirmed this separate bounded assignment. The reviewed files are:

1. `Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.swift`: 18 exact
   authored selectors from the proposal, preserving arity, access, required
   arguments, defaults, helper order, and failure behavior.
2. `Sources/GiftUI/DeclarativeView.swift`: ABI-only qualification of the
   existing `EmptyView` constructor.
3. `Sources/GiftUIMacros/ObservableStateHostMacro.swift`: permit an empty
   State declaration set only when all existing finite shape, signature, ABI,
   evaluation, and enclosure checks pass. Preserve nonempty projection checks.
4. `Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift`: extend the
   existing eligibility family with a genuine finite zero-State positive and
   ordinary/private/incomplete-shape negatives.

Before validation, update the derived checked-State design's nonempty guard and
freeze a fresh candidate-specific input/command/output recipe. The old campaign
runner has pinned old input hashes and output and must not be reused. Validate
the recipe statically, then run the existing 17 macro tests plus added cases,
one fresh maintained P02 producer (full CounterPresentation,
AnalyzerDeclaration, registered P04), then registered P07, schema-4 activation,
and complete native counter 384 controls in order. Fresh receipts must qualify
changed GiftUI and macro inputs. Stop at the first material failure and preserve
all dependents as unrun. No generated-output patch, retry, automatic repair,
broader lowerer feature, resource change, or acceptance claim follows.

Passing this prerequisite would still leave complete current-callee
interpretation, strict cold, resources, and P08/R07/T8.1 open. The original
failed campaign and all historical allowances remain evidence, not a reset.
