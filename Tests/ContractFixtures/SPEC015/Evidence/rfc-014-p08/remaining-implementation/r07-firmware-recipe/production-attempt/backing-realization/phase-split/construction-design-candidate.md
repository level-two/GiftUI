# P08 construction candidate — 2026-10-13

Status: unreviewed, design only. Source remains `63e717d1`; no compiler,
source, build, or link attempt follows the closed IR capture. This records
findings reported by the assigned Strong Sol 6.1 High worker, not an approved
construction design or evidence of stack fit.

## Candidate reported by the worker

- Keep `StaticCounterGeometry` as one ordinary typed caller local inside the
  existing geometry/control borrow scopes. Pass a geometry proxy and explicit
  nonescapable lease through supplied inputs/state instead of copying the bulk
  geometry payload through every owner/host transfer.
- For Embedded, replace inline interaction banks in host transfers with five
  protocol adapters to the original typed bank objects placed in the existing
  2,412-byte interaction slot. Do not add a logical bank, BSS reservation or heap.
- Preserve the existing factory and scoped owner values. The candidate intends
  to use existing pipeline Geometry/C/R/H generic parameters rather than change
  that pipeline's contract. Keep one shared control corpus and unchanged
  factory/escape/provenance oracles.

## Unproved obligations before implementation

The worker did not complete the exact field/layout, lease/alias initialization
and teardown map or exact file handoff. The following are explicitly UNKNOWN:

1. Whether the proposed proxy and explicit lease satisfy every existing generic
   constraint without a contract amendment or hidden escaping raw-pointer route.
2. Whether all five original typed banks fit, align and can be initialized in
   the existing interaction slot without overlapping another live owner.
3. How the original take/ownership transfer, foreign scope, identity, all
   logical instances and error/teardown ordering are preserved exactly.
4. Which concrete declarations change and how all native/Dynamic callers and
   generated negative tests remain valid.
5. Whether the compiled final nested call chain fits 27,648 bytes, including
   alignment and interrupt obligations. Source plausibility is not this proof.

Do not implement this candidate until a separate Strong review can turn these
obligations into a precise semantically valid plan. Do not raw-store a scoped
host/owner, change factory semantics, add capacity, relax limits, change
workload, or infer that pointer-backed storage is safe merely because it fits.

## Assignment accounting

Parent stopped the design-only worker's extended exploration and requested a
bounded written result. When that result remained unavailable, parent recorded
only the worker's reported candidate and unknowns here. No source implementation
or validation attempt was consumed by the interruption. No source/diagnostic
allowance is created or reset by this record. Review `77b72644` remains current:
P08/R07 fail the 58,648-byte construction-frame gate; all four source routes and
the supported image's link/ABI/RAM/flash checks retain their separate scope.
