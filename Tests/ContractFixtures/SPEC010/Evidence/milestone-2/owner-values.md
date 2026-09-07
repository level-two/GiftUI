# SPEC-010 T2.1 Owner Value Evidence

`GiftUIObservableState` now owns the exact profile-neutral limits, local
errors, successful operational values, closed result carrier, and candidate
disposition required by SPEC-010. The target lands atomically with its exact
`GiftUI`, `GiftUISemanticCore`, and `GiftUIExecution` package edges; it imports
no runtime, Interaction, failure, backend, platform, driver, OS/RTOS, HAL, or
hardware owner.

Focused tests exhaust all twelve error raw values, all nine operational raw
values, both candidate dispositions, every invalid next raw value, and every
operation-to-success-result row. Limit tests prove all capacities are nonzero,
registrations and staging each cover locations, equality to the location
limit succeeds, and the complete `UInt16.max` configuration remains valid.

Host layout evidence records six bytes for `ObservableStateLimits`, one byte
for each raw enum and for `ObservableStateResult`. Compile-time
generic witnesses prove every value is `Sendable`; value comparisons prove
`Equatable`. Cross-profile layout and allocation evidence remains assigned to
T8 and is not inferred from these host tests.

The registered source audit rejects alternate public/profile-specific result
surfaces, dynamic collections, existential storage, traps, exceptions, tasks,
and prohibited owner imports. No storage coordinator, profile packing,
application fact, diagnostic, or failure adapter is introduced.
