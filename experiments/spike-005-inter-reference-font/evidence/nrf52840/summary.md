# SPIKE-005 nRF52840 resource evidence

- Revision: 530e479bf9b484d98a9bf722d2dd995e772527c4 (dirty: 43 files)
- Board: nrf52840dk/nrf52840; ARMv7E-M hard-float ELF verified
- Zephyr: 4.3.0; SDK: 0.17.4
- Baseline ELF SHA-256: eebc722949b7bd3eb2305ff12edb4fffbf7ad69a5fb276cbd76e0948c452638c
- Candidate ELF SHA-256: f453802b3047e7ee452fa99f835b046eb16986c8ac6363523410250b1c40b213
- Two pristine builds produced identical normalized size results.
- Both configured heaps are zero; no allocator entry point remains linked.
- Host execution recomputed and accepted both SHA-256 digests.

| Metric | Baseline | Candidate | Delta | SPEC-005 draft ceiling |
| --- | ---: | ---: | ---: | ---: |
| Linked flash bytes | 22836 | 32060 | 9224 | 98304 |
| Linked RAM bytes | 4988 | 4988 | 0 | 512 |
| bss bytes | 1013 | 1013 | 0 | 512 |
| data bytes | 28 | 28 | 0 | 512 |
| Conservative validation call-chain stack | 0 | 568 | 568 | 1024 |

The stack value sums GCC static stack-usage results along the complete
main -> spike005_validate -> spike005_validate_inputs -> validate_digest ->
update call chain. It is
not a connected-hardware high-water measurement. No board was flashed or run.
