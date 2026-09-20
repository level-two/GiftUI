# SPEC-001 T6.7 Dynamic Pi Correlation Allocation

The Dynamic Raspberry Pi target host now owns the four checked identity
allocators used by its production opportunities. Initial presentation reserves
one complete correlation tuple. Every later admitted opportunity reserves a
cycle identity, while semantic revision, candidate frame, and physical
presentation revision are reserved only if that opportunity has a changed
candidate to publish.

The focused hardware-free test proves exact zero-based initial identities,
monotonic changed-publication identities, and an unchanged opportunity that
advances only the cycle identity without leaving gaps in semantic, candidate,
or physical-presentation identity.

Reproduce with:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox -- \
    test --filter dynamicPiCorrelationOwnerReservesPublicationOnlyForChangedCycles
scripts/contracts/check-spec-001-harness.rb
swift package dump-package | scripts/contracts/check-spec-001-boundaries.rb
scripts/raspberry-pi/doctor.sh
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
```

These commands perform only local validation and ARMv6 cross-compilation. No
connected target is accessed.
