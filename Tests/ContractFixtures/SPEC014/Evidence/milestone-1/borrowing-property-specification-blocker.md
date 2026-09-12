# T1.2 Borrowing Property Compiler Blocker

Disposition: **resolved by explicitly approved Specification correction**

Date: 2026-09-12

## Blocker

SPEC-014 normatively requires declarations such as:

```swift
package protocol RasterSurface {
    borrowing var descriptor: RasterSurfaceDescriptor { get }
    borrowing var writableCapacityBytes: UInt32 { get }
    borrowing var presentationResponsibilityAccepted: Bool { get }
}
```

The pinned Apple Swift 6.3.3 compiler rejects the property before any
conformance or implementation body is considered:

```text
error: 'borrowing' may only be used on 'func' declarations
```

The failure was reproduced through the repository-local SwiftPM build used by
`GiftUISurfaceCoreTests`. The exact diagnostic is independently reproduced by
`scripts/contracts/check-spec-014-borrowing-property-blocker.sh` from the
minimal checked-in compiler fixture.

The same unsupported modifier appears on four `DisplayPayloadWriter`
properties, four `DisplayTarget` properties, three `RasterFrameSink`
properties, and five `RasterBackendEndpoint` properties. Correcting only the
first protocol would leave T1.4 and T1.5 blocked by the same parser rule.

## Scope

No ordinary-property substitution, accessor rewrite, compatibility shim, or
weakened ownership contract has been committed. The attempted T1.2 protocol
and recording conformer were removed, and T1.2 remains open. Stateful surface,
display, endpoint, and downstream implementation must pause at this boundary.

The repository has an approved precedent in SPEC-013: after observing the same
compiler diagnostic, the maintainer explicitly approved correcting all
compiler-invalid `borrowing var` declarations to ordinary read-only
properties. Applying that correction to SPEC-014 is still a Specification
decision and is not inferred from the precedent or the implementation request.

## Resolution

On 2026-09-12 the maintainer explicitly approved correcting every affected
SPEC-014 property to an ordinary read-only `var` requirement while retaining
the intended immutable borrowed-use semantics. The authoritative
Specification now contains the corrected declarations. The compiler fixture
and diagnostic remain checked in as the reproducible reason for the amendment;
they no longer block T1.2, T1.4, or T1.5.
