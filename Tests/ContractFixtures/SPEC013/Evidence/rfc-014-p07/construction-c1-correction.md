# P07 construction C1 correction

This implements the bounded correction requested by
[construction review C1](construction-review.md); it does not self-accept the
review, complete P07, or begin another package. The root authorized the repair
under the existing consuming-owner resumption. Shared guard remains **0/2**;
the historical production stop remains unchanged.

## Binding and physical backing

The actual owner retains the immutable audited RuntimeProfileLimits. Common
coordinator construction checks owner limits equal binding audit limits. Admission
controller and sealing use its ExecutionLimits; semantic expansion, Layout,
Interaction, Drawing and Render receive the same configured fields.

Physical storage stays separate. Semantic activation takes configured traversal /
record / payload budgets while bank slicing uses the original physical strides
and offsets. Model adapters forward configured model/claim/pin/capture bounds to
the real ownership ledger while reporting their retained two-model/four-claim/
two-pin storage. Observable root activation binds limits and checks occupied
locations, registrations and staged associations; replacement checks use the same
registration/association bounds. Canvas staging uses configured occurrence and
Static table/capture bounds. Interaction retains physical key extents while
applying separately configured per-key and per-bank budgets.

Drawing keeps retained capacity separate from configured limits through live-path
construction and stroke snapshots. Counts are checked before adding points or
plan records. Maximum line width is an operational geometry limit, not storage
capacity; a configuration above the backing's original width value is supported
without changing allocation. The scoped Render adapter delegates to the actual
borrowed workspace while exposing exactly configured structuralCapacity, as
SPEC-013 requires. Physical headroom is checked independently and cannot expand
that exposed view. Preflight uses configured sink and Render limits; its ordinary
operation count excludes the actual normalized strokes and must fit the configured
ordinary-operation budget before any frame streaming.

The only remaining constants at activation are physical backing extents, the
concrete generated Dynamic Canvas table's type metadata, and the fixed reference
surface/proposal. They do not replace accepted operation budgets. Descriptor
metadata changed because owners now retain configured limits; the fresh report
is [construction-c1-storage-regions.json](construction-c1-storage-regions.json),
linked through the fresh receipt's input and artifact hashes. The earlier
construction-storage-regions.json remains the historical step-5 report.

## Executable matrix

Each axis audits successfully, retains exactly its requested immutable limits,
executes both actual factories, and re-audits equal after teardown/reset. Excess
cases require the exact focused `capacityExhausted` error at the stage below,
zero model mutations/frame streams/commits, and completed cleanup/quiescence.
Adequate cases complete the original full successful/failure-injection lifecycle
fixture and its three admitted mutations. This is not an audit-only matrix.

| Axis | Configured change | Required result |
| --- | --- | --- |
| 0 | One live path point | Drawing capacity failure at Canvas invocation |
| 1 | Two live path points | Full sequence succeeds |
| 2 | One plan point | Drawing capacity failure at Canvas invocation |
| 3 | Two plan points | Full sequence succeeds |
| 4 | One semantic path entry | Semantic capacity failure during expansion |
| 5 | Path depth one | Semantic capacity failure during expansion |
| 6 | Child fanout one | Semantic capacity failure during expansion |
| 7 | Payload byte budget zero | Semantic capacity failure during expansion |
| 8 | One structural record / semantic node and one Canvas | Semantic capacity failure during expansion |
| 9 | One body evaluation | Semantic capacity failure during expansion |
| 10 | Layout depth one | Layout capacity failure |
| 11 | One layout scope and one Canvas | Layout capacity failure |
| 12 | One positioned Layout glyph | Layout capacity failure |
| 13 | One exported Render semantic scope | Render capacity failure during preflight |
| 14 | Exported Render traversal depth one | Render capacity failure during preflight |
| 15 | One ordinary Render operation | Render capacity failure during preflight |
| 16 | One total Interaction identity component | Interaction capacity failure while building candidate |
| 17 | One model, ticket, pin, observable location/registration/association | Full sequence succeeds |
| 18 | One semantic action / Interaction action and hit region | Full sequence succeeds |
| 19 | One admitted input event | Full sequence succeeds |
| 20 | Maximum line width five, beyond original capacity descriptor's width four | Full sequence succeeds; no storage growth |

The matrix does not independently exhaust every scalar combination: remaining
fields are forwarded into their maintained focused algorithms and checked by the
same construction audit. No known C1 limit/provenance mismatch is left open.
Later P07 pointer/lifecycle cases and final-route evidence remain pending.

## Validation and repair record

The fresh formatted focused native gate and twelve compiler negatives are in
[resumption-step-6-macos-static.json](resumption-step-6-macos-static.json).
[Matrix transcript](construction-c1-configured-limits.txt) records all axes.
The review's exact unchanged LimitProbe was linked against these fresh modules;
[command and output](construction-c1-review-probe.txt) show both factories still
audit a one-point configuration, but now terminate with no applied mutations.
The stronger maintained axis-0 regression checks the exact Drawing capacity error
and zero frame work, rather than accepting an arbitrary failure.

A source-located Static Render exclusivity diagnostic was repaired by obtaining
the resolved view before borrowing the render workspace. The next compile and
all original685 assertions passed. The first matrix run reached an invalid test
configuration (one semantic node but five configured Canvases); making its
related Canvas bound one progressed through axis12. The next run exposed that
the audited Render descriptor still reflected physical rather than exported
configured capacity; wiring the real bounded view and checking physical coverage
passed all cases. The ordinary-operation test uses one, not the drawing-only
zero special case. These were productive, narrowing repairs; no two consecutive
unproductive repairs occurred. No escaping/lifetime suppression, compiler change,
contract amendment, connected hardware or parallel implementation was used.
