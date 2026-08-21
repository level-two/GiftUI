# Conservative fixture stack analysis

The linked disassembly in
`.build/nrf52840/spike-003-candidate/reports/spike-003/disassembly.txt` gives a
64-byte Swift candidate frame (nine saved 32-bit registers plus 28 local
bytes). The Zephyr C `main` adds 8 bytes. The deepest candidate path is
`replace -> detach` (8 + 8 bytes), giving a conservative complete fixture
bound of **88 bytes**. The baseline Swift frame saves twelve registers (48
bytes); with C `main`, its bound is **56 bytes**. These bounds exclude Zephyr
boot/scheduler frames and are compile/link evidence, not a hardware high-water
measurement.
