# SPIKE-003 generated evidence

- Revision: `a74340b11fc07529c6a795d882a8c2a745a65f91` (dirty: true)
- Host: macOS 26.3 arm64
- Swift: Apple Swift version 6.3.2 (swift-6.3.2-RELEASE)
- Zephyr: 4.3.0; SDK: 0.17.4
- Board: `nrf52840dk/nrf52840`; Swift target: `armv7em-none-none-eabi`
- Compile mode: `-Osize`, Embedded Swift, Cortex-M4F hard-float; linker GC enabled
- Baseline SHA-256: `e3b2be0ba8ed6ffc44e58b90563b925caba73e54db783ebf7e1f6cc58f960736`
- Generated-handle SHA-256: `83725206e7829918edf48aa52922ba8fa7fc0260988be22fee1b00b968076c3c`
- Direct-class SHA-256: `262312efc20b9293878925e57efdb2868ff71f83a17ccc772232f95fb0cdb1b6`

| Metric | Baseline | Generated handle | Delta |
| --- | ---: | ---: | ---: |
| Linked RAM bytes (ELF LOAD) | 8060 | 8060 | 0 |
| Linked flash bytes (ELF LOAD files) | 26232 | 26680 | 448 |
| `bss` bytes | 1049 | 1087 | 38 |
| Model storage bytes | 24 | 32 | 8 |
| Of which generated owner-token bytes | 0 | 8 | 8 |
| State-location bytes | 0 | 4 | 4 |
| Registration bytes | 0 | 8 | 8 |
| Dirty/live bits | 0 | packed in location | 0 separate |
| Generation / stale protection bytes | 0 | 2 | 2 |
| Instrumentation counters (Spike only) | 0 | 16 | 16 |
| Generated descriptors | 0 | 0 | 0 |
| Conservative complete fixture stack | 56 | 88 | 32 |

The generated-handle image has zero configured Zephyr and libc heaps and no
retained allocator entry point. Relative to the linked baseline, it introduces no
reflection, `Any` storage, task-local binding, Apple Observation, Objective-C,
exception, `Task`, or thread-primitive reference. Zephyr's common baseline
still contains its ordinary kernel thread implementation; it is not introduced
by the candidate.

The direct-class image compiles and links, but an escaping class retains
`swift_allocObject -> posix_memalign`. The fixture's `posix_memalign` shim
always returns `ENOMEM`, so the class cannot materialize under the zero-heap
configuration. A non-escaping class was stack-promoted but cannot satisfy
state preservation across transient view reconstruction.

Host semantic results are in `semantic-results.tsv`; all dynamic-class and
static-handle cases pass with equivalent normalized outcomes. Bounded operation
counts are in `operation-counts.tsv`. The source-level declaration is
`@State var model: ObservableModel` in ordinary and Embedded Swift fixtures.

The generated typed handle therefore passes all SPIKE-003 semantic,
compile/link, bounded-storage, stale-report, and zero-heap checks. It proves
feasibility of a generated/static representation with explicit model-owned
setter signaling; it does not select a production API or capacity.
