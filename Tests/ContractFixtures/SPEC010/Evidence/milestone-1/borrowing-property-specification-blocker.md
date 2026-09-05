# SPEC-010 Borrowing Property Specification Review

Disposition: **not ready for continued implementation of the public contract**

Date: 2026-09-05

## Approval blocker

The normative Public Contract declares:

```swift
public borrowing var attachment: _GiftUIObservationAttachment { get }
```

The pinned Apple Swift 6.3.3 compiler rejects that exact declaration before
any implementation body is considered:

```text
error: 'borrowing' may only be used on 'func' declarations
```

`scripts/contracts/check-spec-010-borrowing-property.sh` reproduces the result
from the repository root and preserves compiler identity plus stdout/stderr
under `.build/contract-generated/spec-010/compiler-blockers/borrowing-property/`.
The checked-in minimal fixture contains the exact modifier placement and no
unrelated GiftUI code.

## Required correction

The Specification must select valid Swift source spelling that preserves its
intended borrowing access to the attachment, update every normative/example
occurrence and compile expectation, and receive the required human amendment
approval. This review does not choose an accessor spelling or relax the
noncopyable sink contract; doing so would resolve contract source shape inside
implementation.

## Scope and residual risks

The accepted ownership, boundedness, outcome, lifecycle, failure, and profile
architecture remains internally coherent. No evidence suggests an RFC/ADR
change. After a source-level correction, the complete mutually recursive
declaration family still requires host, ARMv6, and nRF52840 compile/link proof,
including noncopyable sink ownership and target-image dependency inspection.

No production declaration, compatibility shim, alternate getter, placeholder
state-host protocol, or macro target was retained from the failed attempt.
