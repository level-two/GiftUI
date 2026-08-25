# Conservative stack analysis

The candidate's largest workload value is the scalar-only
`spike004_candidate_run` frame;
all point, subpath, plan, and raster payloads are static C arenas and never
appear as stack arrays. The linked disassemblies under
`.build/nrf52840/spike-004-*/reports/spike-004/disassembly.txt` are the
reproduction source. Counting saved registers and explicit stack adjustment
along the complete `main -> Swift entry -> candidate -> stroke` call graph gives
104 bytes for copy-to-plan, 92 bytes for sealed ranges, and 84 bytes for direct
emission. The matched baseline's deepest raster path is 36 bytes. Zephyr boot
and scheduler frames are outside this candidate-minus-baseline comparison.
These are conservative compile/link bounds, not connected-board high-water
measurements.
