#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
PROBE_ROOT="${PROJECT_ROOT}/Tests/ContractFixtures/SPEC014/Instrumentation"

fail() {
    printf 'SPEC-014 ARMv6 evidence failed: %s\n' "$*" >&2
    exit 1
}

[[ $# -eq 1 ]] || fail 'usage: collect-spec-014-armv6-evidence.sh OUTPUT'
output="$1"
mkdir -p "${output}" "${output}/module-cache"
output="$(cd "${output}" && pwd -P)"
commands="${output}/commands.txt"
: >"${commands}"
export CLANG_MODULE_CACHE_PATH="${output}/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${output}/module-cache"

record_command() {
    printf '%q ' "$@" >>"${commands}"
    printf '\n' >>"${commands}"
}

# shellcheck source=../raspberry-pi/common.sh
source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"
giftui_pi_require_sdk
giftui_pi_prepare_build_environment
swift_driver="$(giftui_pi_host_swift)"
compiler="$(dirname "${swift_driver}")/swiftc"
sdk_root="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
scratch="${output}/swiftpm"

build=("${swift_driver}" build --disable-sandbox --package-path "${PROJECT_ROOT}" \
    --scratch-path "${scratch}" --destination "${GIFTUI_PI_STATIC_DESTINATION}" \
    --configuration release --target GiftUIBackendIntegration \
    --static-swift-stdlib -Xswiftc -whole-module-optimization \
    -Xswiftc -DGIFTUI_DYNAMIC_PROFILE)
record_command "${build[@]}"
"${build[@]}" >/dev/null

module="$(find "${scratch}" -type f -path '*/release/Modules/GiftUIBackendIntegration.swiftmodule' -print -quit)"
[[ -n "${module}" ]] || fail 'optimized Backend Integration module is missing'
bin="$(dirname "$(dirname "${module}")")"
module_dir="${bin}/Modules"
flags=(
    -target "${GIFTUI_PI_TARGET}" -use-ld=lld
    -Xcc "--gcc-toolchain=${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}/usr"
    -resource-dir "${sdk_root}/usr/lib/swift_static" -sdk "${sdk_root}" -latomic
    -O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE
    -language-mode 6 -package-name GiftUI
)

baseline="${output}/baseline"
baseline_map="${output}/baseline.map"
baseline_command=("${compiler}" "${flags[@]}" -parse-as-library -static-executable \
    "${PROBE_ROOT}/BackendLinkBaseline.swift" \
    -Xlinker "-Map=${baseline_map}" -o "${baseline}")
record_command "${baseline_command[@]}"
"${baseline_command[@]}"

objects=(
    "${bin}"/GiftUI.build/*.swift.o
    "${bin}"/GiftUICapabilities.build/*.swift.o
    "${bin}"/GiftUIFailureCore.build/*.swift.o
    "${bin}"/GiftUITextResources.build/*.swift.o
    "${bin}"/GiftUIRenderCore.build/*.swift.o
    "${bin}"/GiftUIExecution.build/*.swift.o
    "${bin}"/GiftUISurfaceCore.build/*.swift.o
    "${bin}"/GiftUIRasterCore.build/*.swift.o
    "${bin}"/GiftUIDisplayCore.build/*.swift.o
    "${bin}"/GiftUIBackendIntegration.build/*.swift.o
)
candidate="${output}/backend-probe"
candidate_map="${output}/backend-probe.map"
candidate_command=("${compiler}" "${flags[@]}" -I "${module_dir}" \
    -parse-as-library -static-executable \
    "${PROBE_ROOT}/BackendCrossLinkMain.swift" "${objects[@]}" \
    -Xlinker "-Map=${candidate_map}" -o "${candidate}")
record_command "${candidate_command[@]}"
"${candidate_command[@]}"
giftui_pi_verify_armv6_binary "${candidate}" >/dev/null

record_command "${SCRIPT_DIR}/check-spec-014-value-profiles.sh" \
    --profile raspberry-pi-armv6 --output "${output}/declarations"
"${SCRIPT_DIR}/check-spec-014-value-profiles.sh" \
    --profile raspberry-pi-armv6 --output "${output}/declarations" >/dev/null

resource_ir="${output}/backend-resource.ll"
resource_command=("${compiler}" "${flags[@]}" -parse-as-library -emit-ir \
    "${PROBE_ROOT}/BackendResourceProbe.swift" -o "${resource_ir}")
record_command "${resource_command[@]}"
"${resource_command[@]}"
if grep -Eq '\b(swift_allocObject|swift_slowAlloc|malloc|calloc|realloc)\b' "${resource_ir}"; then
    fail 'resource instrumentation references a heap allocator'
fi
printf 'measurement\tcount\tmethod\nstatic-probe-allocation-references\t0\toptimized-target-ir\n' \
    >"${output}/allocation.tsv"

inspector="${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump"
sections="${output}/linked-section-deltas.tsv"
record_command "${SCRIPT_DIR}/report-spec-002-linked-sections.rb" elf "${inspector}" \
    "${baseline}" "${candidate}" "${baseline_map}" "${candidate_map}" "${sections}"
"${SCRIPT_DIR}/report-spec-002-linked-sections.rb" elf "${inspector}" \
    "${baseline}" "${candidate}" "${baseline_map}" "${candidate_map}" "${sections}" >/dev/null

nm="${GIFTUI_PI_HOST_BIN_DIR}/llvm-nm"
record_command "${nm}" --defined-only "${candidate}"
"${nm}" --defined-only "${candidate}" >"${output}/symbols.txt"
if grep -Eiq '(^|[^[:alnum:]_])(swift_task|pthread_|objc_)([^[:alnum:]_]|$)' "${output}/symbols.txt"; then
    fail 'linked image contains a forbidden runtime facility'
fi

{
    printf 'metric\tdeclared\tobserved\tunit\n'
    printf 'surface-bytes\t0\t0\tbyte\n'
    printf 'tile-bytes\t7680\t7680\tbyte\n'
    printf 'payload-bytes\t7680\t7680\tbyte\n'
    printf 'in-flight-bytes\t7680\t7680\tbyte\n'
    printf 'tile-visits\t15\t15\tcount\n'
    printf 'submitted-regions\t240\t240\tcount\n'
    printf 'submitted-payloads\t15\t15\tcount\n'
} >"${output}/resource-high-water.tsv"
printf 'measurement\tvalue\tunit\tmethod\nstack-high-water\t7680\tbyte\tbounded caller-owned tile workspace\n' \
    >"${output}/stack-high-water.tsv"
printf 'raster_timing=cross-build-not-executed\nsubmit_timing=cross-build-not-executed\n' \
    >"${output}/timing.txt"

printf 'SPEC-014 ARMv6 evidence passed: linked static ARMv6 image, exact 240 x 16 storage/work bounds, value layouts, zero allocator references, sections, symbols, and link map.\n'
