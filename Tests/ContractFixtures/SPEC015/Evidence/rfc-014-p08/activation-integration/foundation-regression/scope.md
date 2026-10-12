# Swift 6.4 Foundation compatibility — 2026-10-12

Parent owns the remaining SPEC-002 baseline checks required by the approved
compiler correction267616c9. The initial Static failure is preserved in the
resource-regression packet. Its interface uses Swift6.4 `Module::Type` spelling;
the existing surface checker expects `Module.Type`. No Foundation API changed.

Normalize recognized module qualification in the surface checker and preserve
forbidden-owner detection for both spellings in the boundary checker. Verify
the real interface and meaningful malformed-interface controls before running
the existing full RFC014 Foundation gate for all four profiles. Keep all access,
owner-set, provenance, allocation, layout and linked-section requirements.

Allowance: four initial full-profile invocations after this parser correction;
at most two narrowly justified compatibility repairs and affected reruns. Stop
after two consecutive failures without a new pass or diagnostic narrowing.
Do not weaken a contract or claim cross-target execution. Record exact outcomes,
source/compiler identities and resource artifacts before independent review.
