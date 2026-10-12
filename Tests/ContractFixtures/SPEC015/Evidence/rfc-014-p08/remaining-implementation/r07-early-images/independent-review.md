# Independent R07 first nRF failure review — 2026-10-12

Preserved step commit `5a8ea206` contains the exact WIP and completed
[failure packet](nrf-result.md); source bytes were not corrected by the reviewer.
**No nRF image/resource acceptance. Bounded existing-recipe correction may
continue under current authorization.** No new human approval gate follows from
the current failures. Pi `0b224929` remains its separate linked ARMv6 result;
R06's four native/object results do not establish linked nRF feasibility.

This Strong sequential review used source/frozen evidence, hashes and read-only
ELF object inspection with the installed SDK readelf/objdump. No compiler, test,
target executable, image rebuild, source fix, deployment or hardware action ran.
All24 supplied object hashes, seven partial-build identities and invocation
source-patch hash matched. Old receipts and partial artifacts were left intact.

## Existing-recipe causes

The route compiles current counter owners for armv7em-none-none-eabi, but its
flags are not yet the full supported firmware image recipe. Existing
firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt:358–390
supplies GIFTUI_NRF_EMBEDDED, function sections, disable-stack-protector,
short enums, noPIC/noPIE, picolibc includes and Zephyr C flags. R06 fresh modules
have the function-section/disable-stack-protector pair, but omit the other
image selections. The reused base GiftUI.o lacks that pair too. Source-only
target compilation success did not validate those image requirements.

RasterStrokeCoverage.swift:21–58 already selects its bounded unsigned division
and signed divideWide implementation under GIFTUI_NRF_EMBEDDED. Omitting that
existing define selects ordinary Int128 division and explains the two __divti3
references from join coverage. Selecting the supported branch is a recipe fix;
adding a compiler builtin, changing stroke semantics or supplying an ad hoc
division implementation is neither necessary nor justified by this observation.

The partial map further narrows the other errors: it pulls picolibc's
libc_ssp_stack_protector.c.o for **GiftUI.o's __stack_chk_guard**, and
libc_stdlib_arc4random.c.o for **GiftUI.o's arc4random_buf**. Read-only sections
of all24 supplied Swift objects contain no init_array/ctors; the pulled picolibc
stack-protector member contains a four-byte init_array. This is a concrete
constructor source, rather than evidence the counter requires a new startup
constructor contract. The old base object embeds unsectioned runtime code;
its disassembly contains the random calls. Exact live reachability after the
correct firmware selections and dead stripping remains unproved.

Zephyr's current config disables STATIC_INIT_GNU and ENTROPY_GENERATOR.
getentropy.c uses DEVICE_DT_GET_OR_NULL(DT_CHOSEN(zephyr_entropy)); its selected
device ordinal100 is unresolved. The map includes getentropy through Zephyr's
whole-archive POSIX library and the random-library dependency. This does not
prove the actual counter needs an entropy device. Do not enable GNU constructor
startup, entropy hardware, deterministic random stubs or fake device symbols
merely to silence the first link. Reassess the corrected image's actual map and
undefined references before proposing any such runtime change.

## Gross resource evidence limits

The frozen object-stack-prologues.txt is one newline, not captured stack evidence.
Read-only spot inspection sees ordinary object prologues, including a small C
entry thunk and a larger endpoint initializer; these neither bound the actual
root/corpus call chain nor establish fit. No maximum/whole-chain stack number
can be accepted from this packet. Main stack27648, zero heap, RAM196608 and
flash1048576 remain unchanged. The partial pre0 map/archive/config are not a
final linked LOAD/section/symbol/ABI result, and the object/archive file length
is not runtime RAM/flash consumption.

The corrected recipe must capture the actual retained C root, selected Static
host/corpus and relevant callees' frames and evaluate gross fit before hardware
execution. Even individual local-frame fit would remain weaker than a peak
bound. A frame exceeding27648 is an immediate gross-fit failure; do not hide it
with the old hardcoded entry-stack figure, a larger stack/heap, fewer assertions,
or an alternate workload. Pi's documented local frame/LOAD numbers remain
qualified Pi-only evidence, not a substitute.

## Bounded implementation handoff

1. Reuse the **existing supported firmware owner source/flag recipe** to produce
   fresh image-specific objects including the base GiftUI owner and affected
   selected consumers. Keep owner modules separate, macro/toolchain/SDK pins
   unchanged, actual counter root and synchronous spi_tft_write_rgb565 handoff,
   immutable limits/workload, and zero heap. The preserved Counter.cmake branch
   currently bypasses the normal owner compilation flags; selecting the normal
   approved flags for its current sources is ordinary local realization.
2. Record exact source/flag/object/receipt applicability in a new isolated
   target build location. Do not overwrite historical core/R06 receipts,
   silently relax preflight hashes or rerun old package studies. This is a new
   current-image realization, not compiler/SDK/dependency regeneration. No new
   library or flattened owner bridge is justified.
3. Format changed maintained source, invoke the bounded supported route/image
   recipe, preserve every result, and inspect the resulting live sections and
   references. If GNU-init/entropy remains reachable, identify its exact root
   before selecting another correction. A genuinely necessary new runtime
   constructor/entropy behavior, owner, API, resource ceiling or workload change
   requires its smallest explicit upstream decision; none is established yet.
4. Only a final linked image can support its own ARMv7EM/VFP, RAM/flash,
   allocator/zero-heap and gross-stack disposition. Stop for that independent
   result review; do not convert partial objects into image or P08 completion.

First nRF image failure has no repair attempt. The base stop rule concerns two
consecutive repairs of the same blocker without a passing check or narrowed
cause; current source/flag and map narrowing is meaningful progress, not an
exhausted allowance. Historical helper2/2 and B031/1 stay permanently closed.
Current authorization permits this bounded recipe correction and fresh validation,
not reopening those experiments. P08/T8.1/R07 stay open; P09–P12 pending.
