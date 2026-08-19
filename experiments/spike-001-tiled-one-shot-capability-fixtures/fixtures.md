# SPIKE-001 Frozen Fixture Inputs

These values were fixed before the resolver and raster prototype were run.
They are experiment data, not a GiftUI API or production configuration.

| Fixture | Extent | Tile | Producer encodings | Display encodings | Produced lifetime | Accepted lifetime | Expected |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `TILED-PI-POS` | 240 x 240 | 240 x 16 (7,680 bytes) | RGB565 | RGB565, XRGB8888 | offer-scoped | synchronous borrow | available |
| `TILED-NRF-POS` | 480 x 320 | 480 x 4 (3,840 bytes) | RGB565 | RGB565 | offer-scoped | synchronous borrow | available |
| `ENCODING-NEG` | 480 x 320 | 480 x 4 (3,840 bytes) | RGB565 | XRGB8888 | offer-scoped | synchronous borrow | no common canonical pixel encoding |
| `LIFETIME-NEG` | 480 x 320 | 480 x 4 (3,840 bytes) | RGB565 | RGB565 | offer-scoped | retained asynchronous borrow | incompatible downstream submission lifetime |
| `ENCODING-CONTROL` | 480 x 320 | 480 x 4 (3,840 bytes) | RGB565 | RGB565 | offer-scoped | synchronous borrow | available |
| `LIFETIME-CONTROL` | 480 x 320 | 480 x 4 (3,840 bytes) | RGB565 | RGB565 | offer-scoped | synchronous borrow | available |

Every fixture uses the required opaque operation set, synchronous borrowed
one-shot delivery, synchronous handoff, one in-flight submission, 16 KiB
maximum staging, and a tile workspace exactly equal to the stated tile size.
The negative/control pairs differ only in the named display contribution.

The two positive raster executions use this deterministic operation order:

1. damage the full normalized extent;
2. opaque black clear;
3. inset opaque blue fill;
4. white rectangle stroke crossing tile boundaries;
5. positioned 5 x 5 bitmap glyph;
6. set a right-edge clip; and
7. opaque red fill partly outside that clip.

No fixture uses target identity, backend identity, discovery, reflection, or
random input.
