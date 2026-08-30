# SPEC-004 T3.2 One-Shot Lease and Derived-Payload Evidence

The contract probe independently rebuilds the approved ownership seam with a
fixed three-operation stream, explicit active-borrow state, and a three-byte
derived payload. It does not import, copy, or promote SPIKE-001 code and does
not invent production declarations for the still-unimplemented SPEC-009 or
SPEC-014 owner targets.

The six-case lifetime/handoff matrix proves:

| Submission lifetime | Synchronous handoff | Queued handoff |
| --- | --- | --- |
| synchronous borrow | available; bytes consumed before return and no payload retained | rejected before traversal |
| synchronous copy | available; endpoint-owned copy completed while the borrow is active | available; the same owned copy survives return |
| ownership transfer | available; fixed payload transferred while the borrow is active | available; only transferred derived bytes survive return |

For every available pair, the producer traversal count is exactly one, all
three operations are visited exactly once, and the endpoint retains zero
operation values. A second traversal is rejected. After return, a poisoned
borrow rejects access and records the attempted violation. The rejected queued
synchronous-borrow pair performs zero traversals and consumes zero operations.

Separate compatibility controls change only encoding or submission lifetime.
The encoding negative returns `noCommonCanonicalPixelEncoding` while its
control is available; the lifetime negative returns
`incompatibleSubmissionLifetime` while its control is available.

Validated on 2026-08-30 with both executable macOS semantic profiles and all
four hardware-free SPEC-004 contract commands. The unchanged production
declarations cross-compile for ARMv6 and nRF52840; the lease probe remains pure
host evidence, not connected-target or production integration evidence.
