# Independent complete-bound proof supplement

The original 686800bc packet remains immutable. `local_sp.py` fixes load/store
writeback and load-multiple register invalidation; the exact patch is included.
`phase-graph.json.xz` and `bounded.json` are corrected regenerated outputs.

Run `python3 reproduce-review.py` from this directory on the pinned repository
host. It checks original packet/member hashes, all 195 current/snapshot inputs,
the overlay hash and the frozen ELF SHA before executing read-only analysis in a
new temporary directory. It does not build or execute firmware. No Python cache
cleanup is performed. `reproduce.log` records the independent executable replay, which additionally
checks the aggregate bounds.

The replay deliberately rejects a changed ELF or source input. A different SHA
alone cannot authorize address-specific premises. Final-image requalification is
described in the independent review: freeze its new inputs/ELF, create an audited
address map, regenerate executable premise assertions and closure, then archive
and independently review that new proof. This supplement is not a portable
analyzer certification or a proof for a future link.
