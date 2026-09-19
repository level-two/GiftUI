# SPEC-003 Connected Raspberry Pi Evidence

**Task:** `T6.2` complete

**Recorded:** 2026-09-19

The separately authorized connected runner selected
`giftui@giftui-pi.local`. Because local mDNS was unavailable, the run used
`192.168.55.44` with `HostKeyAlias=giftui-pi.local`; the address presented the
same saved ED25519 host key before any deployment. The target reported
`armv6l`, Raspberry Pi Model B Rev 2 hardware, and Raspbian GNU/Linux 12
(bookworm) with kernel `6.12.93+rpt-rpi-v6`.

The clean-revision immutable report is:

```text
.build/contract-reports/spec-003-connected-pi/c49e8a5435d9c165050cba5bafb24d3d975f7fd4-e4ee76f196fa126b/
```

It records repository revision
`c49e8a5435d9c165050cba5bafb24d3d975f7fd4`, Apple Swift 6.3.2
(`swift-6.3.2-RELEASE`), target `armv6-unknown-linux-gnueabihf`, release `-O`
whole-module optimization, all commands, target identity, artifact identity,
raw samples, and copied resource reports.

## Connected latency

The connected target executed the same SPEC-003 production-path corpus after
1,000 warm-up iterations. All 10,000 measured values are retained in
`latency-samples.txt`.

| Warm-up | Samples | p99 | Limit | Status |
| ---: | ---: | ---: | ---: | --- |
| 1,000 | 10,000 | 5,000 ns | 150,000 ns | pass |

The local and remote probe SHA-256 values both equal
`9807f0bbe3b5c835c3578683e12e13e8f010627274419889f89246659addc21a`.
The runner deployed atomically through the repository Raspberry Pi workflow,
restarted no service, and recorded `teardown=removed` from the same SSH
session that executed the corpus.

## ARMv6 resource evidence

The runner regenerated the hardware-free matched-image evidence from the same
revision under resource run
`c49e8a5435d9c165050cba5bafb24d3d975f7fd4-fdec1b1c538b44bb` and copied its
section and call-graph reports into the connected report.

| Metric | Measured | Limit | Status |
| --- | ---: | ---: | --- |
| Writable RAM, candidate minus baseline | -40 B | 512 B | pass |
| Linked code, candidate minus baseline | 24,388 B | 24,576 B | pass |
| Absolute worst stack | 40 B | 384 B | pass |

## Reproduction

```sh
scripts/contracts/run-spec-003-connected-pi.sh \
  --host 192.168.55.44 \
  --user giftui \
  --host-key-alias giftui-pi.local
```

This evidence completes only SPEC-003 `T6.2` and `FAIL-AC-19`. It does not
claim the separately owned PiScreen display/input gates: the selected target
exposed an ADS7846 touchscreen but no `/dev/fb0` and no connected DRM display
during the campaign inventory.
