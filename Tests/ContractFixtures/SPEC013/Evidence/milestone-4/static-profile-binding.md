# SPEC-013 T4.5 Static Profile Binding and Allocation Evidence

Date: 2026-09-12

`StaticRuntimeProfileBinding` binds generated fixed regions and the generated
Canvas metadata/table to Runtime Core's single lifecycle. The storage owns the
table used for both startup audit and invocation, so no secondary dispatch
registry or fallback representation exists. A staged occurrence contains only
its typed identity, nonzero ID, declared size, state, counter, and inline
capture; invocation borrows that capture into the generated table.

The optimized proof compiles the production Runtime Static sources together
with a concrete fixed profile under whole-module optimization. This makes the
exact construction, reservation, staging, cleanup, finalization, and
quiescence path visible rather than relying on unspecialized generic metadata.
The gate records the path's call-symbol list and rejects references to allocator
entry points, generic metadata allocation, Objective-C, reflection, tasks, and
threads. It separately scans every owned optimized SIL body for reference,
closure-box, existential-box, partial-apply, or raw-allocation instructions.

Results:

- macOS Static: `irPathForbiddenReferences = 0`,
  `silForbiddenInstructions = 0`; 13 focused Runtime Static tests passed and
  the test image linked.
- nRF52840 Embedded Swift: `irPathForbiddenReferences = 0`,
  `silForbiddenInstructions = 0`; the specialized binding body remains in the
  linked ELF and the image reports ARMv7E-M, VFPv4-D16, and VFP-register
  arguments.
- Source inspection: 16 distinct generated inline regions, 51 fixed counters,
  one generated callable-table conformance, shared lifecycle delegation, and
  no dynamic collection, class storage, allocation API, `Any`, reflection,
  closure fallback, sibling runtime, backend, or host dependency.

Verification commands:

```text
scripts/contracts/check-spec-013-static-storage.rb
scripts/contracts/check-spec-013-static-profiles.sh --profile macos-static
scripts/contracts/check-spec-013-static-profiles.sh --profile nrf52840-embedded
scripts/contracts/check-spec-013-module-contract.sh
scripts/contracts/check-spec-013-harness.rb
```

This is host execution, compiler inspection, cross-build, and linked-image
inspection evidence. The nRF build was not flashed and is not connected-board
evidence.
