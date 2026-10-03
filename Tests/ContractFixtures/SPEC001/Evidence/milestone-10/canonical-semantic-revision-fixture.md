# Current nRF native semantic revision fixture — 2026-10-03

The final registered driver passed reviewed raster comparison, then its
standalone full-layout fixture trapped on the initial semantic revision.
An unoptimized diagnostic identified its exact assertion: revision 3.

The production common-runner activation owns a fresh zero-initialized semantic
allocator. Its first candidate increments to 1 and the next changed candidate
to 2. Standalone pre-activation validators do not consume that live allocator.
The fixture still expected legacy shared-validator revisions 3 and 4 from
before the T10.6 canonical join. Both assertions now require exact canonical
1/2 values; no assertion or other layout, Drawing, input, refusal, replacement
or lifetime condition is removed. No production code, pixel or firmware changes.

`scripts/contracts/check-spec-001-nrf-full-layout-native.sh` passes all its
conditions with the actual owner-separated native production sources. The
registered nRF profile is rerun afterward. Raw validation is archived in the
final approved-pixel closure packet. This corrects fixture applicability;
it does not grant a contract exception or physical-hardware acceptance.
