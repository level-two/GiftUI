# SPEC-006 T6.1 Portable Declaration Evidence

The four standalone profile commands compile the same manifest-driven client
fixtures. Every public fixture imports only `GiftUI`; the corpus includes an
ordinary external conformance, an invalid external conformance, builder arity
boundaries, unsupported dynamic array syntax, and inaccessible wrapper
initializers and storage.

Each profile records the pinned compiler, target, optimization mode, repository
revision, exact command transcript, compiled module, and emitted textual public
interface. The Raspberry Pi and nRF52840 paths are cross-build evidence only;
they do not deploy, execute on, or flash connected hardware.
