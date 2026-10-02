# T10.6 — Shared finite contracts and canonical interaction increment

2026-10-02. RuntimeOwnerFailure, host residual policy contracts, and application
failure policy values retain their original declarations in independently selected
source files. The Embedded source list imports their actual modules without
pulling coordinator/profile conveniences into the bounded owner closure.

The Static interaction adapter now uses RuntimeInteractionCandidateCoordinator,
RuntimeInteractionCandidateTransaction, and RuntimeActionGenerationAllocator.
Its target projection borrows the already registered generated model; it does
not create a second observable registration or state store. Candidate generation
and committed routing remain distinct.

The application runtime failure rule is shared by class and caller-owned owners.
Its finite packed sequence preserves mandatory effect order, as well as allowed
policy dispositions; it does not substitute enum order for required effect order.
Eleven focused failure/interaction regressions pass. The selected Embedded owner
build passes ABI, no-heap and resource checks. The live complete-runner join is
still being validated; this increment does not complete T10.6.
