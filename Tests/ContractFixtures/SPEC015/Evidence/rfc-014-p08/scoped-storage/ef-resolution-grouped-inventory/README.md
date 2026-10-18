# Grouped E/F commit-resolution proposal — 2026-10-18

Read-only proposal: **23 declarations/four files**, five serialized operations,
14 field sites and four type sites. No source/compiler/runtime action or renewed
source allowance. Independent review precedes any implementation.

The [reviewed current result](../p08-semantic-c-boundary-review.md) resolves21/23
selected boundaries. F20 is live cleanup: OwnedKeyState forwards to State after
unconditional provider metadata setup, then State may dispatch storage witnesses.
F21's eleven-instruction scalar callee is harmless narrowly; its actual caller still
instantiates concrete allocator metadata before the call. Existing exact source,
SIL and provider/object proof is [retained](../semantic-c-consumer-result/README.md).

The [exact map](correction-map.json) serializes both resolvers, State readiness and
allocator adding; qualifies only their direct fields/signature types and allocator
nominal. This covers poison/ready guards, both publication swaps, candidate reset,
phase/error/limits/revision and saturating counters together. No default-CMO promise.

The [storage closure](direct-storage-closure.json) records all15 concrete operations:
five Static witnesses and five protected P08 adapters are already in the same42host
source compilation, including private optional-slot clearing and checked descriptor
exchange; no source edits. Five imported Dynamic operations remain compatibility
and cost questions, without blanket serialization. Source availability is not
proof of successful specialization/destruction or whole-host cost.

Reviewer visibility decision: three scalar counters retain package getters and
change **private(set) → internal(set)** with ABI qualification. Their setters remain
inaccessible to importing modules, including same-package clients; owner-module
access expands explicitly. The [guards](guards.json) distinguish these framework
implementation values from SPEC-015's mandated private P08 backing and preserve
SPEC-011's exact five stored lifetime values, constructor unions and poison rules.
No constructor/default/body/algorithm/ownership changes are proposed.

The [combined validation proposal](tests-validation-proposal.json) groups fresh
registered25/four variants → applicable73+E/F/privacy/setter controls → complete11
indexes/prior87+five new bodies → same42 SIL/matching object and actual cleanup.
Four existing exact identities are [pinned](current-four-body-records.json); adding
has no current physical record, so its new fresh unique identity must be captured,
not guessed. Caller metadata and concrete reset/exchange costs are required gates.
Phase synthesized helpers/property setter ABI eligibility remain compiler-dependent.

Source f2325b85's previous1/1 zero-repair activity stays closed. Full14-loan/safety,
ordinary Text/cold witnesses, strict cold zeroheap/resource and P08 acceptance remain
open. No new deferred work or architecture/API/ownership change is selected here.
