# SPEC-001 T6.7 Dynamic Pi Wake Pacing

The Dynamic Raspberry Pi target host now owns one shared pacing controller for
repository fact callbacks, queued normalized input, and the serialized
application opportunity. The fact-admission decorator records work only after
bounded admission succeeds. The first admitted item requests a wake; later
facts and input coalesce into that outstanding wake. The generated Dynamic
preset determines the earliest application-opportunity boundary.

The hardware-free contract test proves that rejected facts remain silent,
accepted facts and queued input share one accumulated reason, an opportunity
cannot begin before the generated boundary, completion releases the active
gate, and quiescence rejects later work. The callback does not enter the
runtime or mutate the application synchronously.

Reproduce with:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox -- \
    test --filter dynamicPiWakePacingOwnerCoalescesFactAndInputIngress
scripts/contracts/check-spec-001-harness.rb
scripts/contracts/check-spec-001-boundaries.rb
scripts/raspberry-pi/doctor.sh
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
```

The Raspberry Pi commands perform only local toolchain diagnostics and an
ARMv6 cross-build. This evidence does not claim connected execution or deploy
to a remote target.
