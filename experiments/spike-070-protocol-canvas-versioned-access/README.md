# SPIKE-070: protocol Canvas and versioned property access

**Terminal: inconclusive.** This is disposable evidence for [SPIKE-070](../../docs/spikes/spike-070-protocol-canvas-versioned-access.md),
not a production implementation or accepted RFC. Read [the result](evidence/result.md)
before interpreting the successful native runs.

## Source boundary

`Authoring.swift.txt` is a deliberately finite Swift-shaped input language.
`generate.py` tokenizes and parses it into an AST, checks model property and
helper routes, and emits `Generated.swift`. It is not a Swift parser, an
implemented Swift macro or a complete unsupported-use checker.

The checked corpus contains exactly two named model schemas (two UInt32 fields
and one Capture field), one annotated State-bearing root/body, two Canvas
conformers and one UInt32 helper. Bodies accept finite HStack/VStack/Text and
Canvas construction; draws accept a checked drawing helper; capture reads use
`level(at:)` and return owned values. The expression grammar has identifiers,
unsigned literals, strings, member reads, calls, labels, inout graphics context
and builder children. It does not support general control flow, operators,
closures, imports, arbitrary initializers, method dispatch or a complete Swift
type system. Known scalar/helper argument type details remain Swift compiler
checks. The seven rejection controls are examples, not checker completeness.

The output changes when property selection, initializer or body topology changes.
Those three perturbations were checked at generation level only; they were not
compiled or executed. The generator does not emit graph records. Actual GiftUI
children determine traversal when the generated body is evaluated.

## Deliberate seams

- The authoring class becomes a value containing a safe model key; schema
  defaults initialize the disposable owner. Actual `@Published`, State binding,
  class identity/ownership and macro expansion are not implemented.
- The root becomes an owned descriptor with throwing `evaluate(read:) -> some
  View`, **without View conformance**. Its children use actual GiftUI ViewBuilder
  and traversal. No claim of an unchanged public `View.body` contract follows.
- All maintained `Sources/GiftUI/*.swift` files are compiled unchanged except
  concrete `Canvas.swift`, replaced only in this fixture by `CanvasProtocol.swift`.
  The generated Canvas method receives an extra FrameRead argument. Default
  protocol leaf traversal implements the actual visitor requirement.
- `StagedVisitor` is a fixed three-slot disposable visitor. Its synthetic
  `layoutComplete` boundary is not production SemanticCore or Layout. Native
  profile flags share the same owner; they do not establish class-owner parity.
- `ModelOwner` copies two scalar fields and 404 transitions into separate frozen
  backing. Caller-owned raw buffers must be initialized, disjoint, exclusive,
  correctly aligned and live longer than the owner. This unsafe boundary is not
  established by the lifetime annotation. There is no real model pool or host.
- GraphicsContext/Path and their cleanup are actual GiftUI declarations; the
  finite C operation table records calls instead of rasterizing or publishing.
  No output-image, firmware, heap, complete stack or timing proof is claimed.

## Evidence and reproduction

Run from the repository root. Input/compiler hashes, exact commands, flags and
logs are in `evidence/ledger.json` and inventory files. Content-addressed Swift
snapshots preserve every compiled source version, including failed attempts.
`evidence/repairs.json` records both repair rounds. Large binaries remain in
`.build/spike-070`, `.build/raspberry-pi/spike-070` and `.build/nrf52840/spike-070`;
successful artifact hashes/sizes are in `evidence/inspection.json`.

The historical invocation sequence was `run.py policy`, the additional policy
control (trial 3), then three `run.py positive` attempts separated by the two
recorded repairs. No negatives or reachability run occurred. Exact commands in
the ledger are authoritative; the final runner contains the accepted feature
policy and reproduction of all three policy controls.

`python3 experiments/spike-070-protocol-canvas-versioned-access/inspect.py`
rechecks preserved logs, snapshots, native transcripts and existing ARMv6 object
attributes and inventories the pinned toolchains; it does not compile or run a
fixture. Generation can be compared in memory through `generate.generate`.
`generate.py check` describes the seven rejection and three perturbation controls.
The bounded compiler runner refuses new trials after `evidence/result.json`
exists. A newly authorized follow-up must preserve this terminal evidence and
use its own explicit scope and budget; deleting the terminal marker is not a
continuation mechanism.
