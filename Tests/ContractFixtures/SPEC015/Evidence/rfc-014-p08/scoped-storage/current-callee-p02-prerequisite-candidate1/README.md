# P08 maintained P02 prerequisite candidate 1 — STOP / withdrawn

Date: 2026-10-18. Base HEAD: `e16cb2d70eb8aa06a61f4ba0684dc80b8d4c3150`.

The [separate activity](../current-callee-p02-prerequisite-activity.md) authorized
one candidate and zero automatic source repairs for the reviewed
[21-selector/four-file proposal](../current-callee-safety-campaign1-result/grouped-correction-proposal.json).
The initial partial source patch failed static source inspection before any
formatter, compiler, test, or validation execution. Candidate **1/1 is consumed**;
no automatic repair or second variant was attempted.

## Exact attempted edits

The frozen [partial source diff](withdrawn-source.patch) has SHA-256
`f8599f872d7f01f86039f3933dba0932d0b74b0ff9f9b6d04f58c1848c283bbf`.
It contains only these four files:

| File | Partial candidate changes |
| --- | --- |
| `Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.swift` | Added ABI annotations at the eight reviewed stored-property selectors, existing CounterRoot initializer, and two helpers; added explicit internal arity 0–5 initializers and the required-argument internal CounterBadge initializer. |
| `Sources/GiftUI/DeclarativeView.swift` | Added `@usableFromInline` to the existing package EmptyView constructor. |
| `Sources/GiftUIMacros/ObservableStateHostMacro.swift` | Removed only the initial nonempty-State guard and explained the retained finite-shape/projection checks. |
| `Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift` | Added two zero-State test methods and partially extended existing positive/ABI-negative eligibility coverage; this construction is incomplete and invalid as detailed below. |

Candidate source SHA-256 values before withdrawal:

| File | SHA-256 |
| --- | --- |
| `Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.swift` | `2abe29596021e08b6c64b909ee034ed4afc6875ee8fe749f00c05be3bb92d4d2` |
| `Sources/GiftUI/DeclarativeView.swift` | `1451f910208735955fe7f188800d639f024ac1cb75fdb7dd49c5a3d835672c24` |
| `Sources/GiftUIMacros/ObservableStateHostMacro.swift` | `1b1a0e91b1694c11ec02e56af35ee861decec7b4662a0a0eca65e51029e0ad3d` |
| `Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift` | `bbac74f666acb91b92886c3e4a2d78bf2cf32b27ecb2a843aa69a4ca87c1d273` |

## Stop cause and withdrawal

The test edit attempted to derive each zero-State negative by replacing the full
`checkedSource(names: ["model"])` string inside an already transformed
`serializedSource()` variant. That full string includes the original Root header,
which the serialization helper has already replaced. The replacement cannot
remove the State and helpers, so the derived case is not a genuine zero-State
negative. This is a test construction defect found by static inspection, not a
compiler or contract failure.

The same partial patch called `serializedSource(names: [])` before changing the
helper's existing no-argument signature. The intended zero-State generic-header
and enclosure matrix extensions had not yet been applied. All 17 original test
methods were retained; two added methods made 19 declarations in this partial
patch, but no test result is claimed.

The implementing agent reported the defects immediately and stopped source edits.
The coordinating agent directed archival of the exact partial diff and restoration
of only these four files to HEAD. Restoration withdraws this failed initial
candidate; it is not a source repair, retry, second candidate, or budget reset.
The resulting commit contains evidence and derived documentation only.

The preexisting dirty analyzer sources, nRF CMake/build script, Raspberry Pi build
script, and `scripts/contracts/__pycache__/` were excluded from both the source
patch and restoration/commit scope.

## Validation boundary and remaining gates

Only source reading and static diff inspection occurred. No formatter, compiler,
macro test, producer, generated-output patch, or validation script ran. A fresh
candidate-specific recipe was not frozen. Fresh macro regression, maintained P02
(full CounterPresentation, AnalyzerDeclaration, registered P04), registered P07,
schema-4 activation, and all 384 native controls remain unrun for this activity.
All dependents are unrun; there is no source acceptance or P08 acceptance claim.

The original failed safety campaign and all prior E/F/checked-State allowances
remain historical evidence with their existing consumed budgets. Complete
current-callee interpretation, safety, strict cold, resources, and P08/R07/T8.1
remain open. No continuation or additional source allowance is implied.
