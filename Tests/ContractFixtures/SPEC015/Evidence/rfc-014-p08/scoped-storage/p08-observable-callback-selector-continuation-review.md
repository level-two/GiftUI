# Independent callback selector continuation review — 2026-10-18

**READY for the focused harness continuation.** Reviewed proposal 08e28178 against
fixed source f8da7a28 and initial result 24c645d2. This corrects two declaration
selectors; it grants no source repair or budget reset.

Attach target 42 uniquely identifies current function 68, serialized kind 1,
11 basic blocks, bit offset 430253. Detach target 43 uniquely identifies function
61, kind 1, 14 blocks, bit offset 393555. Exact mangled names, constrained source
signatures, full indexed records, decoded function headers/block counts and raw
module bit prefixes agree. Both original regexes miss the method-level generic
constraints between the method name and argument list; neither is a missing body,
closure/defer substitute or unused similarly named declaration.

Only targets 42/43 change; the other 48 target objects remain identical. The runner
requires one match, nonzero serialized kind and positive block count for all 50,
plus full pinned-record equality for these two. All 50 must pass before SIL runs.
This review checked the two identities offline; it does not claim the proposed
50-target execution has passed.

The 861-input freeze, five recipe hashes, 230-artifact seal and original archive
identities verify. Original lower/25 compile, 64 privacy, eight complete indexes,
interpreter/two captures and all 75 executed qualification checks remain usable;
the original 48/50 failure and blocked SIL result remain preserved. The prepared
42-source consumer command changes only argument 14 (cache) and 72 (SIL output).
Fresh output is absent; the runner forbids reuse, writes new logs, and rechecks
the frozen inputs after collection. No prerequisite compiler/decoder/object rerun
or automatic source repair is introduced.

Proceed under the existing grouped harness-correction authorization: apply the
50-target gate, then collect fresh optimized actual-host SIL only if it passes.
Interpret actual callbacks and normal/error ownership/release paths separately;
collection alone cannot pass them. Prior selected-root/resolver results remain
limited; whole-host closure, ordinary costs, full private P08/14-loan/Optional and
lifetime safety, strict cold, zero heap and P08 acceptance remain unqualified.
No source/compiler/decoder/runtime action occurred in this independent review.
