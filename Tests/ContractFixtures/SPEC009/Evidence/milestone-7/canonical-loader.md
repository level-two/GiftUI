# SPEC-009 T7.1 Canonical Loader Evidence

The canonical loader now validates every registered shared and domain field,
requires the literal `none` for inapplicable values, recursively accepts only
registered decimal symbolic identity tokens, and rejects address-, pointer-,
closure-, hash-, metatype-, or profile-private identity forms. Result checking
enforces the operational-event bitset and primary precedence and mirrors the
legal `RunCycleSummary` state matrix. Endpoint scripts use one exact closed
shape and cannot claim a stream result or irreversible output without a body.

`check-spec-009-canonical-loader.rb` builds one valid reference case in a
temporary fixture root and then proves fail-closed rejection of a missing
shared field, forbidden identity, wrong operational primary, illegal summary,
and incomplete endpoint script. Acceptance-criterion case lists remain
reciprocal, globally named, and tied to allowed evidence classes.
