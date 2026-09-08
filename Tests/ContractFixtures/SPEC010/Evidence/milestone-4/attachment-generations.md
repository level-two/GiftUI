# SPEC-010 T4.1 Attachment-Generation Evidence

The profile-neutral allocator owns one checked runtime-wide `UInt32`
generation cursor. It issues raw zero first, advances across registration
slots, issues `UInt32.max` exactly once, and then returns
`registrationGenerationExhausted` permanently without wrapping, reusing a
value, or reserving a sentinel.

Each reservation constructs the complete underscored attachment and derives
the opaque `ObservableTargetGeneration` from the same generation bits. A
recycled slot therefore rejects an attachment from its former lifetime while
accepting the fresh full slot-generation pair. Focused initial and replacement
exhaustion fixtures prove that no registration becomes active on initial
failure and that an existing live registration remains active and reportable
when replacement reservation fails.

```sh
swift test --filter ObservableStateAttachmentGenerationAllocatorTests
ruby scripts/contracts/check-spec-010-attachment-generations.rb
```

The allocator does not select slot storage or implement replacement. Atomic
candidate installation and former-registration retirement remain T4.2.
