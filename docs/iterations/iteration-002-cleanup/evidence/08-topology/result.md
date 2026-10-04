# Clean topology generation

2026-10-05. SPEC-001 T11.4 complete.

Both topology outputs are emitted from empty directories using registered normal/diagnostic projections, explicit codec/scaffold templates and reviewed specialized binding policy. Previous generated output is never an input. Two independent runs match maintained bytes exactly; default regeneration and check mode are idempotent. Registered declaration/projection freshness is checked, and 18 malformed/stale/unsupported/nonempty-input refusals leave no partial output. Runtime checks remain enabled with Python optimization.

The 42-case research semantic corpus is now maintained independently under Tests/ContractFixtures/SPEC001, with 84 wrong-size/variant refusals and 42 retirements. It compiles the selected production firmware; all complete 3,024-byte transcripts match the original-production golden fixture exactly. The native checker is invoked explicitly by SPEC-001 nRF; the cheap clean-generation/refusal gate is registered in the aggregate runner. Three runner fixtures still pass (28 assertions).

[Paired images](paired-images.json): flash 274,272 → 274,272; RAM 191,104 → 191,104. ABI, heap/allocator/refusal-stub and stack reservation checks pass. Packed storage, runtime algorithm and specialized model writers are preserved. CBR-002 is partially addressed: geometry/live binding policy and model ordinal mappings remain; named runtime roles stay excluded under EXP-001. Projections cover the four registered declaration sources; a transitive change requires extending/refreshing registration, not an inferred freshness pass.

Reproduce: `python3 scripts/contracts/check-spec-001-nrf-topology.py`, `python3 -O scripts/contracts/generate-spec-001-nrf-topology.py --check`, `scripts/contracts/check-spec-001-nrf-topology-native.sh`, and the normal nRF build. See [generation](generation.log), [native](native.log), [build](firmware-build.log), [governance](governance.log).
