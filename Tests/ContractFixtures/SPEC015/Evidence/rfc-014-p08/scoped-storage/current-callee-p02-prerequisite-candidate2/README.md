# P08 maintained P02 prerequisite candidate 2 — source only

Date: 2026-10-18. Base HEAD: `88214f619b6113471dcc2a7f390af337db3a1e60`.

The [explicit continuation](../current-callee-p02-prerequisite-continuation.md)
authorizes one new candidate and zero automatic source repairs after the
[withdrawn candidate 1 STOP](../current-callee-p02-prerequisite-candidate1/README.md).
This continuation's candidate **1/1 is consumed**, repairs **0/0**. Static source
diff inspection found no exactness or scope issue. This is not source acceptance
or a test result. All prior consumed budgets remain closed.

## Exact source scope

The [four-file patch](source.patch) has SHA-256
`14ac477b241fc25acae5946d7f252eac7f57ced1eeec4c34833d6bd9d6e8d557` and implements the reviewed
[21-selector proposal](../current-callee-safety-campaign1-result/grouped-correction-proposal.json):

- Counter fixture: ABI annotations on eight stored properties, the existing
  CounterRoot initializer and two helpers; explicit equivalent internal arity
  0–5 constructors; explicit ABI-usable internal CounterBadge constructor with
  its required UInt8 value argument and no default.
- EmptyView: only `@usableFromInline` on its existing package constructor.
- ObservableStateHostMacro: only removal of the initial nonempty-State guard
  and its explanatory comment. Projection equality and every finite host,
  alias/domain, evaluation/ABI and enclosure check remain.
- Existing macro test family: direct `checkedSource(names:extra:header:)`
  construction; `serializedSource(names: [String] = ["model"])` forwards names.
  No post-construction header replacement. All 17 original methods remain;
  two methods add true finite zero-State and ordinary zero-State coverage.
  Finite positives (3), ABI negatives (17), generic negatives (8), and enclosure
  negatives (8) each run independently for `["model"]` and `[]`. Matrix
  replacements assert one match and changed parsed tokens. Every empty input
  and expansion rejects State/backing/helper tokens; empty expansions reject
  State visits. Existing private-State/original-wrapper controls remain.

## Frozen source inputs

| File | SHA-256 |
| --- | --- |
| `Sources/GiftUI/DeclarativeView.swift` | `1451f910208735955fe7f188800d639f024ac1cb75fdb7dd49c5a3d835672c24` |
| `Sources/GiftUIMacros/ObservableStateHostMacro.swift` | `1b1a0e91b1694c11ec02e56af35ee861decec7b4662a0a0eca65e51029e0ad3d` |
| `Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.swift` | `2abe29596021e08b6c64b909ee034ed4afc6875ee8fe749f00c05be3bb92d4d2` |
| `Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift` | `0cd0244d1f0194cd927e7eee6bedce73a1a6f0d1146a4cb42dc45e9b8a9f60a3` |

The [machine-readable receipt](source-receipt.json) records exact methods,
shape counts, source hashes, and excluded dirty files. The derived
[checked-State note](../../../../../../../docs/implementation-designs/spec-015-p08-checked-state-serialization.md)
describes the guarded zero-State exception without changing contract authority.

## Execution boundary

No formatter, compiler, tests, producer, validation, generated-output repair,
hardware operation or deployment ran. A candidate-specific validation input
freeze, command list, output directory and stop rules must precede execution.
The maintained macro family must precede one fresh P02 producer with full
CounterPresentation, AnalyzerDeclaration and registered P04, then registered
P07, schema-4 activation and all 384 counter controls. Stop at the first material
failure; dependent stages stay unrun. Zero automatic source repairs apply.

Preexisting dirty analyzer sources, nRF CMake/build script, Raspberry Pi build
script and pycache are excluded from the patch and commit. Full current-callee
interpretation, safety, strict cold, resources and P08/R07/T8.1 remain open.
No broader lowerer support, resource-limit change or acceptance follows.
