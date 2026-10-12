# R07 first nRF prelink checkpoint — 2026-10-12

Entry0b224929; implementation worker interrupted by model capacity while
preparing this failure packet. Preserve the exact WIP, with no source correction
or compiler invocation by the receiving reviewer. Pi linked image remains its
separate committed source-specific result; four R06 routes remain native/object
results. nRF/R07/P08 are incomplete.

First command: scripts/nrf52840/build.sh --application signal-analyzer-static
--counter-build .build/nrf52840/contracts/p08-counter-7x97oi7d. Exit1 at
zephyr_pre0 link, before a final zephyr.elf/hex or verifier result.
[Exact invocation](nrf-attempt-1/invocation.json), [build output](nrf-attempt-1/build.log),
[source patch](nrf-attempt-1/source.patch), [verified object input receipt](nrf-attempt-1/input-receipt.json)
and [partial artifact identities](nrf-attempt-1/partial-build-identities.json)
are frozen; generated binaries stay under .build/nrf52840.

Preserved WIP: supported build.sh opt-in counter object handoff under the existing
application and distinct build directory; early CMake Counter.cmake branch;
counter_main.c supplies existing spi_tft_write_rgb565 after initialization and
shuts down after the finite corpus; counter-build-checks.conf selects existing
entry/driver/fault symbols and zero heap. No source repair, new application or
hardware action occurred at handoff.

Observed linker failures: GNU-style constructor section while STATIC_INIT_GNU
is disabled; two __divti3 references in RasterStrokeCoverage join coverage;
getentropy's unresolved __device_dts_ord_100. The first source diagnosis locates
existing GIFTUI_NRF_EMBEDDED safe division and existing firmware flags omitted
from the object route. GNU-init/entropy causes require separate reachability
assessment; no constructor/entropy feature or replacement builtin is approved
by the failure itself.

Existing main stack27648/heap0 and resource ceilings remain unchanged. The frozen
object-stack-prologues.txt contains only a newline: **no nRF object-frame fit
evidence was successfully captured**. Partial object/config/map presence is not
linked RAM/flash/ABI, stack-peak or allocator proof. No target execution,
deployment or flashing occurred.

This is the first nRF image invocation with no repair attempt. Historical
helper2/2 and B031/1 remain closed; the exact same-blocker rule is not exhausted
by this failure. Preserve WIP/evidence in a step commit, then independent review
dispositions local recipe correction versus actual new contract/scope decisions.
No P08 completion or permission to change owners, workload, limits, compiler/SDK
or runtime requirements is inferred.
