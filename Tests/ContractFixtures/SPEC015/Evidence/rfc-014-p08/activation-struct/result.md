# Invariant struct span — failed primitive, 2026-10-12

**The minimal invariant struct still accepts reachable callback escape. The
assigned primitive-failure stop closes this work at2/8 compiler calls. No actual
host integration was attempted.** Strong Astra6 Medium, sequential, under the
committed [scope](scope.md). All prior ledgers remain closed and unchanged.

Run1 compiles, links and executes the minimal positive. Run2 compiles and links
the reachable forbidden capture; it was **never executed**. There is no successful
lifetime-negative control for this representation.

[MinimalSpanOwner](MinimalOwner.swift) is noncopyable and nonescapable. It stores
an immutable private Span and a mutable Boolean flag. Its initializer declares
copied dependence on the span. Its activate method mutates only the flag and
preserves copied-self dependence; it never consumes or reconstructs whole self
or the anchor. Reading checks the flag and passes the stored span to a noinline
read function. No enum, runtime type, unsafe pointer, lifetime override or module
import appears in this primitive.

Both drivers use the exact noinline callback helper from the preceding direct
span control and a runtime-derived marker byte. The negative's reachable main
creates the marker inside the callback, constructs and activates the struct,
captures it into an outer Optional, then reads the struct after callback return.
Only compilation/linking were performed for that negative. Its acceptance
narrows away consumed/reconstructed enum state as a necessary condition for the
previous accepted escape; it does not isolate the compiler mechanism, establish
why lifetime propagation differs from the direct Span, or prove every lawful
host representation impossible.

The successful positive's complete output and executable hash are retained in
[execution-1](execution-1/result.json); it was executed once. Each run directory
retains exact sources, command, complete diagnostics and compiler/source hashes.
The runner verified pinned compiler and schema input/artifact identities before
both calls. No real runtime code was compiled in this scope. The existing flags
and dependency search paths were preserved; no compiler feature changed.

[ledger.json](ledger.json) is closed. The six unused numerical calls are not
continuation authority. Actual activation, reachable host callback containment,
copy, local backing-expiry and constant-seed controls were skipped exactly as
required after a failed primitive. No maintained code changed; no package,
lifecycle, platform or hardware acceptance is claimed.

Independent Strong review of this frozen finite result is next. Any further
investigation needs a separately bounded assignment under the maintainer's
resolution instruction; this failed representation is not production authority.
