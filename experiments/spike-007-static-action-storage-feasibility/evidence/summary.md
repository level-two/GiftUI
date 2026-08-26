# SPIKE-007 generated evidence

- Revision: `d97853c496f9eb4816c978c79483e74ee6642073`
- Swift: `Apple Swift version 6.3.2 (swift-6.3.2-RELEASE)`
- Zephyr: `4.3.0`; SDK: `0.17.4`
- Board: `nrf52840dk/nrf52840`; Swift target: `armv7em-none-none-eabi`
- Compile mode: `-Osize`, Embedded Swift, Cortex-M4F hard-float

## Semantic results

```text
append-first	pass	first record admitted
exact-once	pass	start:7
stale-generation	pass	old generation rejected
replacement	pass	start:7,start:8
disabled	pass	disabled record rejected
exact-capacity	pass	count=32
overflow	pass	count=32
```

## Resources and linked dependencies

```text
variant	flash_bytes	ram_bytes	datas_bytes	bss_bytes	fixed_delta	allocator_symbols	forbidden_introduced
baseline	25780	6016	40	1021	0	none	none
direct	26220	6016	48	1049	36	posix_memalign	none
tagged	26064	6012	68	1029	36	none	none
```

## Stack

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
