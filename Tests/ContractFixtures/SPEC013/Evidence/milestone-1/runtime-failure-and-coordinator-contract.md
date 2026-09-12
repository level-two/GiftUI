# T1.5 Runtime Failure and Coordinator Contract

Date: 2026-09-12

`GiftUIRuntimeCore` now contains the exact five-case `RuntimeOwnerFailure` and
the corrected, approved `GiftUIRuntimeProfileCoordinator` surface. The
coordinator remains generic over the SPEC-009 endpoint, SPEC-012 drawing sink,
typed action handler, model-target access, and noncopyable profile storage.

The `ActionModelTargetAccess` declaration was placed in its authoritative
`GiftUIInteraction` owner as the declaration-only part of the explicit
SPEC-011/SPEC-013 integration handoff. SPEC-011 T5.1-T5.6 subsequently supplied
the dispatcher, concrete target-composed adapter, and mutation-phase join,
unblocking SPEC-013's pending profile bindings.

The sibling runtime failure adapter is still the only target that imports
Runtime Core and the SPEC-003 failure authority. Its total validation table
maps all seven `RuntimeProfileValidationError` values to their exact condition,
origin, runtime scope, and containment. Its focused-owner seam preserves the
exact five-case value and `ExecutionContext` supplied by SPEC-009 correlation.
Runtime Core imports neither failure module.

Focused checks passed under both repository-supported compiler installations:

- Xcode Apple Swift 6.3.3: four adapter tests passed;
- repository Apple Swift 6.3.2, also used by the cross-build toolchains: four
  adapter tests passed.

Both executions prove `MemoryLayout<RuntimeOwnerFailure>.size <= 2` and
`stride <= 2`; the current result is two bytes. The total mapping fixtures also
cover every validation case and every focused-owner carrier case.
