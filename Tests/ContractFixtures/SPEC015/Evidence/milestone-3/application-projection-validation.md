# Application projection validation

The pure configuration slice validates action codes `0...5`, six declared
actions, one immutable handler, one root target, at most one non-transition
publication per action, one normalized input source, one target-local
presentation gate, one wake requester, distinct application/mutation domains,
and a non-reentrant wake declaration. The complete workload gate supplies the
matching executor, fact, observable, interaction, source-spacing, input, and
action limits before these stages run.

Focused tests independently vary every `HostActionModelConfiguration` and
`HostInputWakeConfiguration` field. Action/range/handler/publication defects
return `.invalidActionDomain`; root target defects return
`.invalidModelTarget`; source/gate defects return `.invalidInputIntegration`;
and requester/domain/reentrancy defects return `.invalidWakeIntegration` at
their exact ordered stages.

This is partial T3.5 evidence. Concrete invalid action decoding, stale target
generation, callback/admission projections, and proof that action records and
pointer capture retain neither the handler nor model remain open for the T5.4
integration seam. This record does not claim those behaviors.

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
