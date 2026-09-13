# Source and import boundary scan

The SPEC-015 source-boundary check reads the frozen module-owner registry and
requires every `GiftUIHostConfiguration` import to be registered and outside
the forbidden focused-owner set. It scans the portable Signal Analyzer layers,
runtime/profile owners, capabilities, backend owners, and focused framework
owners to reject upward imports of `GiftUIHostConfiguration`.

The same scan rejects ambient process, environment, defaults, dynamic-loader,
and runtime-class lookup tokens from host-configuration sources. This is the
early-safe source/import portion of T7.1; integrated negative, lifecycle,
action/input, failure, and resource corpora remain pending.

Reproduction:

```sh
scripts/contracts/check-spec-015-source-boundaries.rb
```
