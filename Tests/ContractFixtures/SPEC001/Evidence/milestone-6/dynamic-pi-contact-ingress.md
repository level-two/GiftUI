# SPEC-001 T6.7 Dynamic Pi Contact Ingress

The production Dynamic Pi target-host boundary now accepts already decoded
PiScreen contact phases and feeds them through the existing normalized-input
gate. The gate remains the sole owner of source, sequence, ordinal, and
physical-presentation correlation. Only successfully queued events notify the
shared pacing owner; the first requests a wake and later contacts coalesce.
Rejected or stale contacts do not request runtime work, and contact admission
does not enter an application opportunity or mutate the model synchronously.

The hardware-free fixture creates the exact down/move/up sequence with
`PiScreenContactDecoder`, maps those contacts into the target-host ingress,
and proves three queued events produce one wake request plus two coalesced
wakes. A stale-presentation contact is rejected without changing the pending
wake reason.

Reproduce with:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox -- \
    test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
    --filter dynamicPiDecodedContactsEnterNormalizedAdmissionAndWakePacing
scripts/contracts/check-spec-001-harness.rb
swift package dump-package | scripts/contracts/check-spec-001-boundaries.rb
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
```

This is a hardware-free decoded-contact join. The Linux device-file poll loop,
remote input, display behavior, and connected execution remain unclaimed.

The ARMv6 executable boundary now also contains
`LinuxSignalAnalyzerPiInputPump`. Its typed poll call reads the real nonblocking
`LinuxPiScreenTouchDevice`, maps every decoded event without another
calibration or phase translation, and submits the batch to this ingress with
the current physical presentation revision and monotonic timestamp. The ARMv6
cross-build proves this concrete device-to-host seam compiles; the surrounding
process scheduling loop and connected behavior remain open.
