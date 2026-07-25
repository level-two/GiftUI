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
- exits cleanly on `SIGINT` and `SIGTERM`;
- sleeps while idle instead of busy-looping.

The Linux application loop also exposes input-source and event-dispatch
contracts. A physical input adapter is intentionally a subsequent platform
slice.

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

4. Give the unprivileged runtime user access to the framebuffer, normally
   through the `video` group:

   ```bash
   sudo usermod -aG video giftui
   ```

5. Log out and back in after changing group membership.

The concrete overlay name is deliberately not hard-coded: products sold as a
“3.5-inch PiScreen” use more than one controller and overlay. Confirm the
controller or vendor image before editing the boot configuration.

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
    --device /dev/fb1
```

Useful variations:

```bash
# Rotate output clockwise for the physical mounting.
giftui/bin/GiftUIExampleThermostatRaspberryPi --rotation 90

# Validate one frame and release the device.
giftui/bin/GiftUIExampleThermostatRaspberryPi --once

# Use the primary framebuffer if the panel appears there.
giftui/bin/GiftUIExampleThermostatRaspberryPi --device /dev/fb0
```

Startup logs report the selected device, physical dimensions, pixel depth,
logical dimensions, and rotation. Failures to open, inspect, map, or present
the framebuffer include the underlying Linux error.

## Next platform slices

The current target establishes rendering and deployment. Remaining PoC B work
is intentionally separated:

1. add a Linux evdev or GPIO input source;
2. add focus navigation for button-only input;
3. validate the exact PiScreen overlay and rotation on hardware;
4. add a service unit after the device path and permissions are confirmed;
5. consider DRM presentation if the selected kernel panel driver exposes a
   DRM connector rather than fbdev.
