# Step 13 — Startup text-probe retirement assessment

Research at `c8bf4560`; maintained code remains unchanged. The disposable
candidate is reconstructed by [the runner](check-startup-text-candidate.py).

## Concrete experiment and result

The candidate removes both EmbeddedTextMeasure/EmbeddedTextPlace fragments
from an isolated production closure. The actual firmware startup text function
uses `LayoutEngine` and `StaticSignalAnalyzerNRFCommonLayoutWorkspace` over a
one-text semantic adapter. It preserves the original font/glyph checks,
packed line/glyph round-trip, nonempty output, publish/readback and reset
invalidation checks. It does not replace the packed codecs or workspace.

Both original and candidate compile and execute the firmware's full native
layout/Drawing harness. Added startup assertions cover success, null pointer,
wrong region size and repeated success/reuse. The harness also exercises full
diagnostic layout, Canvas, repository/input actions and failure teardown.
[Native commands and outputs](evidence/13-startup-text-candidate.json).

A separate focused SwiftPM run passes five existing semantic/codec/workspace
checks. The semantic test compares legacy and shared-engine packed scope/text
bytes for every text identity in its published diagnostic state, at 480×320
and origin (7,11). It is not a parameterized all-state text test.
[Execution log](evidence/13-focused-tests.txt).

| Pinned nRF linked metric | Original | Candidate | Delta |
| --- | ---: | ---: | ---: |
| Flash bytes | 275,600 | 274,304 | −1,296 |
| RAM bytes | 191,104 | 191,104 | 0 |

Both ELFs report ARMv7E-M/VFP arguments and disabled Zephyr/libc heaps. Neither
retains malloc/calloc/realloc/aligned_alloc/swift_allocObject. Both retain the
existing `posix_memalign` refusal stub, whose disassembly returns ENOMEM (12).
Stack reservations are unchanged; physical high-water is unmeasured.
[ELF identities, sizes, configuration and stub evidence](evidence/13-startup-text-elf.json).
The original is the unchanged Step 11 production build; the candidate copies
its application/configuration and references the same repository sources and
paired compiler, changing only the reconstructed startup implementation and
selected duplicate files. Native execution substitutes hardware.

## Coverage that must survive a production cleanup

| Check | Existing owner / disposition |
| --- | --- |
| Exact region size, alignment, acquisition, append/readback and reset | Keep EmbeddedLayoutWorkspace and scope/text codec suites |
| Invalid index and exact text/glyph capacity | Keep codec/workspace negative cases; these do not need the duplicate algorithms |
| Diagnostic UTF-8, CR/LF and bounded lines | Preserve semantic-region test; move its byte assertions to shared-owner expectations rather than keeping retired algorithms as an oracle |
| Shared text arithmetic, wrapping, clipping and overflow | Keep GiftUILayout tests and resource validator; add a startup-sized title expectation and CR/LF/empty/first-excess cases through the shared adapter |
| Startup publication/readback and failure cleanup | Keep original codec half of the startup function; shared-engine half must reset on failure and invalidate published views on release |
| Source selection | Remove the two entries from firmware CMake and update focused comparison tests in the same change; audit native/generated compile inputs |

The experiment supports a small CBR-003 maintenance candidate: retire the two
startup-only algorithms and use the shared owner. Production selection still
needs the explicit negative/overflow corpus migration above and affected
profile gates. No blanket claim of equivalent text behavior, measured timing,
or safe stack reduction follows from the flash saving.

## Reproduction

Run `python3 docs/iterations/iteration-002-review/check-startup-text-candidate.py`
after the production firmware/native-owner build. The generated application
is under `.build/nrf52840/iteration-002-startup-text/application`. Build that
copy with `west build`, sourcing `scripts/nrf52840/common.sh` and using its
paired compiler, board, Ninja and DTC options as in `scripts/nrf52840/build.sh`.
Run `measure-research-elf.py` with the two build directories; the JSON records
all native commands and source/ELF hashes. No flash or deployment is involved.
