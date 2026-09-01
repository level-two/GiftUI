#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
python_command=${GIFTUI_TEXT_RESOURCE_PYTHON:-"${repository_root}/.toolchains/text-resource-generator/bin/python"}
temporary_root=$(mktemp -d "${TMPDIR:-/tmp}/giftui-reference-generation.XXXXXX")
trap 'rm -rf "${temporary_root}"' EXIT HUP INT TERM

if [ ! -x "${python_command}" ]; then
    printf '%s\n' 'reference generator toolchain is missing; run scripts/text-resources/setup-reference-generator.sh' >&2
    exit 1
fi

generate() {
    destination=$1
    "${python_command}" \
        "${repository_root}/scripts/text-resources/generate-reference-resources.py" \
        --source-font "${repository_root}/ThirdParty/Inter-4.1/Inter-Regular.ttf" \
        --license "${repository_root}/ThirdParty/Inter-4.1/LICENSE.txt" \
        --output-directory "${destination}"
}

generate "${temporary_root}/first"
generate "${temporary_root}/second"
diff -ru "${temporary_root}/first" "${temporary_root}/second"

if [ "${1:-}" = "--update" ]; then
    generated_root="${repository_root}/Sources/GiftUIReferenceTextResources/Generated"
    rm -rf "${generated_root}"
    mkdir -p "${generated_root}"
    cp -R "${temporary_root}/first/." \
        "${generated_root}/"
    printf '%s\n' 'SPEC-005 reference resources generated deterministically.'
elif [ "${1:-}" = "" ] || [ "${1:-}" = "--verify" ]; then
    diff -ru \
        "${repository_root}/Sources/GiftUIReferenceTextResources/Generated" \
        "${temporary_root}/first"
    printf '%s\n' 'SPEC-005 reference resource generation verification passed.'
else
    printf 'unknown argument: %s\n' "$1" >&2
    exit 2
fi
