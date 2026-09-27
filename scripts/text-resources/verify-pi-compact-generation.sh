#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
python_command=${GIFTUI_TEXT_RESOURCE_PYTHON:-"${repository_root}/.toolchains/text-resource-generator/bin/python"}
temporary_root=$(mktemp -d "${TMPDIR:-/tmp}/giftui-pi-font.XXXXXX")
trap 'rm -rf "${temporary_root}"' EXIT HUP INT TERM

"${python_command}" \
    "${repository_root}/scripts/text-resources/generate-pi-compact-resources.py" \
    --output-directory "${temporary_root}/generated"
diff -ru \
    "${repository_root}/Sources/GiftUIReferenceTextResources/PiCompactGenerated" \
    "${temporary_root}/generated"
printf '%s\n' 'Pi compact text resource generation verified.'
