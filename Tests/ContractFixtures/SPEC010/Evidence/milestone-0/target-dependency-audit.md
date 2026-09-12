# SPEC-010 T0.2 Target Dependency Audit

The exact package registry records `GiftUIMacros` as a host-only macro target
with only pinned SwiftSyntax compiler-support dependencies. It is not a
product; its only consumers are the `GiftUI` build-time macro edge and the
focused macro test target. Four-profile generated-host symbol-closure evidence
contains no `GiftUIMacros`, SwiftSyntax, compiler-plugin, or macro
implementation symbols in a target image.

`GiftUIObservableState` imports and directly depends on exactly `GiftUI`,
`GiftUISemanticCore`, and `GiftUIExecution`. Its focused tests name only the
owner and those three dependencies. The narrow
`GiftUIObservableStateFailureAdapterFixture` depends on exactly Observable
State and Failure Core, keeping failure mapping outside the owner.

The target-boundary check fails on any additional macro consumer, owner import,
runtime, Interaction, backend, platform, driver, OS/RTOS, HAL, hardware, or
application-model dependency. The repository-wide exact dependency checker
separately rejects package/registry drift, unknown or duplicate edges, and
cycles.
