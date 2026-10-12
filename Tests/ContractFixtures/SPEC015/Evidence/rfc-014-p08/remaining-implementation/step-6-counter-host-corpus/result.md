# P08 step6 — actual scoped host finite action/render corpus

2026-10-12, sequential Strong Sol6.1 High. PASS **3,665 assertions /23controls**.
Final command: `python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static`.
Final receipt: `.build/contracts/p08-counter-o8voc10w/result.json`. All inputs and
artifacts reverified before this frozen packet. Formatter/lint, governance and
diff checks pass. Guard0/2; all historical stopped guards remain preserved.

Both actual scoped hosts receive normalized pointer down/up events carrying the
current committed presentation revision, through the same admission controller
used by their concrete coordinator. The one Controller? value physically lives
inside CounterControl; coordinator and synchronous finite callback adapters hold
only pointers to it. Controller mutation and queue/model/context state occupy
disjoint fields of the enclosing stable control allocation. Callback submission
synchronizes the same context/revision and invokes maintained admission logic;
it performs no model read, direct model mutation, independent retain or controller
construction/copy. The enclosing withUnsafeMutablePointer scope outlives the scoped
host, its coordinator and callbacks. No new maintained host API is introduced.

For each actual host, disabled Reset at0 admits no action; nine increment gestures
reach1–9; disabled Increment at9 admits no action; Reset returns0; disabled Reset
again admits no action. Actual dispatch revalidates typed action/identity/target
and runs the maintained mutation route. Each frame independently checks all four
text scalar sequences and lengths, both disabled flags, all22 glyph IDs and exact
baselines, one finished stream/no discard, zero/one optional stroke, translated
stroke points and completed frame/admission cleanup. Both full and partial host
teardown subsequently reject callback fact admission and leave no pending fact.

Expected geometry comes from authored Counter source plus the checked-in font
catalogue, independently of runtime traversal/layout output: title/Increment/Reset
widths60/74/41, digit widths7 for1,9 for7,10 otherwise; lineheight20 with4 spacing;
baselines16/40/64/88; centered Canvasorigin(13,96), translated stroke starts(17,104)
and ends(17+4×value,104). The100×100 surface clips the stroke; this records the
fixture's actual clipping rather than inventing visible stroke pixels. These are
render-operation/geometry controls, not raster pixel or physical display proof.

The26family storage audit now partitions the full physical CounterControl value,
including all simultaneously live outer fixture controls, observations, copied
recording sink, optional controller and padding. Admission/pointer/result fields
are subtracted only after separately charging their exact partitions; coordinator
fields no longer subtract a controller they do not contain. Nothing live is
excluded to pass a ceiling. Endpoint and sink remain an explicitly separate
backend-owner charge in the later complete linked ledger; this profile subtotal
is not complete image RAM or stack acceptance.

Retained setup failures: x63iun88 borrowed-control precondition autoclosures;
a0e7gaiv narrowed remaining short-circuit capture, fixed by primitive-field reads.
4fyhvg6b passes compiler/ownership/link but trapped at an unlabeled glyph oracle;
8aztjd9p labeled line65 without changing expectations. Before reading that result,
independent catalogue inspection found digit1's distinct advance7; expected
centering now uses each digit's authoritative advance. Preparatory guessed stroke
origin(4,88) was corrected from layout/font contracts before any execution. No
runtime output was copied into expected values, contract relaxed or capacity
raised. Borrowed-capture guard conservatively reached1/2, then reset to0/2 when
module/negatives passed; subsequent frame oracle errors were independently narrowed.

Remaining: actual host normalized-input gate and wake/physical-presentation joins;
live owner-role graph and exact endpoint/health identity projection; actual raster
pixel controls; full registered four-route counter artifacts and early linked
Pi/nRF RAM/stack/allocator/ABI checks. Existing scoped-model replacement evidence
remains applicable at its documented component boundary. No P08 exit, target
execution, complete linked resource proof or implemented transition is claimed.
