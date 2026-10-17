# Witness compatibility candidate1 — fixture validity STOP

Source/commands frozen at `22589fec`; candidate1/1, no automatic source repairs.
The one execution stops on an **independently invalid public positive fixture**.
It does not establish a macro-source failure. No source/test/runner/fixture edit
or retry followed. [Independent grouped fixture review](../p08-witness-annotation-compatibility-fixture-review.md)
passes the exact constraint-only continuation below; no continuation has run.
Fixing a test's validity does not require or grant a production source repair.

Macro compile/link and **all17 maintained macro tests** pass with zero failures/
skips, including existing ordinary expansion fixtures, checked-helper negatives
and actual Counter/multiple/nested output expansion and parsing. Fresh actual
lowering and GiftUI/schema/presentation compilation pass. The five previously
clean privacy controls pass again, with every negative error classified. Ordinary
private/fileprivate/internal/package hosts with private State compile successfully.

The public ordinary fixture fails with exactly one error:
`generic struct cannot be declared public because its generic parameter uses a package type`.
Its header uses `D: CounterReadDomain`; the fresh generated schema declares that
protocol `@usableFromInline package`, which grants ABI usability but not public
source access. This is a test signature defect, independent of the macro's
private-State/annotation behavior. Public compatibility remains unproved.

The [result](result.json) records all18 attempted of22 prepared stages and the
four unrun controls. [Raw evidence](result-evidence.tar.gz) and its
[hash manifest](result-manifest.json) freeze all command arrays, logs, provider
modules/objects, new macro/runner, generated source/expansion, maintained source,
failed fixture and all remaining fixtures. No physical decoder/helper/callee,
actual consumer/host, safety or strict cold/reuse gate ran. Source stays frozen
and unaccepted; P08/R07/T8.1 remain open. Five external files, pycache and original
authored inputs retain their recorded hashes.

## Exact fixture-only review boundary

These archived sources were reviewed together before continuation:

| Member under `attempt/` | Current state and proposed correction |
| --- | --- |
| `privacy/ordinary-public.swift` | Failed; replace only generic constraint `CounterReadDomain` with public `_GiftUIReadDomain`. |
| `privacy/ordinary-abi.swift` | Unrun public host with private evaluation dependency; same constraint-only correction. |
| `privacy/ordinary-enclosing-private.swift` | Unrun public inner host in private enclosure; same constraint-only correction. |
| `privacy/scope-twin.swift` | Unrun, unchanged valid explicit-D.Type source; same module/source argv differs only package `giftui`/`outside` in `stages.json`. |

Exact access references are fresh `attempt/CounterSchema.swift:2` (package
`CounterReadDomain`) and maintained `Sources/GiftUI/DeclarativeView.swift:14`
(public `_GiftUIReadDomain`). Ordinary fixtures use only EmptyView and concrete
Counter State schema/seed; their evaluation needs no CounterReadDomain operation.
The proposed constraint change preserves their intended private-backing and
nonserialized-evaluation tests. Keep the Counter schema/seed private State,
Domain/evaluation access, original macro calls and all17 frozen maintained tests.
Neither protocol nor provider source is to be widened. The repaired FrameRead
twins still need their actual positive and isolated package-access negative runs.

No correction file or continuation invocation was created or executed here.
The independent review permits three constraint-only corrected positives and the
unchanged scope twins against the exact frozen modules/plugin, with fresh output
receipts and a stop on the first unexpected failure. Original fixture/log bytes,
macro/tests and candidate1/1 remain frozen; no source candidate/allowance reset.
