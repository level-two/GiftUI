#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
compiler=${GIFTUI_SPEC005_SWIFTC:-"$(xcrun --find swiftc)"}
sdk=${GIFTUI_SPEC005_SDK:-"$(xcrun --sdk macosx --show-sdk-path)"}
target=${GIFTUI_SPEC005_TARGET:-arm64-apple-macosx26.0}
output_root=${1:-"$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec005-compositions.XXXXXX")"}
module_root="${output_root}/base/modules"
library_root="${output_root}/base/libraries"
module_cache="${output_root}/module-cache"
mkdir -p "${module_root}" "${library_root}" "${module_cache}"

foundation_source="${repository_root}/Sources/GiftUI/GiftUI.swift"
text_source="${repository_root}/Sources/GiftUITextResources/GiftUITextResources.swift"
reference_root="${repository_root}/Sources/GiftUIReferenceTextResources"
catalogue_source="${reference_root}/Generated/ReferenceCatalogue.generated.swift"
bitmap_source="${reference_root}/Generated/ReferenceBitmapPayload.generated.swift"
outline_source="${reference_root}/Generated/ReferenceOutlinePayload.generated.swift"
reference_source="${reference_root}/GiftUIReferenceTextResources.swift"
probe_source="${repository_root}/Tests/ContractFixtures/SPEC005/CompositionProbe/main.swift"

"${compiler}" -target "${target}" -sdk "${sdk}" -O -whole-module-optimization \
    -module-cache-path "${module_cache}" \
    -language-mode 6 -parse-as-library -package-name GiftUI \
    -emit-library -emit-module -module-name GiftUI "${foundation_source}" \
    -emit-module-path "${module_root}/GiftUI.swiftmodule" \
    -o "${library_root}/libGiftUI.dylib"
"${compiler}" -target "${target}" -sdk "${sdk}" -O -whole-module-optimization \
    -module-cache-path "${module_cache}" \
    -language-mode 6 -parse-as-library -package-name GiftUI \
    -I "${module_root}" -L "${library_root}" -lGiftUI \
    -emit-library -emit-module -module-name GiftUITextResources "${text_source}" \
    -emit-module-path "${module_root}/GiftUITextResources.swiftmodule" \
    -o "${library_root}/libGiftUITextResources.dylib"

build_composition() {
    name=$1
    expected=$2
    shift 2
    composition_root="${output_root}/${name}"
    composition_modules="${composition_root}/modules"
    composition_libraries="${composition_root}/libraries"
    sources_path="${composition_root}/sources.txt"
    transcript="${composition_root}/transcript.txt"
    mkdir -p "${composition_modules}" "${composition_libraries}"

    definition=""
    case "${name}" in
        complete) payload_sources="${bitmap_source} ${outline_source}" ;;
        bitmap-only)
            definition=-DGIFTUI_REFERENCE_BITMAP_ONLY
            payload_sources="${bitmap_source}"
            ;;
        outline-only)
            definition=-DGIFTUI_REFERENCE_OUTLINE_ONLY
            payload_sources="${outline_source}"
            ;;
        *) exit 2 ;;
    esac
    {
        printf '%s\n' "${catalogue_source#"${repository_root}/"}"
        for source in ${payload_sources}; do
            printf '%s\n' "${source#"${repository_root}/"}"
        done
        printf '%s\n' "${reference_source#"${repository_root}/"}"
    } >"${sources_path}"

    # shellcheck disable=SC2086
    "${compiler}" -target "${target}" -sdk "${sdk}" -O -whole-module-optimization \
        -module-cache-path "${module_cache}" \
        -language-mode 6 -parse-as-library -package-name GiftUI ${definition} \
        -I "${module_root}" -L "${library_root}" -lGiftUI -lGiftUITextResources \
        -emit-library -emit-module -module-name GiftUIReferenceTextResources \
        "${catalogue_source}" ${payload_sources} "${reference_source}" \
        -emit-module-path "${composition_modules}/GiftUIReferenceTextResources.swiftmodule" \
        -o "${composition_libraries}/libGiftUIReferenceTextResources.dylib"
    "${compiler}" -target "${target}" -sdk "${sdk}" -O -language-mode 6 \
        -module-cache-path "${module_cache}" \
        -package-name GiftUI -I "${module_root}" -I "${composition_modules}" \
        -L "${library_root}" -L "${composition_libraries}" \
        -lGiftUI -lGiftUITextResources -lGiftUIReferenceTextResources \
        -Xlinker -rpath -Xlinker "${library_root}" \
        -Xlinker -rpath -Xlinker "${composition_libraries}" \
        "${probe_source}" -o "${composition_root}/probe"
    DYLD_LIBRARY_PATH="${library_root}:${composition_libraries}" \
        "${composition_root}/probe" >"${transcript}"
    diff -u "${expected}" "${transcript}"
}

mkdir -p "${output_root}/expected"
printf '%s\n' \
    'resource_matches_adopted=true' \
    'instance_count=1' \
    'realization_count=2' \
    'bitmap_available=true' \
    'outline_available=true' \
    'bitmap_validation=valid' \
    'outline_validation=valid' \
    >"${output_root}/expected/complete.txt"
printf '%s\n' \
    'resource_matches_adopted=true' \
    'instance_count=1' \
    'realization_count=2' \
    'bitmap_available=true' \
    'outline_available=false' \
    'bitmap_validation=valid' \
    'outline_validation=invalid:4' \
    >"${output_root}/expected/bitmap-only.txt"
printf '%s\n' \
    'resource_matches_adopted=true' \
    'instance_count=1' \
    'realization_count=2' \
    'bitmap_available=false' \
    'outline_available=true' \
    'bitmap_validation=invalid:4' \
    'outline_validation=valid' \
    >"${output_root}/expected/outline-only.txt"

build_composition complete "${output_root}/expected/complete.txt"
build_composition bitmap-only "${output_root}/expected/bitmap-only.txt"
build_composition outline-only "${output_root}/expected/outline-only.txt"

grep -Fxq 'Sources/GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift' \
    "${output_root}/bitmap-only/sources.txt"
! grep -Fq 'ReferenceOutlinePayload.generated.swift' \
    "${output_root}/bitmap-only/sources.txt"
grep -Fxq 'Sources/GiftUIReferenceTextResources/Generated/ReferenceOutlinePayload.generated.swift' \
    "${output_root}/outline-only/sources.txt"
! grep -Fq 'ReferenceBitmapPayload.generated.swift' \
    "${output_root}/outline-only/sources.txt"

printf '%s\n' 'SPEC-005 reference composition check passed.'
