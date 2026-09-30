# Pi packed projection candidate — 2026-09-28

SPEC-001 T8.1 remains blocked after the [connected measurement of the previous
candidate](pi-performance-candidate-measurement-20260928.md): 2,322 ms mean
frame service against a 250 ms period. The sink averaged 841 ms, with no
current-source internal subdivision. This record covers commit `e103a1b1`.

For a region whose physical width is exactly twice its logical pixel count
and whose destination pointer is 32-bit aligned, the Pi projection now writes
each duplicated RGB565 pixel pair as one little-endian 32-bit value. The
unaligned double-width and other scaling paths retain their bytewise writes.
Region ordering, row copying, mapped storage, and output bytes are unchanged.
This targets store count in the sink; its effect on the Pi is still unknown.

The aligned and unaligned projection tests passed. The host-native Pi exact
raster gate passed before the final pointer-alignment guard was tightened; the
focused projection tests passed after it. The final ARMv6 hard-float build
passed with ELF build ID `3f1b029d15aff461706c1eb26c29bc3cd38e109e`.
The [60-second connected run](pi-performance-packed-connected-20260928.log)
completed 25 steady frames. All 25 workload counts matched the prior
candidate trace. Mean frame service was 2,320.940 ms versus 2,322.267 ms
prior; mean sink time was 858.029 ms versus 840.534 ms. This did not establish
a speedup, so `6802154f` reverted the code. See the
[subsequent measurement](pi-performance-layout-lookup-measurement-20260928.md).

The approved pipeline still requests `.initializeCompleteSurface` on every
steady frame. The last connected run submitted about 220 KB through roughly
338 payloads and 3,913 regions per frame. This local optimization does not
remove full-frame derivation or the operation-major output volume. If further
measured local changes cannot meet T8.1, reducing steady-frame damage or
changing presentation ownership must be reviewed through the feature
lifecycle rather than introduced as an implementation detail.
