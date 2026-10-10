# Terminal result

**Completed: the finite fixed-context inference mechanism is supported.**
15/16 compiler/link/native-execution invocations; one of two allowed source repair
rounds; approximately 41 seconds from first invocation through the last result.
No ceiling was extended. [Machine result](result.json), [ledger](ledger.json).

| Configuration | Positive | Execution | Overlap negative | Escaping-storage negative |
| --- | --- | --- | --- | --- |
| macOS Dynamic flag | Pass | 15 checks, 0 failures | Intended rejection | Intended rejection |
| macOS Static flag | Pass | 15 checks, 0 failures | Intended rejection | Intended rejection |
| Raspberry Pi ARMv6 | Object compiled | Not run | Intended rejection | Intended rejection |
| nRF Embedded | Object compiled | Not run | Intended rejection | Intended rejection |

Native generic evaluation reached compiler-derived Root.Body and Nested.Body with
nonzero discriminating output. The conditional's zero and nonzero branches pass;
the opaque helper participates without manually naming its result. Wrong Never
inference would invoke the fixture's trapping leaf default and fail the run.
Canvas remains an explicit Never leaf with a separate deferred draw operation.

One shared scalar bank supplies the two evaluations and later Canvas reads.
Phase checks reject writes between borrows, compiler exclusivity rejects ending
the phase with a live read, and the next cycle observes new data while earlier
owned output remains unchanged. This separates phase enforcement, short borrow
lifetime, and owned output lifetime without a snapshot copy.

The initial failed invocation and its one repair are preserved: explicitly typed
do/catch scopes were necessary to avoid catch inference to `any Error`. This was
a fixture error, not a failure of opaque Body inference. No positive/negative
matrix was expanded after success. Every negative log was checked for the named
error; no unrelated diagnostic supplies its expected rejection.

Object attributes identify ARMv6/VFP arguments for Pi and Cortex-M4/v7E-M,
Thumb-2 and VFP arguments for nRF. [ABI evidence](abi.json) includes commands and
artifact hashes. Objects are not linked firmware or hardware validation.

## Disposition

SR-Q2's narrow language question is answered. Prefer compiler-derived associated
Body through a non-generic contextual requirement over frontend-generated Body
aliases. Preserve the actual integration question: a concrete scalar FrameRead is
not a portable general schema API, and this miniature protocol is not GiftUI's
real module graph. No production architecture, source API or compiler-policy
approval follows. See [limitations](../README.md#limits).
