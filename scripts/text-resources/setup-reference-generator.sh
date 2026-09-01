#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
environment_root="${repository_root}/.toolchains/text-resource-generator"
python_command=${GIFTUI_TEXT_RESOURCE_BOOTSTRAP_PYTHON:-python3}

"${python_command}" -m venv "${environment_root}"
"${environment_root}/bin/pip" install \
    --disable-pip-version-check \
    --require-hashes \
    --no-deps \
    -r "${repository_root}/scripts/text-resources/requirements-macos-arm64-py39.txt"

"${environment_root}/bin/python" \
    "${repository_root}/scripts/text-resources/generate-reference-resources.py" \
    --check-tools-only
printf '%s\n' 'SPEC-005 reference generator toolchain is ready.'
