# Independent review: retained activation span

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at frozen `27635694`
(primitive checkpoint `eb89bd2d`). Read-only source, receipt and hash review;
no compiler invocation or executable run. Scope is the bounded [experiment](scope.md),
not complete P08 conformance.

**Reject actual-owner adoption.** The direct Span primitive has a passing
positive and intended lifetime rejection, but the actual owner still accepts its
reachable callback-escape negative. The bench closes at 6/8; no copy or physical
backing-expiry negative was compiled for the final candidate.

Runs 1–2 prove that a callback-local `InlineArray.span` can provide a checked
boundary in the tested direct primitive. Its reachable negative reports the
intended escaped lifetime-dependent value. Runs 3 and 5 compile, link and execute
the real coordinator opportunity and quiescence. Runs 4 and 6 compile/link active
owner use after supplying callbacks end, with no lifetime rejection; neither
accepted negative executable was executed. These outcomes agree with the
author's result and do not establish a compiler root cause.

The span is physically retained in both enum cases and preserved through each
activate/opportunity/quiesce reconstruction. An out-of-line span read makes it
part of active use. The run-5 correction adds receiver copied-lifetime annotations
to the three mutating methods. Installed Swift's own mutating span methods use
the corresponding receiver-dependence annotation. This is a checked internal
propagation attempt under the unchanged contract, not an unsafe override; its
positive result cannot substitute for the failed escape control.

As in prior reviews, callback end is a semantic boundary: model/root cleanup,
semantic bank clearing and Canvas discard occur even while profile allocation
survives. SPEC-015 prohibits this escape. Actual backing, private construction,
activation-time coordinator/endpoint construction and unchanged module contracts
remain necessary alongside a working compiler guard.

## Remaining diagnostic distinction

The direct primitive and actual join are not an exact isolation of enum-payload
lifetime behavior. `PrimitiveNegative.swift` uses an explicit `@inline(never)`
callback helper and a marker derived from `CommandLine.arguments.count`. The
actual negative creates its marker inside inlineable profile/pointer callbacks,
from `control.teardowns + 1`, followed immediately by a precondition establishing
that teardown count is zero. Constant propagation or callback inlining remains
an alternative explanation for the different compiler outcomes. No proof that
the enum itself loses dependency follows from this bench.

The sharpest next control is to match the primitive's out-of-line callback and
externally derived marker at the innermost actual construction site, without
changing the enum. Only if that still accepts escape should a minimal enum versus
fixed-span-field wrapper on the identical primitive boundary be needed. These are
read-only recommendations; any further experiment requires a separate bounded
assignment. They do not change approved host behavior or grant adoption.

All 151 frozen manifest entries matched SHA256 values. Historical runs and limits
are unchanged. No generic `MVPHostInstance` integration, full validation/failure
containment, resource accounting, cross-profile target result or P08 package
acceptance is established by this mechanism bench.
