# SPEC-011 Contract Fixtures

These fixtures are the ordered, profile-neutral oracle for Button interaction.
`fixture-manifest.tsv` is the closed inventory. The five YAML corpora use stable
row identifiers and may be extended only with a matching manifest and
`task-evidence.yaml` edge. `normalized-transcript-schema.tsv` excludes compiler,
address, timing, and profile-private fields. `resource-schema.tsv` separates
host execution, cross-build inspection, simulator, and connected hardware.

The driver rejects duplicate or unknown rows, unreferenced corpus entries,
missing task/criterion edges, and profile-private normalized fields.
