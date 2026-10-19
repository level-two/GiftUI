# U01 residual environment correction — 2026-10-19

This applies only B1 from the [independent preparation review](independent-review.md)
at `42a61c25`. All six complete decoder dictionaries now explicitly set
`DYLD_FALLBACK_LIBRARY_PATH=/usr/lib` and
`DYLD_FALLBACK_FRAMEWORK_PATH=/System/Library/Frameworks`. The proposed
bootstrap/controller policy uses those same restrictions. No HOME fallback,
ambient environment, developer framework override or new operation is added.

[loader-policy.json](loader-policy.json) records the complete base dictionaries,
absolute Xcode interpreter, isolated `-I -S -B -X pycache_prefix=/dev/null` flags
and the only exact interpreter-added values permitted at bootstrap:
`LC_CTYPE=C.UTF-8` and `__CF_USER_TEXT_ENCODING=0x1F5:0x7:0x3D`.
LLVM alone receives the already pinned decoder `DYLD_LIBRARY_PATH`.

[loader-roots.json](loader-roots.json) freezes **8,720** entries in three
applicable non-system roots: the complete Python framework version, the complete
adjacent Xcode toolchain library root conservatively covering Apple tool
dependencies, and the complete explicit LLVM decoder library root.
[loader-aliases.json](loader-aliases.json) records **72** symlinks, resolved
endpoints and applicable file hashes/sizes, including the interpreter entry.
Every non-system endpoint is inside those authenticated roots. Complete
membership, content and aliases require reauthentication at launch and each
decoder boundary; existence alone is insufficient.

The installed Apple system loader and `/usr/lib` and `/System/Library` runtimes
remain the explicit OS trust boundary. The fallback directories exist. This
does not freeze a portable OS image, qualify a historical counter runtime,
extract a cache or waive U01's provider/cold-cost proof.

The [preparation program](prepare-loader.py) only read directories/file bytes and
wrote these manifests. It launched no child. Inventory regeneration updates the
six proposed dictionaries without launching a decoder or controller. The output
root is still absent, historical collection1/1 remains consumed, and strict cold
remains ineligible. Concrete controller preparation and independent readiness
review remain separate prerequisites; this correction grants no launch or retry.
