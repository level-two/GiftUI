#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

layer="giftui"

usage() {
    cat <<'USAGE'
Usage: scripts/nrf52840/compile-layer.sh [options]

Options:
  --layer NAME  Compile through NAME. Supported: giftui, runtime.
  -h, --help    Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --layer)
            [[ $# -ge 2 ]] || giftui_nrf_error "--layer requires a value"
            layer="$2"
            shift
            ;;
        -h | --help) usage; exit 0 ;;
        *) giftui_nrf_error "unknown option: $1" ;;
    esac
    shift
done

[[ "${layer}" == "giftui" || "${layer}" == "runtime" ]] ||
    giftui_nrf_error "unsupported layer: ${layer}"

giftui_nrf_export_environment

output_dir="${GIFTUI_NRF_BUILD_ROOT}/layers/giftui"
mkdir -p "${output_dir}"

sources=(
    Sources/GiftUI/GiftUI.swift
    Sources/GiftUI/Geometry/Point.swift
    Sources/GiftUI/Geometry/ProposedSize.swift
    Sources/GiftUI/Geometry/Rect.swift
    Sources/GiftUI/Geometry/Size.swift
    Sources/GiftUI/Input/ActionID.swift
    Sources/GiftUI/Input/HitRegion.swift
    Sources/GiftUI/Input/InputEvent.swift
    Sources/GiftUI/Layout/LayoutArithmetic.swift
    Sources/GiftUI/Runtime/RuntimeProfile.swift
    Sources/GiftUI/View/PrimitiveView.swift
    Sources/GiftUI/View/View.swift
    Sources/GiftUI/View/ViewBuilder.swift
    Sources/GiftUI/View/ViewVisitor.swift
    Sources/GiftUI/Composition/ConditionalContent.swift
    Sources/GiftUI/Composition/EmptyView.swift
    Sources/GiftUI/Composition/OptionalContent.swift
    Sources/GiftUI/Composition/TupleView.swift
    Sources/GiftUI/Containers/HStack.swift
    Sources/GiftUI/Containers/VStack.swift
    Sources/GiftUI/PrimitiveViews/Button.swift
    Sources/GiftUI/PrimitiveViews/Text.swift
)

giftui_nrf_note "compiling GiftUI portable layer for ${GIFTUI_NRF_SWIFT_TARGET}"
"${GIFTUI_NRF_SWIFTC}" \
    -parse-as-library \
    -Osize \
    -whole-module-optimization \
    -enable-experimental-feature Embedded \
    -target "${GIFTUI_NRF_SWIFT_TARGET}" \
    -package-name GiftUI \
    -module-name GiftUI \
    -module-cache-path "${GIFTUI_NRF_CLANG_MODULE_CACHE}" \
    -emit-module \
    -emit-module-path "${output_dir}/GiftUI.swiftmodule" \
    -c \
    -o "${output_dir}/GiftUI.o" \
    "${sources[@]}"

printf 'MODULE=%s\n' "${output_dir}/GiftUI.swiftmodule"
printf 'OBJECT=%s\n' "${output_dir}/GiftUI.o"

if [[ "${layer}" == "giftui" ]]; then
    exit 0
fi

runtime_output_dir="${GIFTUI_NRF_BUILD_ROOT}/layers/runtime"
mkdir -p "${runtime_output_dir}"

giftui_nrf_note "compiling GiftUIRuntimeStatic for ${GIFTUI_NRF_SWIFT_TARGET}"
"${GIFTUI_NRF_SWIFTC}" \
    -parse-as-library \
    -Osize \
    -whole-module-optimization \
    -enable-experimental-feature Embedded \
    -target "${GIFTUI_NRF_SWIFT_TARGET}" \
    -package-name GiftUI \
    -module-name GiftUIRuntimeStatic \
    -module-cache-path "${GIFTUI_NRF_CLANG_MODULE_CACHE}" \
    -I "${output_dir}" \
    -emit-module \
    -emit-module-path "${runtime_output_dir}/GiftUIRuntimeStatic.swiftmodule" \
    -c \
    -o "${runtime_output_dir}/GiftUIRuntimeStatic.o" \
    Sources/GiftUIRuntimeStatic/GiftUIRuntimeStatic.swift \
    Sources/GiftUIRuntimeStatic/StaticRuntime.swift

printf 'MODULE=%s\n' "${runtime_output_dir}/GiftUIRuntimeStatic.swiftmodule"
printf 'OBJECT=%s\n' "${runtime_output_dir}/GiftUIRuntimeStatic.o"

fixture_output_dir="${GIFTUI_NRF_BUILD_ROOT}/layers/thermostat"
mkdir -p "${fixture_output_dir}"

giftui_nrf_note "compiling portable thermostat fixture for ${GIFTUI_NRF_SWIFT_TARGET}"
"${GIFTUI_NRF_SWIFTC}" \
    -parse-as-library \
    -Osize \
    -whole-module-optimization \
    -enable-experimental-feature Embedded \
    -target "${GIFTUI_NRF_SWIFT_TARGET}" \
    -package-name GiftUI \
    -module-name GiftUIExampleThermostatPortableView \
    -module-cache-path "${GIFTUI_NRF_CLANG_MODULE_CACHE}" \
    -I "${output_dir}" \
    -emit-module \
    -emit-module-path "${fixture_output_dir}/GiftUIExampleThermostatPortableView.swiftmodule" \
    -c \
    -o "${fixture_output_dir}/GiftUIExampleThermostatPortableView.o" \
    Sources/GiftUIExampleThermostatPortableView/ThermostatModel.swift \
    Sources/GiftUIExampleThermostatPortableView/ThermostatPortableView.swift

printf 'MODULE=%s\n' "${fixture_output_dir}/GiftUIExampleThermostatPortableView.swiftmodule"
printf 'OBJECT=%s\n' "${fixture_output_dir}/GiftUIExampleThermostatPortableView.o"
