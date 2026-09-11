#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
source "$PROJECT_ROOT/scripts/nrf52840/common.sh"
giftui_nrf_require_environment
EVIDENCE_DIRECTORY="${1:-}"

TEMPORARY_DIRECTORY="$(mktemp -d "${TMPDIR:-/tmp}/giftui-spec007-embedded.XXXXXX")"
trap 'rm -rf "$TEMPORARY_DIRECTORY"' EXIT
MODULES="$TEMPORARY_DIRECTORY/modules"
mkdir -p "$MODULES" "$TEMPORARY_DIRECTORY/module-cache"

FLAGS=(
    -target "$GIFTUI_NRF_SWIFT_TARGET"
    -enable-experimental-feature Embedded
    -Osize -whole-module-optimization
    -Xcc -mfloat-abi=hard -Xcc -mcpu=cortex-m4 -Xcc -mfpu=fpv4-sp-d16
    -package-name GiftUI
    -module-cache-path "$TEMPORARY_DIRECTORY/module-cache"
)
GIFTUI_SOURCES=(
    "$PROJECT_ROOT/Sources/GiftUI/GiftUI.swift"
    "$PROJECT_ROOT/Sources/GiftUI/DeclarativeView.swift"
    "$PROJECT_ROOT/Sources/GiftUI/ObservableState.swift"
    "$PROJECT_ROOT/Sources/GiftUI/Color.swift"
    "$PROJECT_ROOT/Sources/GiftUI/BoundedText.swift"
    "$PROJECT_ROOT/Sources/GiftUI/Text.swift"
    "$PROJECT_ROOT/Sources/GiftUI/LayoutValues.swift"
    "$PROJECT_ROOT/Sources/GiftUI/LayoutContainers.swift"
    "$PROJECT_ROOT/Sources/GiftUI/LayoutModifiers.swift"
    "$PROJECT_ROOT/Sources/GiftUI/StyleModifiers.swift"
)

"$GIFTUI_NRF_SWIFTC" "${FLAGS[@]}" -parse-as-library -emit-module \
    -module-name GiftUI "${GIFTUI_SOURCES[@]}" \
    -emit-module-path "$MODULES/GiftUI.swiftmodule"
"$GIFTUI_NRF_SWIFTC" "${FLAGS[@]}" -parse-as-library -emit-module \
    -module-name GiftUISemanticCore -I "$MODULES" \
    "$PROJECT_ROOT/Sources/GiftUISemanticCore/GiftUISemanticCore.swift" \
    "$PROJECT_ROOT/Sources/GiftUISemanticCore/SemanticLayoutView.swift" \
    -emit-module-path "$MODULES/GiftUISemanticCore.swiftmodule"
"$GIFTUI_NRF_SWIFTC" "${FLAGS[@]}" -parse-as-library -emit-module \
    -module-name GiftUITextResources -I "$MODULES" \
    "$PROJECT_ROOT/Sources/GiftUITextResources/GiftUITextResources.swift" \
    -emit-module-path "$MODULES/GiftUITextResources.swiftmodule"
"$GIFTUI_NRF_SWIFTC" "${FLAGS[@]}" -parse-as-library -emit-module \
    -module-name GiftUILayout -I "$MODULES" \
    "$PROJECT_ROOT"/Sources/GiftUILayout/*.swift \
    -emit-module-path "$MODULES/GiftUILayout.swiftmodule"

PROBE_OBJECT="$TEMPORARY_DIRECTORY/SemanticBorrowProbe.swift.o"
"$GIFTUI_NRF_SWIFTC" "${FLAGS[@]}" -parse-as-library -emit-object \
    -module-name SPEC007EmbeddedSemanticProbe -I "$MODULES" \
    "$PROJECT_ROOT/Tests/ContractFixtures/SPEC007/Instrumentation/SemanticBorrowProbe.swift" \
    -o "$PROBE_OBJECT"

if [[ -n "$EVIDENCE_DIRECTORY" ]]; then
    mkdir -p "$EVIDENCE_DIRECTORY"
    PROBE_IR="$EVIDENCE_DIRECTORY/layout-resource.ll"
    "$GIFTUI_NRF_SWIFTC" "${FLAGS[@]}" -parse-as-library -emit-ir \
        -module-name SPEC007EmbeddedSemanticProbe -I "$MODULES" \
        "$PROJECT_ROOT/Tests/ContractFixtures/SPEC007/Instrumentation/SemanticBorrowProbe.swift" \
        -o "$PROBE_IR"
fi

READELF="$GIFTUI_NRF_SDK_DIR/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf"
ATTRIBUTES="$TEMPORARY_DIRECTORY/attributes.txt"
SYMBOLS="$TEMPORARY_DIRECTORY/symbols.txt"
"$READELF" -A "$PROBE_OBJECT" >"$ATTRIBUTES"
"$READELF" -Ws "$PROBE_OBJECT" >"$SYMBOLS"
grep -Fq 'Tag_CPU_arch: v7E-M' "$ATTRIBUTES"
grep -Fq 'Tag_ABI_VFP_args: VFP registers' "$ATTRIBUTES"

if grep -E 'UND.*(swift_allocObject|swift_allocBox|swift_slowAlloc)' "$SYMBOLS"; then
    printf 'SPEC-007 embedded semantic check failed: allocation symbol found\n' >&2
    exit 1
fi
if grep -Eqi 'GiftUIRender|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|Zephyr|JLink' \
    "$SYMBOLS"; then
    printf 'SPEC-007 embedded semantic check failed: prohibited dependency symbol found\n' >&2
    exit 1
fi

if [[ -n "$EVIDENCE_DIRECTORY" ]]; then
    cp "$PROBE_OBJECT" "$EVIDENCE_DIRECTORY/layout-probe.o"
    cp "$ATTRIBUTES" "$EVIDENCE_DIRECTORY/attributes.txt"
    cp "$SYMBOLS" "$EVIDENCE_DIRECTORY/symbols.txt"
    "$SCRIPT_DIR/check-spec-007-resource-ir.rb" \
        "$PROBE_IR" "$EVIDENCE_DIRECTORY/value-layouts.tsv"
fi

printf 'SPEC-007 embedded semantic passed: ARMv7E-M hard-float layout probe has zero allocation and no prohibited dependency symbols.\n'
