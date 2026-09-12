# SPEC-012 T6.3 Static Canvas Generation Rejection Evidence

The checked generator boundary evaluates every candidate before generated
Swift is accepted. `static-canvas-rejection-cases.yaml` fixes fourteen
independent candidates and their exact first diagnostics:

| Candidate | Required rejection |
|---|---|
| zero ID | callable ID is zero |
| 65,536 ID | callable ID exceeds `UInt16` |
| fourth configured case | callable case count exceeds limit |
| missing switch case | switch coverage is incomplete |
| duplicate switch case | switch coverage is duplicated |
| `Double` | unsupported capture type |
| four `GeometryScalar` fields | capture bytes exceed limit |
| `[Point]` | dynamic collection capture is prohibited |
| `any Equatable` | existential capture is prohibited |
| `HeapBox<GeometryScalar>` | heap-owned box capture is prohibited |
| `weak FixtureModel` | weak capture is prohibited |
| `unowned FixtureModel` | unowned capture is prohibited |
| `FixtureModel` | class reference capture is prohibited |
| `@escaping (Size) -> Void` | closure capture is prohibited |

The positive generated-source audit separately requires the exact borrowing
capture parameter, complete dense switch, and manifest byte counts. It rejects
assignment or `copy` of the whole capture storage, `@escaping` storage, an
array of capture records, and a retained-closure fallback. The generated table
contains only direct cases that call the scoped drawing API.

Reproduce with:

```sh
scripts/contracts/check-spec-012-static-canvas-manifest.rb
scripts/contracts/check-spec-012-module-contract.rb
swift test --filter generatedStaticCanvas
```

This is host generator and runtime-fixture evidence. Cross-profile SIL/symbol,
allocation, stack, RAM, flash, and production source-analysis integration
remain assigned to T6.5 and SPEC-013.
