# SPEC-013 T7.3 Static and Target Inspection Evidence

Evidence kind: host execution, compiler inspection, cross-build, and linked-
image inspection. No simulator, connected target, deployment, service restart,
or flashing was used.

## Result

The macOS Static and nRF52840 builds each specialize the concrete binding path
under whole-module optimization. Their path call inventories contain zero
allocator, generic-metadata allocator, Objective-C, reflection, task, thread,
or exception-personality references. Every Runtime Static-owned optimized SIL
body contains zero `alloc_ref`, `alloc_box`, existential-box, partial-apply, or
raw-allocation instructions. Both reports therefore record:

```text
irPathForbiddenReferences	0
silForbiddenInstructions	0
heapAllocations	0
peakHeapBytes	0
```

The linked nRF profile probe retains the specialized binding entry point and
reports `Tag_CPU_arch: v7E-M`, `Tag_FP_arch: VFPv4-D16`, and
`Tag_ABI_VFP_args: VFP registers`. Zephyr's image-level libc/runtime inventory
is not mislabeled as reachable profile code; the optimized profile-path call
inventory is the reachability boundary for forbidden facilities.

The Raspberry Pi compiler produced `GiftUIRuntimeDynamic.o` as
`elf32-littlearm`, and its optimized LLVM module reports exactly
`armv6-unknown-linux-gnueabihf`. The checker rejects any ARMv7 or AArch64 token.

## Commands

```sh
scripts/contracts/check-spec-013-static-profiles.sh --profile macos-static --output .build/spec013-t73-final/macos-static
scripts/contracts/check-spec-013-static-profiles.sh --profile nrf52840-embedded --output .build/spec013-t73-final/nrf52840-embedded
scripts/contracts/collect-spec-013-pi-target-evidence.sh .build/spec013-t73-final/raspberry-pi-armv6
scripts/contracts/check-spec-013-target-evidence.rb .build/spec013-t73-final
```
