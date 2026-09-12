# T1.4 Runtime Profile Storage Compiler Blocker

Disposition: **resolved by explicitly approved Specification correction**

Date: 2026-09-12

## Blocker

SPEC-013 normatively requires this exact declaration:

```swift
package protocol RuntimeProfileStorage: ~Copyable {
    associatedtype StructuralIdentity: Equatable & Sendable
    static var profile: RuntimeProfileKind { get }
    borrowing var limits: RuntimeProfileLimits { get }
    borrowing func audit() -> RuntimeProfileValidationResult
    mutating func resetAttemptStorage()
    mutating func resetAllStorage()
}
```

The pinned Apple Swift 6.3.3 compiler rejects the property before any
conformance or implementation body is considered:

```text
Sources/GiftUIRuntimeCore/RuntimeProfileStorage.swift:5:5: error:
'borrowing' may only be used on 'func' declarations
```

The failure was reproduced through the repository-local SwiftPM build used by
the focused SPEC-013 tests. The same compiler limitation previously affected
SPEC-010 and required an explicitly approved source correction before its
implementation resumed.

The immediately following T1.5 coordinator contract uses the same unsupported
modifier on `profile`, `storageAudit`, `executionContext`, and `isQuiescent`.
Those declarations will encounter the same parser restriction even after T1.4
is corrected unless the Specification review covers every `borrowing var`
declaration in SPEC-013.

## Scope

No alternate property spelling, compatibility shim, copyable-only storage
protocol, or weakened ownership contract has been committed. T1.4 remains
open. Because T1.5 requires the coordinator protocol surface and Milestone 2
requires the completed Milestone 1 storage contract, affected SPEC-013 work
must pause at this gate under the plan's readiness rule.

The likely source correction is to remove the invalid modifier from all five
read-only properties while retaining `{ get }`, matching the approved SPEC-010
precedent, but that is a Specification decision and is not inferred by
implementation.

## Resolution

On 2026-09-12 the maintainer explicitly approved that correction and directed
that SPEC-013 remain approved. The authoritative Specification now declares
all five properties as ordinary read-only `var` requirements. This evidence is
retained as the reproducible reason for the source correction; it no longer
blocks T1.4 or T1.5.
