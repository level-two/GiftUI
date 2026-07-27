# GiftUI Raspberry Pi Platform

## Current platform slice

The `GiftUIExampleThermostatRaspberryPi` product is the first operable
Raspberry Pi platform target. It:

- cross-compiles for Raspberry Pi 1 as
  `armv6-unknown-linux-gnueabihf`;
- runs the same `ThermostatView` module as the macOS simulator;
- renders through `GiftUIRuntimeDynamic` and
  `GiftUIBackendFramebuffer`;
- presents RGBA8888 pixels to a Linux framebuffer device;
- supports 16-, 24-, and 32-bit framebuffer layouts;
- handles framebuffer stride, offsets, aspect-fit scaling, and clockwise
  rotation;
- reads single-contact evdev touchscreens and maps their absolute coordinates
  through the same aspect-fit and rotation transform as the framebuffer;
- reads three GPIO buttons through the libgpiod character-device API;
- applies independent monotonic 35 ms debouncing;
- maps previous/next/activate input to visible focus and GiftUI activation;
- exits cleanly on `SIGINT` and `SIGTERM`;
- sleeps while idle instead of busy-looping.

## PiScreen model

This implementation uses the Linux-managed SPI mode from the PoC B
specification:

```text
ThermostatView
    ↓
GiftUI dynamic runtime
    ↓
RGBA8888 memory framebuffer
    ↓
GiftUIPlatformLinux fbdev adapter
    ↓
/dev/fb1
    ↓
kernel PiScreen driver
    ↓
SPI panel
```

GiftUI does not initialize the panel or send raw SPI commands. The Raspberry
Pi OS Device Tree overlay/driver must expose the PiScreen as a framebuffer
device. This keeps controller-specific code outside the renderer and allows a
different kernel-supported panel to be selected with `--device`.

## Raspberry Pi preparation

After booting the prepared Raspberry Pi OS Bookworm image:

1. Enable SPI and configure the Device Tree overlay supplied for the exact
   PiScreen/controller revision.
2. Reboot.
3. Verify the framebuffer:

   ```bash
   ls -l /dev/fb*
   fbset -fb /dev/fb1
   ```

4. Install the GPIO runtime and diagnostics:

   ```bash
   sudo apt install -y libgpiod2 gpiod
   gpioinfo /dev/gpiochip0
   ```

5. Give the unprivileged runtime user access to the framebuffer, input, and
   GPIO character devices, normally through the `video`, `input`, and `gpio`
   groups:

   ```bash
   sudo usermod -aG video,input,gpio giftui
   ```

6. Log out and back in after changing group membership.

The concrete overlay name is deliberately not hard-coded: products sold as a
“3.5-inch PiScreen” use more than one controller and overlay. Confirm the
controller or vendor image before editing the boot configuration.

## GPIO buttons

The default wiring uses line offsets/BCM GPIO numbers that are normally free
on a 512 MB Raspberry Pi 1 Model B:

| Action | BCM GPIO | Header pin | Connection when pressed |
| --- | ---: | ---: | --- |
| Previous | 17 | 11 | GPIO to GND |
| Next | 27 | 13 | GPIO to GND |
| Activate | 22 | 15 | GPIO to GND |

The default input is active-low and requests the kernel pull-up bias. Do not
connect a GPIO input to 5 V. Confirm that the PiScreen overlay does not claim
these lines; use the CLI line options if it does. Line numbers are GPIO chip
offsets, not physical header pin numbers.

If the GPIO controller rejects bias configuration, use an external pull-up
resistor and pass `--gpio-bias disabled`.

The adapter requests both edges from `libgpiod.so.2`, filters for the configured
pressed edge, and debounces each button independently using the kernel's
monotonic event timestamp. It never blocks the GiftUI application loop.

## Touchscreen

Enable the PiScreen's evdev touchscreen with `--touch`. The default device is
`/dev/input/event0`; prefer a stable `/dev/input/by-path/...` link when more
than one input device may be attached. GiftUI reads `ABS_X`, `ABS_Y`, and
`BTN_TOUCH` without blocking and emits pointer-down, pointer-move, and
pointer-up events.

The kernel-reported absolute axis ranges are detected at startup. Touch
coordinates are mapped into framebuffer pixels, rejected in aspect-fit black
bars, and transformed back through the selected GiftUI `--rotation`.

Resistive touch orientation varies across PiScreen revisions and Device Tree
configurations. Prefer configuring `invx`, `invy`, or `swapxy` on the
`piscreen` overlay. For runtime-only calibration, use `--touch-invert-x`,
`--touch-invert-y`, and `--touch-swap-xy`. Do not apply the same transform in
both places.

Inspect the live device before running GiftUI:

```bash
grep -A12 -B2 -i touchscreen /proc/bus/input/devices
evtest /dev/input/event0
```

## Build and deploy

On the Mac:

```bash
scripts/raspberry-pi/doctor.sh
scripts/raspberry-pi/build.sh \
    --product GiftUIExampleThermostatRaspberryPi
scripts/raspberry-pi/deploy.sh \
    --product GiftUIExampleThermostatRaspberryPi
```

The build script rejects artifacts that are not ARMv6 hard-float ELF
executables. The deploy script also requires the remote host to report
`armv6l`.

Configure SSH defaults in the ignored
`scripts/raspberry-pi/local.env` file:

```bash
GIFTUI_PI_HOST="giftui-pi.local"
GIFTUI_PI_USER="giftui"
GIFTUI_PI_REMOTE_DIR="giftui/bin"
GIFTUI_PI_PRODUCT="GiftUIExampleThermostatRaspberryPi"
```

## Run

For the default PiScreen framebuffer:

```bash
giftui/bin/GiftUIExampleThermostatRaspberryPi \
    --display fbdev \
    --device /dev/fb1 \
    --touch \
    --gpio-buttons
```

Useful variations:

```bash
# Rotate output clockwise for the physical mounting.
giftui/bin/GiftUIExampleThermostatRaspberryPi --rotation 90

# Validate one frame and release the device.
giftui/bin/GiftUIExampleThermostatRaspberryPi --once

# Use the primary framebuffer if the panel appears there.
giftui/bin/GiftUIExampleThermostatRaspberryPi --device /dev/fb0

# Enable a stable touchscreen path and adjust runtime axis orientation.
giftui/bin/GiftUIExampleThermostatRaspberryPi \
    --touch-device /dev/input/by-path/platform-20204000.spi-cs-1-event \
    --touch-swap-xy \
    --touch-invert-x

# Override GPIO chip offsets and debounce time.
giftui/bin/GiftUIExampleThermostatRaspberryPi \
    --gpio-chip /dev/gpiochip0 \
    --gpio-previous 5 \
    --gpio-next 6 \
    --gpio-activate 13 \
    --gpio-debounce-ms 50
```

Startup logs report the selected device, physical dimensions, pixel depth,
logical dimensions, and rotation. Failures to open, inspect, map, or present
the framebuffer include the underlying Linux error.

GPIO mode starts with the first GiftUI action focused. Previous and next wrap
through the current hit regions and redraw an amber focus border. Activate
sends pointer-down and pointer-up events at the focused region's center, using
the same application dispatch path as pointer input.

## Next platform slices

The current target establishes rendering and deployment. Remaining PoC B work
is intentionally separated:

1. validate the exact PiScreen overlay, rotation, and GPIO lines on hardware;
2. validate touch orientation and calibration on the selected panel;
3. add a service unit after the device path and permissions are confirmed;
4. consider DRM presentation if the selected kernel panel driver exposes a
   DRM connector rather than fbdev.
