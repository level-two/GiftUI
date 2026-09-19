# SPEC-011 T8.4 Layout and Resource Audit

The composed SPEC-013 report records exact layouts for the Runtime profile
contract aggregates and every profile-owned storage family, including
Interaction candidate and committed records. It separately records configured
capacity, byte capacity, observed high water, stage stack bounds, timing
samples, generated-code/capture costs, linked sections, flash, RAM, and
Dynamic allocator bookkeeping.

The Static audit scans source, optimized SIL/IR, object symbols, final link
maps, and linked artifacts. It rejects closure boxes, reflection or metadata
discovery, unrestricted existentials, allocator calls, task/thread and
Objective-C facilities, indirect registries, and retained handler/model
references. Direct typed action decode and dispatch are retained in the
optimized path.

Every SPEC-011 driver verifies the immutable SPEC-013 report before recording
its run identity and metadata digest. This composes resource evidence without
moving profile storage or measurement policy into Interaction.
