# P08 receiver-dependence comparison — 2026-10-12

Final one-factor primitive control under the maintainer's continuing P08
resolution/delegation instruction. The optional-extraction assignment is closed
at `c6b4c55f`,2/4 calls. Independent review identified the minimal wrapper's
explicit receiver-dependence update as one remaining discriminator: its activate
method only changes a Boolean and does not replace its invariant span.

Strong Astra6 Medium, one compiler owner, no nested delegation. Remove only
`@_lifetime(self: copy self)` from MinimalSpanOwner.activate. Preserve copied-span
initializer, private stored fields, method body, noinline helper/read, runtime
seed and the exact switch-observation negative from the frozen extraction result.
No other layout, annotation or caller change is assigned.

At most three fresh compiler invocations, including any setup correction. Run
the matching positive compile/link/execution, then reachable switch negative
compile/link. Never execute an accepted negative. Preserve exact commands,
source snapshots, compiler/input hashes and complete diagnostics. Stop after
the pair, budget exhaustion, or two consecutive nonproductive attempts.

If escape remains accepted, stop representation trials and freeze evidence for
an upstream packet; do not use remaining numerical allowance for another idea.
If the negative rejects for the intended lifetime reason, report for independent
review before any actual-host integration. No maintained source, approved
contract, compiler feature, resource, lifecycle or hardware change is in scope.
