# SPIKE-075 disposable state feasibility fixture

Scope: [SPIKE-075](../../docs/spikes/spike-075-p08-state-feasibility.md), committed
before preparation as `722f5862`. This is the exact candidate in draft
[RFC-015](../../docs/rfcs/rfc-015-p08-scoped-storage-ownership.md), not approved
architecture. Preparation does not authorize execution before the required
independent Strong review. No compiler has been invoked during preparation.

Run from the repository root after that review:

```sh
python3 experiments/spike-075-p08-state-feasibility/run.py
```

The runner preserves a unique receipt at
`.build/spike-075/<UTC-UUID>/receipt.json`, snapshots sources, and never replaces
prior runs. Native output stays there; target output goes under
`.build/raspberry-pi/spike-075/<UTC-UUID>/` and
`.build/nrf52840/spike-075/<UTC-UUID>/`. Each attempted subprocess command is
recorded before spawning, with separate stdout/stderr, timeout, exit and elapsed
time. Normal exits, exceptions and catchable interruption produce a final
receipt. As with any process, SIGKILL or an unavailable filesystem cannot be
handled by the runner. Source, compiler driver/frontend, recipe/configuration,
SDK trees and Embedded standard library tree have SHA-256 provenance. SDK
hashing occurs before the compiler time window begins.

Compiler selection uses `compiler-baseline.sh`; both selected compiler paths
must report `Apple Swift version 6.4 (swift-6.4-RELEASE)`. No PATH compiler or
replacement SDK is accepted. The native SDK is explicitly resolved with xcrun.
Each compiler path has one identity query (two total). Profiles run sequentially:
macOS Dynamic, macOS Static, ARMv6 Dynamic, Embedded Static. Each profile has
exactly eight experiment invocations: shadow object/module emission, positive
client object, copy rejection, then five lifetime rejections. The runner uses
Swift 6, LifetimeDependence, Lifetimes, Osize, whole-module optimization and
isolated caches; it does not link or execute objects. The first unexpected
result stops all further profiles, with zero repairs. Each invocation has at
most 180 seconds; the whole compiler window has at most 20 minutes and 32
experiment invocations. A stopped run must be independently reviewed; invoking
the runner again is a new experiment and requires separate authorization.

`DomainAndProtocols.swift` copies all six protocol declarations verbatim.
`States.swift` preserves both RFC stored field sets, generic constraints,
consuming initializer signatures/lifetime annotations and four conditional
extensions. Added initializers assign only those fields. Protocol witnesses
are inert and do not simulate transaction behavior. Only the fixture `probe`
methods read banks. `Banks.swift` uses owned scalar stand-ins and noncopyable,
non-escaping Span adapters constructed from actual typed InlineArray owners.
No raw pointer descriptor or unsafe lifetime erasure appears.

The positive client copies, returns and stores both owned layers. Five scoped
positive twins consume through the failable wrapper after an inner block while
all five owners remain alive. Each `EscapeN.swift` moves only owner N into that
block, then consumes the wrapped value through Optional.take after that one
owner has ended. Bank numbering is: candidate records, candidate hit regions,
candidate committed records, committed records, committed hit regions. The
copy rejection explicitly requires Copyable of the scoped wrapper. Returning
an observable UInt64 from public client entry points, non-inlined probe methods
and reads from all five banks prevent an unused fixture from eliminating the
intended last use. The emitted shadow module forms a real separate module;
client and shadow share package name `giftui` and access package declarations.

An accepted negative needs nonzero exit, an intended diagnostic on every error
line, and no crash marker. Copy rejection needs Copyable/noncopyable diagnostics;
each escape needs lifetime/escape/dependence/outlive diagnostics. Unexpected
missing witnesses, access errors, or successful escape/copy acceptance stop the
run. Review the saved full diagnostics as well as the receipt; diagnostic
classification is evidence routing, not a substitute for independent review.

This fixture establishes only compiler language feasibility if it passes. It
cannot prove production behavior, concurrency, memory budgets, runtime
semantics, physical initialization, common-owner exclusive mutation, the full
session/carrier/retirement chain, ABI conformance, whole-image fit or hardware
execution. Span provides read access here; inert exchange witnesses do not
establish mutable backing authority. Real-owner lifetime tests deliberately
isolate each bank rather than claiming a common backing-session proof.

Preflight concerns: the RFC explicitly calls these declarations uncompiled;
a rejection in the first shadow-module emission is a valid falsification gate
and must not be repaired within this scope. Optional.take and InlineArray.span
spellings were inspected in the pinned compiler's installed Swift interface,
without invoking a compiler. Availability and cross-profile support remain
part of the bounded run. The fixture is 526 Swift lines; disposable experiments
are excluded from the maintained-source formatter by CODE_STYLE.md.
