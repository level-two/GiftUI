# T1.2 Storage Audit Accounting

`RuntimeStorageAudit.checked` sums all sixteen exclusive byte fields in
contract order with checked `UInt32` arithmetic and returns
`.invalid(.arithmeticOverflow)` instead of saturating. Focused tests preserve
every field, verify the exact total, exercise overflow, and demonstrate the
required zero-byte alias representation when a complete overlay extent is
charged to one owner.

`storage-families.tsv` records one unique byte owner for every audit field,
its lifetime, simultaneous families, overlay charging rule, and excluded
allocator-bookkeeping, stack, and generated-code bytes.
`scripts/contracts/check-spec-013-storage-registry.rb` checks the exact field
set and proves its duplicate-owner rejection oracle.

Reproduce from the repository root:

```sh
swift test --filter RuntimeStorageAudit
scripts/contracts/check-spec-013-storage-registry.rb
```

This is host accounting and registry evidence only. Concrete dynamic/static
capacity audits and resource measurements land in later tasks.
