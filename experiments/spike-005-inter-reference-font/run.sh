#!/bin/sh
set -eu

experiment_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
python_command=${SPIKE_005_PYTHON:-python3}
temporary_root=$(mktemp -d "${TMPDIR:-/tmp}/giftui-spike-005.XXXXXX")
trap 'rm -rf "$temporary_root"' EXIT HUP INT TERM

"$python_command" -m venv "$temporary_root/venv"
"$temporary_root/venv/bin/pip" install \
    --disable-pip-version-check \
    --require-hashes \
    --no-deps \
    -r "$experiment_dir/requirements-macos-arm64-py39.txt"

"$temporary_root/venv/bin/python" "$experiment_dir/generate.py" \
    --source-font "$experiment_dir/source/Inter-Regular.ttf" \
    --output-root "$temporary_root/first"
"$temporary_root/venv/bin/python" "$experiment_dir/generate.py" \
    --source-font "$experiment_dir/source/Inter-Regular.ttf" \
    --output-root "$temporary_root/second"

diff -ru "$temporary_root/first" "$temporary_root/second"

if [ "${1:-}" = "--verify" ]; then
    diff -ru "$experiment_dir/generated" "$temporary_root/first/generated"
    for evidence_file in SHA256SUMS coverage.json measurements.json toolchain.json; do
        diff -u \
            "$experiment_dir/evidence/$evidence_file" \
            "$temporary_root/first/evidence/$evidence_file"
    done
    printf '%s\n' 'SPIKE-005 verification passed.'
else
    mkdir -p "$experiment_dir/generated" "$experiment_dir/evidence"
    cp -R "$temporary_root/first/generated/." "$experiment_dir/generated/"
    cp -R "$temporary_root/first/evidence/." "$experiment_dir/evidence/"
    printf '%s\n' 'SPIKE-005 assets generated deterministically.'
fi
