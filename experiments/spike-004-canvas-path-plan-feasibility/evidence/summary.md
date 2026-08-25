# SPIKE-004 generated evidence

- Revision: f30645c3044b0712eaa1d855487ac5b3e37f2d9e (dirty: true)
- Swift: Apple Swift version 6.3.2 (swift-6.3.2-RELEASE)
- Zephyr: 4.3.0; SDK: 0.17.4
- Board: nrf52840dk/nrf52840; target: armv7em-none-none-eabi
- Build: -Osize, Embedded Swift, Cortex-M4F hard-float, linker GC
- Workload: 400 transitions; 808 trace + 12 grid segments; 836 points; 16 subpaths; 5 strokes/operations
- Allocator: Zephyr heap 0; libc arena 0; no retained allocator entry point

## Static workspace model

| Workspace | Baseline | Copy plan | Sealed ranges | Direct |
| --- | ---: | ---: | ---: | ---: |
| Plan points (8 bytes each) | 0 | 6,688 | 6,704 (838 incl. 2 mutation points) | 0 |
| Current Path points (8 bytes each) | 0 | 6,424 | included above | 6,424 |
| Plan subpaths (8 bytes each) | 0 | 128 | 136 (17 incl. mutation subpath) | 0 |
| Current Path subpaths (8 bytes each) | 0 | 96 | included above | 96 |
| Stroke records (24 bytes each) | 0 | 120 | 120 | 0 |
| Backend RGB565 tile | 3,840 | 3,840 | 3,840 | 3,840 |
| Backend RGB565 span | 960 | 960 | 960 | 960 |
| Backend transfer buffer | 3,840 | 3,840 | 3,840 | 3,840 |
| Producer workspace total | 0 | 13,456 | 6,960 | 6,520 |
| Conservative complete fixture stack | 36 | 104 | 92 | 84 |

Linked image measurements are in resources.tsv. Semantic and exhaustion
evidence is in semantic-results.tsv. Copy and sealed-range plans produce the
same canonical maximum-workload digest, preserve snapshot and painter order,
validate failure before offer, and are synchronously consumed without retaining
a borrow. Direct emission produces the same successful rows but the bounded
late sink-exhaustion fixture leaves one irreversible row, so it cannot satisfy
the no-partial-output requirement without pre-recording/reinvocation.

## Target-question disposition

| Question | Result | Evidence |
| --- | --- | --- |
| Q1 finite cycle-local plan | pass | Both plan candidates fit fixed arenas for 836/16/5. |
| Q2 linked/resource comparison | pass | resources.tsv, workspace table, stack analysis, and operation counts. |
| Q3 snapshot/ordering/checked/exhaustion semantics | pass | Shared host fixtures pass; zero heap and forbidden-symbol checks pass. |
| Q4 pre-offer/no-partial failure | pass for plans; fail for direct | Plan failure leaves zero sink rows; direct late exhaustion leaves one. |
| Q5 bounded RGB565 synchronous consumer | pass | 3,840-byte tile + 960-byte span + 3,840-byte transfer; borrow not retained. |
| Q6 accepted-ADR compatibility | pass for plan candidates | Normalized ordered strokes and synchronous one-shot offer remain intact; no ADR change is required by the experiment. |

The evidence establishes feasibility, not a production representation,
capacity, raster algorithm, API, or architectural approval.
