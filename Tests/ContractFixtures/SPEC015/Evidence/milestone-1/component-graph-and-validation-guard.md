# Component graph and validation guard

`GiftUIHostConfiguration` validates exactly eighteen role-ordered records in
constant storage. It rejects truncated graphs with the first missing role,
duplicate roles, out-of-order records, self/upward edges, and bits 18...31.
Because every admitted edge points to a lower raw-value role, an admitted
graph is acyclic without allocation or a traversal worklist.

The checked concrete validator owns a noncopyable one-shot state guard. Its
first call evaluates the nine ordered projections; every later call returns
graph-stage `invariantViolation` before another projection is read. Focused
tests also freeze host, role, validation-stage, and lifecycle raw values.

Reproduction:

```sh
scripts/format-swift.sh
CLANG_MODULE_CACHE_PATH="$PWD/.build/module-cache" \
SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/module-cache" \
swift test --disable-sandbox --filter GiftUIHostConfigurationTests
```
