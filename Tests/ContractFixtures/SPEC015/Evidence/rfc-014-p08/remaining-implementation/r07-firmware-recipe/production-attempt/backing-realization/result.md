# R07 backing realization checkpoint — 2026-10-12

P08/R07 remain incomplete. Design step `19d07b6e` and source step `38ba440d`
implement the bounded caller-owned Embedded backing direction independently
reviewed in `71c833a9`. This checkpoint preserves completed native validation;
it is not independent acceptance of the backing implementation or target fit.

| Current source route | Result | Evidence |
| --- | --- | --- |
| macos-static | exit 0; 1,349,555 assertions, zero failures | [invocation](native-invocation.json), [exit](native-exit.json), [receipt](macos-static/result.json) |
| macos-dynamic | exit 0; 1,349,501 assertions, zero failures | [invocation](macos-dynamic-invocation.json), [exit](macos-dynamic-exit.json), [receipt](macos-dynamic/result.json) |

Both runs use source `38ba440d`. Their commands, logs and receipts are preserved;
generated objects/executables remain in the recorded `.build/` directories.
The formatter passed before the source commit. No validation repair occurred.
Native success does not validate the Embedded-only storage realization.

The implementation worker hit selected-model capacity after the completed native
runs; retrying the same Sol 6.1 High worker failed again, and the separate Strong
worker also returned a capacity error before recovering the handoff. Root copied
the existing Static logs/receipt and recorded this mechanical checkpoint without
substituting a model, changing source or claiming independent review. Capacity
failures are not compiler attempts or repair-count resets.

## Exact remaining boundary

1. Continue the existing receipt's sequential current-source Raspberry Pi and
   nRF cross-route checks; no backing-realization target run is recorded yet.
2. Use the fresh verified nRF receipt for the supported counter firmware build.
3. Inspect final ABI/GOT/allocator, total RAM/flash and actual nested entry,
   graph, host, initialization and corpus stack use against unchanged limits.
4. Obtain separate Strong result review, then independent P08 package exit review
   after all required current-source evidence is available.

Do not rerun the two passing native checks solely because of this handoff.
The previously linked `e5620a35` image and its 32,344/121,216-byte failing frames
remain historical evidence; they neither validate nor measure `38ba440d`.
The backing correction has not yet established target feasibility. No stack,
heap, capacity, workload, runtime, toolchain or contract change is authorized.
Historical helper 2/2, B03 1/1, GOT diagnostic 1/1 and earlier supported-image
1/1 allowances stay closed; continue only the reviewed backing-realization scope.
No hardware action occurred. SPEC-015 remains implementing, its plan active;
T8.1/HC-RD-003/P08 remain open, and P09–P12 remain pending.
