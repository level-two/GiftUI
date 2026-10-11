# Optional extraction comparison — complete, 2026-10-12

**The Optional.take observation mismatch does not explain the recorded direct
Span versus wrapped-owner results.** Exactly2/4 compiler calls were used, no
syntax corrections were needed, and no executable was run. Strong Astra6 Medium,
sequential, under [scope](scope.md), committed as `117c5fcc` before either call.
All prior failed candidates and their closed budgets remain unchanged.

| Control | Exact changed observation | Result |
| --- | --- | --- |
|A / run1|Direct Span: `let span = escaped.take()!`, then existing noinline read|Rejects expected callback escape; diagnostic identifies captured variable and its dependence on local marker.|
|B / run2|Invariant private-span owner: `switch escaped`, `.some(let owner)` calls owner.read|Compiles/links; never executed.|

A changes only the postcallback observation in the previously rejected direct
Span source. The direct marker, helper, runtime input and captured Optional are
unchanged. Therefore Optional.take does not by itself erase the direct Span
lifetime rejection in this control.

B uses the unchanged MinimalSpanOwner and callback helper from the preceding
invariant-struct positive/negative pair. It changes only the final observation
to the requested switch form, with no take or explicit consume at extraction.
The creation-side `escaped = consume owner` remains necessary and unchanged.
This source-level control does not independently inspect the compiler's lowered
ownership of the switch; it specifically removes the Optional.take call while
preserving a reachable postcallback read. Accepted escape persists.

These are diagnostic comparisons, not fixes. They neither authorize substituting
a different negative oracle nor establish a compiler root cause or a safe host
representation. Actual callback containment remains unproved for every tested
wrapped-owner candidate. No actual host/runtime integration occurred here.

Existing direct-span and minimal-struct positive results were not replayed.
Both negatives have reachable mains and use the prior runtime seed and noinline
callback/read boundaries. The accepted run2 executable was never executed.
Pinned compiler and schema inputs/artifacts passed the runner's checks before
both calls; exact commands, source snapshots, complete diagnostics and hashes
are retained. [ledger.json](ledger.json) closes the assignment after its two
required comparisons; remaining2/4 numerical calls are not continuation authority.
[manifest.json](manifest.json) covers the frozen result.

No maintained source, contract, compiler feature, resource, lifecycle or hardware
change occurred. Independent Strong review is next.
