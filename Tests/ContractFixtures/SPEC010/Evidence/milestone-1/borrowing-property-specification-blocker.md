# SPEC-010 Borrowing Property Specification Review

Disposition: **resolved by approved source correction**

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

Commit `95c600e` introduced the repository-root reproducer for the rejected
spelling. It remains as historical evidence but is no longer registered by the
contract driver; the approved correction is guarded by a separate positive
witness.

## Resolution

On 2026-09-05 the maintainer directed the Specification correction. The
invalid modifier was removed from the property declaration:

```swift
public var attachment: _GiftUIObservationAttachment { get }
```

A read-only, nonmutating getter borrows the noncopyable sink for the access and
does not consume or mutate it. The public `sink.attachment` use, complete-sink
transfer, non-forgeable attachment, and all accepted ownership rules remain
unchanged. `check-spec-010-attachment-property.sh` now compiles a positive
witness that reads the attachment and subsequently consumes the same sink.

## Scope and residual risks

The accepted ownership, boundedness, outcome, lifecycle, failure, and profile
architecture remains internally coherent. No evidence suggests an RFC/ADR
change. After a source-level correction, the complete mutually recursive
declaration family still requires host, ARMv6, and nRF52840 compile/link proof,
including noncopyable sink ownership and target-image dependency inspection.

No compatibility shim, alternate getter, placeholder state-host protocol, or
macro target was retained from the failed attempt. Continued implementation
must still compile the complete mutually recursive declaration family on all
four profiles.
