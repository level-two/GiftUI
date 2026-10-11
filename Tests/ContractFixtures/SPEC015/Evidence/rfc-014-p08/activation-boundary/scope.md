# P08 matched activation boundary — 2026-10-12

Next bounded assignment under the maintainer's continuing resolution/delegation
instruction. Prior retained-span work is closed at `27635694` and independently
reviewed at `a1565f9d`; no earlier ledger is reopened.

The direct span primitive rejects callback escape. Actual host escape still
compiles, but the controls differ: the primitive invokes a non-inlined callback
with an external runtime marker value; the actual host's innermost closure can
inline and its marker is constrained to a known constant. The existing evidence
does not isolate enum storage as the cause.

Strong Astra 6 Medium owns at most six fresh compiler invocations, counting every
correction/link. Match the actual host's innermost marker/construction scope to
the passing primitive's exact private callback boundary and runtime seed, while
keeping the current owner representation, constructors, lifetime annotations,
actual supplying scopes, and runtime/endpoint construction order unchanged.
This is a private construction helper, not a new host role or public API.

Required controls, in order: actual positive execution; reachable active callback
escape; copy rejection; local backing-expiry rejection; reachable callback escape
with a constant seed. Both seed cases must reject for the intended lifetime
reason; safety must not depend on data varying at runtime. Accepted negative
executables are never run. If the runtime-seed escape still compiles, stop full
host testing and use at most one remaining control to compare a minimal
enum-wrapped span under the identical primitive boundary, then close with exact
evidence. No unbounded alternative owner designs are assigned.

Stop at completion, the six-call ceiling, or two consecutive attempts without a
passing check or narrower cause. Preserve exact inputs, outputs, command and
compiler identities, and commit the result for independent review. No contract,
compiler/feature, capacity, platform, or hardware change is authorized here.
