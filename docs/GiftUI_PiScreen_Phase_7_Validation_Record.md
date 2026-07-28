# GiftUI PiScreen Phase 7 Validation Record

This record separates the completed hardware-free optimization and hardening
work from results that require the exact nRF52840-DK/PiScreen assembly. Leave
unperformed checks as `Not run`; a successful build is not endurance evidence.

## Software baseline

| Item | Value |
| --- | --- |
| Firmware application | `ili9486` |
| Board target | `nrf52840dk/nrf52840` |
| Display clock candidate | 4 MHz; not yet accepted on hardware |
| Touch clock maximum | 2 MHz |
| Renderer tile candidate | 480 × 4 × 2 bytes |
| SPI pixel segment candidate | 3,840 bytes maximum |
| Dirty update | Union of previous and updated thermostat layout bounds |
| Heap | Zephyr system heap 0; C allocation arena 0; fail-closed Swift ABI shim |
| Runtime telemetry | Transfer time, release-to-visible latency, stack high-water, one-minute heartbeat |
| Fault categories | Capacity, display controller, display SPI, touch controller, touch SPI |
| Hardware-free linked flash | 57,680 bytes |
| Hardware-free linked RAM | 37,504 bytes, including the 32 KiB main stack |

The build must emit ARMv7E-M hard-float ELF, HEX, map, Devicetree, symbol, and
memory reports under `.build/nrf52840/ili9486/` without flashing hardware:

```bash
scripts/nrf52840/doctor.sh
scripts/nrf52840/build.sh --application ili9486
```

## Prerequisite gates

Do not power or flash until the hardware provenance, supply, backlight,
continuity, and shared-bus isolation gates in the Phase 5 ILI9486 and Phase 6
ADS7846 records have passed. Flashing remains an explicit connected-board step:

```bash
scripts/nrf52840/flash.sh --application ili9486 --no-build
```

## Transfer tuning matrix

Run each candidate only after the 4 MHz baseline is visually stable. Record raw
UART samples and logic-analyzer evidence. Do not accept a faster clock merely
because it boots once.

| Display clock | Tile rows | Segment bytes | Full frame median/worst | Dirty update median/worst | Touch responsive | Corruption/reset count | Result |
| ---: | ---: | ---: | --- | --- | --- | --- | --- |
| 4 MHz | 4 | 3,840 | Not measured | Not measured | Not run | Not run | Not run |
| Candidate | Candidate | Candidate | Not measured | Not measured | Not run | Not run | Not run |

Accept the smallest tile/segment combination that preserves correct rendering,
keeps touch responsive, and satisfies the 150 ms dirty-update target with safe
stack margin. Record the accepted values in tracked configuration, not only in
a local binary.

## Resource and latency results

Collect at least 500 completed alternating thermostat taps in one session.
Calculate latency from every `release to visible update` UART sample.

| Measurement | Acceptance criterion | Result |
| --- | --- | --- |
| Linked flash | At most 1 MiB; 896 KiB warning threshold | 57,680 bytes |
| Linked RAM | At most 192 KiB | 37,504 bytes |
| Main-stack high-water | At least 25% measured margin after worst case | Not measured |
| Median release-to-visible latency | Reported from at least 500 taps | Not measured |
| Worst release-to-visible latency | At most 150 ms | Not measured |
| Missed/repeated actions | Zero | Not run |
| Fault totals in nominal run | All remain zero | Not run |

## Fault-path checks

| Check | Acceptance criterion | Result |
| --- | --- | --- |
| Capacity rejection | Invalid region/byte counts return a bounded error | Hardware-free path implemented; connected check not run |
| Display SPI interruption | Render returns; fault count advances; no retry loop | Not run |
| Touch SPI interruption | Pressed state clears; display/event loop remains live | Not run |
| PENIRQ read failure | Polling backs off by 100 ms; no log spin | Not run |
| Repeated fault logging | First eight and power-of-two counts only | Not run |
| Recovery after safe reconnection | Requires documented result; no implicit reset assumption | Not run |

Only introduce faults with the panel safely powered and without shorting signal
or supply rails. Do not hot-plug an unverified adapter.

## Endurance and power-cycle results

Run the accepted configuration continuously for at least eight hours while
alternating touch activity and idle periods. Preserve the UART log containing
every one-minute heartbeat. Then perform at least 50 complete power cycles with
a cold-off interval long enough for the panel and DK rails to discharge.

| Measurement | Acceptance criterion | Result |
| --- | --- | --- |
| Continuous duration | At least 8 hours | Not run |
| Heartbeat gaps | None beyond one interval plus test-control tolerance | Not run |
| Successful updates | Monotonic; count recorded | Not run |
| Unexpected fault count | Zero | Not run |
| Visual corruption | Zero occurrences | Not run |
| Watchdog/fatal reset | Zero occurrences | Not run |
| Cold power cycles | At least 50 | 0 |
| Successful boots/calibrations/renders | Every cycle | 0 |
| Stuck touch after cycle | Zero occurrences | Not run |

## Phase 7 disposition

The hardware-free Phase 7 implementation is ready for connected-board
validation. The phase gate remains open until the exact assembly passes the
prerequisite hardware gates, transfer tuning, resource and latency checks,
fault injection, eight-hour endurance run, and 50 cold power cycles with the
results captured above.
