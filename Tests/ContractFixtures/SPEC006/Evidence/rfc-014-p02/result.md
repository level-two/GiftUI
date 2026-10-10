# P02 typed declarations and finite lowering receipt — 2026-10-10

**P02 passed; P03 is next.** This is the declaration package exit for SPEC-006
T10.1, DV-RD-001 and the declaration portions of DV-001/002/011/015–017. It does
not close T10.1, the full source-inventory/application requirement or any Spec.

Direction correction: `117f49cf`. Implementation and focused suite:
`53de09c62afe040dab7fe7829ad168a2dcc4b7bc`. All four final runs used that clean
implementation commit. The [validation snapshot](validation.json) preserves
source/recipe/compiler/SwiftSyntax hashes, exact commands, logs, module/object
sizes and hashes, native executable identities, and unique generated run paths.
Every recorded input and artifact hash was rechecked before this receipt.

## Delivered boundary

The existing GiftUI files now expose one fixed-domain View ABI with inferred
Body, scoped typed reads, package-only key/read construction and explicit leaf
dispatch. GiftUIMacros owns the finite source-lowering build invocation and the
state-host accessor macro. There is no separate lowering target, duplicate View
implementation or migration conditional. The existing Dynamic Canvas profile
conditional remains part of the preexisting P06 surface.

Generated application schemas contain nonescapable read facades, nested scoped
aggregates, owned typed scalar results and checked indexed access. Generated
Presentation preserves conditional selection, lazy reads and typed first-failure
order. The lowerer emits no topology. Pure scalar helpers retain their signatures;
view helpers receive only the domain/read context their composition requires.

## Validation

All commands below exited successfully with project-local Apple Swift 6.3.2:

```text
scripts/contracts/run-spec-006.sh --profile macos-dynamic --compiler-baseline rfc-014
scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014
scripts/contracts/run-spec-006.sh --profile raspberry-pi-armv6 --compiler-baseline rfc-014
scripts/contracts/run-spec-006.sh --profile nrf52840-embedded --compiler-baseline rfc-014
```

| Configuration | Driver checks | Execution / target evidence |
| --- | ---: | --- |
| macOS Dynamic | 28 | 120 assertions, zero failures |
| macOS Static | 28 | 120 assertions, zero failures |
| Raspberry Pi ARMv6 | 27 | Separate modules/objects; ARMv6, VFP register arguments |
| nRF52840 Embedded | 27 | Separate modules/objects; Cortex-M4/v7E-M, VFP register arguments |

Each run separately compiles GiftUI, CounterSchema, CounterPresentation,
SignalAnalyzerDomain values, AnalyzerSchema, AnalyzerPresentation and the
declaration host. Cross profiles compile the same host oracle and inspect its
object; they do not execute on target or produce a linked application/firmware.
All generated ARMv6/nRF artifacts remain under their mandated `.build` roots.

The 120 native assertions cover digits 0–9; arities 0–5; nested/free/member view
helpers; stateless and state-host accessor dispatch; optional, conditional and
switch selection; nested facade lifetimes; checked indexed failure; lazy
`&&`/`||`/`??`; argument first-error precedence; and stopping before a later
sibling's body. Six existing macro expansion goldens and both UInt16
declaration-limit controls pass in the host macro check for every profile.

Twelve negative cases pass per profile: owned facade escape, mismatched custom
Body domain, mixed child domains, missing custom body, direct sixth child,
escaping read closure, unknown call/effect, unchecked inout, effect disguised
as a view modifier, unknown model member, and external key/read construction.
Lowering failures must identify original file/line/column and leave no generated
Presentation output. Lifetime negatives compile through object emission because
the relevant escape diagnostic occurs after type checking.

Formatting/lint, the 84-target dependency graph, explicit driver registry, shell
syntax, governance/authority/task-evidence validation and `git diff --check`
pass. The registered broad repository gate remains P10.

During development, the macro golden runner initially searched the wrong module
directory, then exposed a missing C shim import. Reading SwiftPM's actual build
plan supplied the pinned prebuilt and shim paths; the next complete native run
passed. The six goldens now expect the approved typed accessor. No contract or
negative expectation was weakened to obtain the final passes.

## Remaining boundary

The P01 route inventory remains authoritative for the finite corpus. P02 closes
its declaration/grammar portions and SY01 controls. Shared routes still require
P03 checked ownership/State/mutations, P04 actual semantic records, P05 actions,
P06 Canvas, and P08/P09 complete counter/analyzer integration. The Analyzer
fixture compiles three actual Domain value files and nested read syntax; it is
not the entire application. DeclarationHost is a test oracle with scoped backing,
not evidence for live-owner storage validity or runtime transactions.

Downstream consumers still require migration to the single ABI; a whole-tree
build is not yet claimed. Historical conformance is reproducible at its pinned
revision. Object file sizes in the snapshot are artifact identities, not RAM,
heap, stack or complete-image resource measurements. P10–P12 retain functional,
resource, connected-target disposition and adoption obligations. No new package,
optional deferred item, exception or architecture change was introduced.

- [Shared sequence](../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md)
- [Owner plan](../../../../../docs/implementation-plans/spec-006-implementation-plan.md)
- [Design note](../../../../../docs/implementation-designs/spec-006-finite-source-lowering.md)
