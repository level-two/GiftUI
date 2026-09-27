# Terminus 8×14 source for GiftUI 7×14

The Pi reference application derives 7×14 cells from Terminus 8×14 normal
BDF glyphs, version 4.49.1, by Dimitar Toshkov Zhekov. The generator verifies
that the rightmost column is empty for every selected glyph, then removes
that column from the cell width without changing the ink. The source and SIL
Open Font License 1.1 were extracted from the upstream release archive at
https://sourceforge.net/projects/terminus-font/files/terminus-font-4.49/
on 2026-09-27.

The source SHA-256 is
`fb6aaad8bebe5ee824e914635b3f4e17a82f1673dea37f083e9adde285d7de32`.
The license SHA-256 is
`c14f8d795784a547ea35e69c51dee2957bb71a1cdb492ec5321e4b61d3d97630`.
The Pi generator validates both before selecting the SPEC-001 glyph subset.
