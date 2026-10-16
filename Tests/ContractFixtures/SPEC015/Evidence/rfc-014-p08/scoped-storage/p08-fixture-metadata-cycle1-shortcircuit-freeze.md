# P08 metadata cycle1 — preserve checked model-read short-circuit

**Independent SOURCE PASS at `31ecb1a5`.**
[Focused two-site addendum](p08-fixture-metadata-cycle1-independent-source-review.md#focused-two-site-addendum--31ecb1a5)
closes B01/B02 and confirms readiness for the first registered fresh screen.

**Same grouped correction1/2, source-only followup to `d82dde91`.** The inventory
fix remains unchanged/closed. Only the prepare/delivery model conditions change:
evaluate the owned fingerprint Bool once; an ordinary `if` calls the original
model equality once only when that Bool is true, otherwise assigns false; the
assertion combines owned Booleans. No borrowed value enters an autoclosure.

The earlier cycle1 receipt's description of the model observation as pure was
incorrect. `observeModelValue` performs checked frame/pin/read/end operations.
This followup restores the original skip on fingerprint mismatch, preserving
observation order, invocation count and failure behavior. It adds no new source
optimization, representation or correction cycle. Prior freezes/reviews remain
immutable; correction1/2 stays consumed and no compiler/runtime/build has run.

[Immutable diff/manifest](fixture-metadata-cycle1-shortcircuit-source/manifest.json)
pins the exact two Swift replacements, regression expectation and qualification
driver glue. An inverse check reproduces `d82dde91` source exactly after undoing
only these two blocks. Four Boolean/control-flow cases per site confirm model
reads0 when fingerprint=false and1 when true; this is source-flow evidence, not
runtime execution. The focused source regression, formatter grammar, Python AST
and whitespace checks passed. No unrelated condition, inventory/lender, lifetime
bound, oracle, label or resource constant changes.

The fresh qualification carries only CounterScopedStorage's new excluded source
hash; all other candidate hashes and the same seven receipt hashes are unchanged.
Prior exact argv/765-artifact proof remains pinned and was not repeated. No changed
compiled counter input or stale collection/image is qualified. Focused two-site
independent reassessment precedes the same registered fresh nRF screen command
in the manifest. All historical closed budgets remain closed; P08 remains open.
