# SPEC-011 T8.3 Static Allocation and Workspace Evidence

SPEC-011 consumes the profile-owned measurements produced by the matching
SPEC-013 immutable report. The static profile probe covers construction,
candidate and committed record storage, hit routing, pointer capture, action
decode, target lookup, nonescaping model borrow, and direct handler dispatch.
Its optimized SIL/IR and linked-image scans reject allocation, closure-box,
existential-box, reflection, task/thread, Objective-C, and generic-metadata
facilities and report zero heap allocations and zero peak heap bytes.

The exact-limit fixture uses 32 action records, 32 hit regions, and four input
sources. The report retains candidate/committed/profile workspace and
stage-by-stage stack high-water values separately rather than folding them
into a single total. Both macOS Static and nRF52840 Static paths are required;
the corresponding Dynamic modes retain their bounded allocation and
bookkeeping reports for comparison.

Reproduce by running the four exact SPEC-011 drivers. Each verifies and hashes
the matching SPEC-013 report before publishing its own result. Cross-target
results are artifact inspection, not device execution.
