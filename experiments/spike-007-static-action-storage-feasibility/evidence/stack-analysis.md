# Conservative fixture stack analysis

The linked disassemblies give these complete fixture bounds, including the
8-byte C `main` frame:

- baseline: **8 bytes**; the Swift entry is a tail call and creates no frame;
- direct stored closure: **80 bytes** on the deepest
  `Swift entry (32) -> install (24) -> allocation wrapper (16)` path; and
- generated tagged callable: **56 bytes** on the deepest
  `Swift entry (32) -> install (16)` path.

The bounds exclude Zephyr boot and scheduler frames and are hardware-free
call-graph evidence, not connected-board stack high-water measurements.
