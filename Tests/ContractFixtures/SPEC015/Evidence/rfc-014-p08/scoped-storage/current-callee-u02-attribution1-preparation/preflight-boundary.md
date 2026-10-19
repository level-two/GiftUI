# U02 preflight boundary — 2026-10-19

The first executor paused before the retained attribution session began. Its
operations were `pwd`, reading `AGENTS.md` and the implementation-executor
skill, read-only commit/path listings, and reading this preparation README and
its B01 review. It did not read evidence payloads, authenticate preservation
inputs, interpret selected rows, start a session clock or ledger, or create the
fixed result directory. The tool-visible orientation output was about 32 KiB.

Astra Medium reviewed the boundary. These orientation reads do not consume the
one proposed retained inspection. No five-file STOP result should be created.
This is a local execution-boundary interpretation, not an ADR, Specification,
scope, repair-budget or evidence change. If later evidence shows that session
authentication or selected evidence use had begun, this conclusion no longer
applies and the attempt must STOP without resetting its clock or allowance.

The packet's 10,000-byte transcript ceiling covers **all tool-visible output
after session startup**, including control, authentication, status and errors;
it is separate from the 8 MiB result-file ceiling. Earlier orientation output
cannot be reused as session authentication. Before the first session read, the
executor must start one monotonic clock and cumulative input, output and
transcript counters; reserve mandatory final checks, then re-read and
authenticate controls under those counters. The original 512 MiB, time, row,
destination and zero-retry limits remain binding. No U02 attribution or
conformance conclusion follows from this record.

The user's standing instruction to proceed covers the reviewed bounded U02
step. Preparation `3db4e1b1` and independent readiness review `eae5e6ab`
remain the exact inputs. The result destination remains absent at this
boundary. Five dirty files/cache, consumed P08 markers and prior API/ref2
allowances remain preserved.
