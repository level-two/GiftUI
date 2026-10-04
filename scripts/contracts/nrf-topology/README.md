# Maintained nRF topology generation inputs

`generate-spec-001-nrf-topology.py` emits the packed topology writer and record
codec from the two registered measured projections, codec/scaffold templates
and explicit binding policy. Generated Swift is never an input. The default
command validates/render the complete pair before replacing maintained files;
`--output <empty-directory>` demonstrates clean emission, and `--check` compares
a clean pair with maintained outputs.

`policy.json` registers projection bytes and the four declaration source hashes
that produced them. A changed declaration or projection refuses generation
until the portable projection is remeasured and the registration is explicitly
reviewed/refreshed. Do not update hashes to suppress a stale-input failure.
These projections remain measured fixtures, rather than executable view source;
transitive changes require extending the registration and corresponding check.
Templates retain the packed codec and runtime algorithms. Policy retains the
specialized geometry and live binding assumptions; the application model
writers still contain ordinal mappings. CBR-002 is only partially addressed;
optional named roles remain under EXP-001 and runtime replacement is excluded.

`check-spec-001-nrf-topology.py` runs two empty-directory generations, byte
comparison and malformed/stale/unsupported input refusals, including no partial
publication. Validation also runs with Python optimization: production input
checks use explicit exceptions. The native checker compiles the actual selected
firmware against the maintained 42-case corpus and full 3,024-byte golden
transcript, including 84 refusal checks and 42 retirements. The golden fixture
was adopted from the reviewed original-production transcript; it is an oracle,
not an architecture source. Every intentional oracle change needs its own
contract explanation and reviewed evidence.
