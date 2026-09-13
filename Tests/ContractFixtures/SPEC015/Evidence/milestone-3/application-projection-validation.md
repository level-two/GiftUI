# Application projection validation

The pure configuration slice validates action codes `0...5`, six declared
actions, one immutable total handler, one root target, publishable generation,
50,000-microsecond source spacing, 20 source callbacks per service window,
one callback per action/repository/use-case boundary, at most one non-transition
publication per action, an exact 28-fact executor limit, one admission adapter,
no retained owner reference, no reentrant callback, one normalized input source,
one target-local
presentation gate, one wake requester, distinct application/mutation domains,
and a non-reentrant wake declaration. The complete workload gate supplies the
matching executor, fact, observable, interaction, source-spacing, input, and
action limits before these stages run.

Focused tests independently vary every `HostActionModelConfiguration` and
`HostInputWakeConfiguration` field. Action/range/handler/callback defects
return `.invalidActionDomain`; root target defects return
`.invalidModelTarget`; source/gate defects return `.invalidInputIntegration`;
and requester/domain/reentrancy defects return `.invalidWakeIntegration` at
their exact ordered stages.

This is partial T3.5 evidence. Concrete invalid action decoding, stale target
generation/replacement races, and poisoned-lifetime proof that action records
and pointer capture retain neither the handler nor model remain open for the
T5.4 integration seam. This record does not claim those behaviors.

Reproduction:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIHostConfigurationTests
```
