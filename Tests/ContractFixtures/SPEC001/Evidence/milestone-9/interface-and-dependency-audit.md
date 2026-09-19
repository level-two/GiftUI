# SPEC-001 T9.1 Interface and Dependency Audit

- Package targets: exact Domain → Data and Domain/GiftUI/FailureCore → Presentation graph
- Generated presets: four immutable roots with Static storage declarations where required
- Portable interfaces: no forbidden platform, timing, concurrency, renderer, display, or hardware imports
- Action surface: exactly six qualified cases and one total noncapturing handler
- Failure representation: structural typed terminal failure with no `String` or general `Error` payload
- Negative dependency fixtures: 13 ordered allow/reject cases
- Result: pass

Reproduce with `scripts/contracts/check-spec-001-interface-audit.sh`. The four
registered hardware-free profile drivers compile the same declarations with
their pinned host/cross compilers; no SPEC-001 profile substitutes a local
contract or skips an owner fixture.
