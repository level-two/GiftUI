# P08 optional extraction comparison — 2026-10-12

Bounded Strong assignment under the maintainer's continuing instruction to
resolve P08 and delegate bounded work without repeated permission. The preceding
invariant-struct primitive is closed at `81c9a13b`,2/8 calls; no previous ledger
or implementation authority is reopened.

Independent read-only review identified an unmatched observation path: the direct
Span negative reads `escaped!`, whereas wrapped-owner negatives call
`escaped.take()!`. The pinned standard-library Optional.take implementation
consumes self, sets it to nil, and declares copied-self result dependence.
This assignment isolates that distinction; it does not propose a production fix.

Strong Astra6 Medium, one compiler owner, no nested delegation. At most four
fresh compiler invocations, including syntax/setup corrections. Exactly two
intended controls with the unchanged primitive helper and external runtime seed:

1. Direct Span negative: bind `let span = escaped.take()!` after callback return,
   then call the existing out-of-line span read.
2. Existing MinimalSpanOwner negative: observe through `switch escaped` with
   `.some(let owner)` and call its read method; use no explicit take or consume
   when extracting it for that observation.

Use the already passing direct-span and invariant-struct positive controls only
as existing scoped evidence; do not replay them or integrate any host/runtime
layout. Any syntax correction consumes budget and must preserve complete prior
source/diagnostic evidence. Never execute accepted negative executables. Stop
after the two controls (and necessary bounded syntax corrections), budget
exhaustion, or two consecutive attempts without a passing check or narrower
cause. Record compiler/input hashes, exact commands, sources and complete
outputs. Freeze and commit the result for independent review.

A different negative result is not authorization to substitute an easier oracle
for required callback containment. No maintained source, contract, compiler,
feature, resource, platform, lifecycle or hardware change is in scope.
