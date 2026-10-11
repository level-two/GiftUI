# Matched activation boundary — finite FAIL, 2026-10-12

**The actual escape remains accepted under the matched boundary. A minimal
span-only enum accepts the same escape. Closed at3/6 compiler calls as required
by the assigned stop rule. No accepted negative was executed.** Strong Astra6
Medium, sequential, under [scope](scope.md), committed before all calls.
Previous benches, reviews and budgets remain unchanged.

| Run | Exact comparison | Outcome |
| --- | --- | --- |
|1|Actual activation/opportunity/quiescence inside primitive noinline callback; external runtime seed|Compile/link/execute PASS.|
|2|Reachable active owner used after all actual callbacks under same boundary and seed|Compiles/links; never executed. FAIL callback containment.|
|3|Minimal two-case enum containing only Span, same boundary/seed and consuming state transition|Compiles/links the reachable forbidden capture; never executed. Narrows failure independently of actual runtime types.|

## Matched source and narrowed finding

[Boundary.swift](Boundary.swift) is the exact noninline callback helper from the
passing direct primitive, `invokeActivationCallback(_ body: () -> Int) -> Int`.
It wraps marker, supplied state and host construction inside the innermost real
control-pointer callback. The seed is an external UInt8 argument supplied by
the reachable test main from command-line argument count (with its low bit set
to preserve the marker's nonzero assertion). Positive entry is also noinline.

The enum representation, retained spans in both states, copied-self annotations,
scoped control constructor overloads and backing ownership remain unchanged
from the final retained-span candidate. Actual runtime/endpoint construction
still occurs first in activate. No alternative layout was tried.

Run2 demonstrates that using this boundary and runtime seed is insufficient.
It does not prove which mechanism accepts the escape. The assigned scope then
permits only one minimal enum comparison and requires closing the full-host
controls; that exact path was followed.

[EnumComparison.swift](EnumComparison.swift) contains no GiftUI imports or actual
runtime/coordinator types. Its noncopyable/nonescapable enum has only inert and
active Span payloads. Its initializer copies the span lifetime; activate/read
consume and reconstruct enum state with copied-self lifetime annotations. The
reachable main contains an in-callback use, then captures an active enum outside
the callback and reads it afterward. Its marker uses the same external runtime
source as the actual main. This entire source compiles and links.

Compared with the earlier passing [direct span escape rejection](../activation-span/run-2/stderr.txt),
the reduction narrows the problem to the tested enum wrapping/transition pattern
rather than requiring actual coordinator types, imported noncopyable fields,
constant marker data or absence of a reachable main. It does not isolate enum
construction from transition individually, establish a compiler root cause, or
prove all lawful internal implementations impossible. It was not run.

## Limits and retained evidence

Run1 executed once and passed actual accepted endpoint rendering, opportunity and
synchronous quiescence. Complete output, binary hash and execution status are in
[execution-1](execution-1/result.json). This is an internal mechanism test, not
host/controller or full P08 acceptance. No hardware/platform claim is made.

After run2 failed, the scope required skipping remaining full-host controls.
Copy rejection, local-profile backing expiry and constant-seed callback escape
were therefore not compiled in this assignment. Prepared source files are not
evidence of those properties. Unused3/6 numerical calls do not reopen the stop.

Every compiler reservation, exact command, source snapshot, diagnostic and
compiler/source/link-object hash is retained in the three run directories and
[ledger.json](ledger.json). All consumed schema/runtime identity checks passed.
All18 maintained P07 fixture files remain unchanged; initialization overloads
remain in a new same-module extension. No maintained source or approved contract
changed. [manifest.json](manifest.json) covers this frozen result.

Independent Strong review is next. A new internal realization would need a
separately bounded assignment under the maintainer's resolution instruction;
this closed failed candidate is not production authority.
