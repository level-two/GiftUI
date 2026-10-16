#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

application="${GIFTUI_NRF_APPLICATION}"
pristine="auto"
counter_build=""

usage() {
    cat <<'USAGE'
Usage: scripts/nrf52840/build.sh [options]

Options:
  --application NAME  Firmware application under firmware/nrf52840/applications.
  --pristine          Discard this application's generated build before building.
  --counter-build PATH Build verified P08 counter sources in the existing application.
  -h, --help          Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --application)
            [[ $# -ge 2 ]] || giftui_nrf_error "--application requires a value"
            application="$2"
            shift
            ;;
        --pristine) pristine="always" ;;
        --counter-build)
            [[ $# -ge 2 ]] || giftui_nrf_error "--counter-build requires a value"
            counter_build="$2"
            shift
            ;;
        -h | --help) usage; exit 0 ;;
        *) giftui_nrf_error "unknown option: $1" ;;
    esac
    shift
done

[[ "${application}" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || giftui_nrf_error "invalid application name: ${application}"
application_dir="${GIFTUI_NRF_APPLICATIONS_DIR}/${application}"
build_dir="${GIFTUI_NRF_BUILD_ROOT}/${application}"
[[ -f "${application_dir}/CMakeLists.txt" ]] ||
    giftui_nrf_error "application '${application}' is not available under firmware/nrf52840/applications"

giftui_nrf_export_environment

counter_cmake_arguments=()
ram_limit_bytes="${GIFTUI_NRF_RAM_LIMIT_BYTES}"
resource_scope="application-default"
if [[ -n "${counter_build}" ]]; then
    [[ "${application}" == "signal-analyzer-static" ]] ||
        giftui_nrf_error "counter inputs require the existing signal-analyzer-static application"
    build_dir="${GIFTUI_NRF_BUILD_ROOT}/${application}/rfc014-counter-firmware"
    counter_input_dir="${GIFTUI_NRF_BUILD_ROOT}/${application}/rfc014-counter-firmware-inputs"
    python3 "${GIFTUI_NRF_PROJECT_ROOT}/scripts/contracts/build-spec-015-counter-image.py" \
        --profile nrf52840-embedded --counter-build "${counter_build}" --output "${counter_input_dir}"
    # ADR-040 is a finite-counter exception, not a change to analyzer defaults.
    ram_limit_bytes=262144
    resource_scope="p08-counter"
    counter_cmake_arguments+=(
        "-DGIFTUI_COUNTER_SOURCE_INPUTS=${counter_input_dir}/counter-sources.cmake"
        "-DEXTRA_CONF_FILE=${application_dir}/counter.conf"
    )
fi

giftui_nrf_note "building ${application} for ${GIFTUI_NRF_BOARD}"
"${GIFTUI_NRF_WEST}" build \
    -p "${pristine}" \
    -b "${GIFTUI_NRF_BOARD}" \
    -d "${build_dir}" \
    "${application_dir}" \
    -- \
    "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
    "-DCMAKE_Swift_COMPILER=${GIFTUI_NRF_SWIFTC}" \
    "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
    "-DDTC=$(giftui_nrf_dtc)" \
    -DUSE_CCACHE=0 \
    "${counter_cmake_arguments[@]}"

elf="${build_dir}/zephyr/zephyr.elf"
hex="${build_dir}/zephyr/zephyr.hex"
map="${build_dir}/zephyr/zephyr.map"
dts="${build_dir}/zephyr/zephyr.dts"
readelf="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf"
size="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-size"

# A pristine west build removes the application build directory.
mkdir -p "${build_dir}/reports"

for artifact in "${elf}" "${hex}" "${map}" "${dts}"; do
    [[ -f "${artifact}" ]] || giftui_nrf_error "expected build artifact is missing: ${artifact}"
done

"${readelf}" -h "${elf}" >"${build_dir}/reports/elf-header.txt"
"${readelf}" -A "${elf}" >"${build_dir}/reports/arm-attributes.txt"
"${readelf}" -lW "${elf}" >"${build_dir}/reports/program-headers.txt"
"${readelf}" -S "${elf}" >"${build_dir}/reports/sections.txt"
"${readelf}" -sW "${elf}" >"${build_dir}/reports/symbols.txt"
"${size}" -A "${elf}" >"${build_dir}/reports/size.txt"
if [[ -n "${counter_build}" ]]; then
    # This only reads existing target objects/ELF/map; no target code runs.
    python3 "${GIFTUI_NRF_PROJECT_ROOT}/scripts/contracts/p08_layout_facts.py" firmware \
        --input "${elf}" --map "${map}" \
        --so07 "${counter_build}/so07-layout-facts.json" \
        --compiler-sha256 "$(shasum -a 256 "${GIFTUI_NRF_SWIFTC}" | awk '{print $1}')" \
        --output "${build_dir}/reports/so08-layout-and-c-reservation.json"
fi
flash_bytes=0
ram_bytes=0
ram_end_address=0
ram_start_address=0
while read -r virtual_address file_size memory_size; do
    flash_bytes=$((flash_bytes + 16#${file_size#0x}))
    if [[ "${virtual_address}" == 0x2* ]]; then
        ram_bytes=$((ram_bytes + 16#${memory_size#0x}))
        segment_start=$((16#${virtual_address#0x}))
        segment_end=$((segment_start + 16#${memory_size#0x}))
        if ((ram_start_address == 0 || segment_start < ram_start_address)); then
            ram_start_address="${segment_start}"
        fi
        if ((segment_end > ram_end_address)); then
            ram_end_address="${segment_end}"
        fi
    fi
done < <(awk '$1 == "LOAD" {print $3, $5, $6}' "${build_dir}/reports/program-headers.txt")
ram_extent_bytes=$((ram_end_address - ram_start_address))
main_stack_bytes="$(awk -F= '$1 == "CONFIG_MAIN_STACK_SIZE" {print $2}' "${build_dir}/zephyr/.config")"
isr_stack_bytes="$(awk -F= '$1 == "CONFIG_ISR_STACK_SIZE" {print $2}' "${build_dir}/zephyr/.config")"
printf 'FLASH_BYTES=%s\nRAM_BYTES=%s\nFLASH_WARNING_BYTES=%s\nFLASH_LIMIT_BYTES=%s\nRAM_LIMIT_BYTES=%s\nRAM_ADDRESS_EXTENT_BYTES=%s\nMAIN_STACK_SIZE_BYTES=%s\nISR_STACK_SIZE_BYTES=%s\nRESOURCE_SCOPE=%s\n' \
    "${flash_bytes}" "${ram_bytes}" "${GIFTUI_NRF_FLASH_WARNING_BYTES}" \
    "${GIFTUI_NRF_FLASH_LIMIT_BYTES}" "${ram_limit_bytes}" "${ram_extent_bytes}" \
    "${main_stack_bytes}" "${isr_stack_bytes}" "${resource_scope}" \
    >"${build_dir}/reports/memory-summary.txt"
((ram_bytes <= ram_limit_bytes)) || giftui_nrf_error "firmware RAM use exceeds the ${ram_limit_bytes}-byte ${resource_scope} limit"
if [[ -n "${counter_build}" ]]; then
    # Charge and address extent are distinct; gaps cannot hide physical overflow.
    ((ram_start_address >= 0x20000000 && ram_end_address <= 0x20040000)) ||
        giftui_nrf_error "counter RAM segments exceed physical 256 KiB SRAM"
fi
((flash_bytes <= GIFTUI_NRF_FLASH_LIMIT_BYTES)) || giftui_nrf_error "firmware does not fit in internal flash"
if ((flash_bytes > GIFTUI_NRF_FLASH_WARNING_BYTES)); then
    printf 'warning: firmware flash use exceeds the 896 KiB warning threshold\n' >&2
fi

grep -Fq 'Machine:                           ARM' "${build_dir}/reports/elf-header.txt" ||
    giftui_nrf_error "firmware is not an ARM ELF"
grep -Fq 'Tag_CPU_arch: v7E-M' "${build_dir}/reports/arm-attributes.txt" ||
    giftui_nrf_error "firmware does not declare ARMv7E-M"
grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${build_dir}/reports/arm-attributes.txt" ||
    giftui_nrf_error "firmware does not declare the hard-float calling convention"
checks_file="${application_dir}/build-checks.conf"
if [[ -n "${counter_build}" ]]; then
    checks_file="${application_dir}/counter-build-checks.conf"
fi
if [[ -f "${checks_file}" ]]; then
    while IFS='=' read -r check value; do
        [[ -n "${check}" && "${check}" != \#* ]] || continue
        [[ -n "${value}" ]] ||
            giftui_nrf_error "empty ${check} value in ${checks_file}"
        case "${check}" in
            required-config)
                config_name="${value%%:*}"
                expected_value="${value#*:}"
                [[ "${config_name}" =~ ^CONFIG_[A-Z0-9_]+$ && "${expected_value}" =~ ^[0-9]+$ ]] ||
                    giftui_nrf_error "required-config must be CONFIG_NAME:NUMBER in ${checks_file}"
                grep -Fqx "${config_name}=${expected_value}" "${build_dir}/zephyr/.config" ||
                    giftui_nrf_error "${application} requires ${config_name}=${expected_value}"
                ;;
            required-ram-limit)
                [[ "${value}" =~ ^[0-9]+$ && "${ram_limit_bytes}" == "${value}" ]] ||
                    giftui_nrf_error "${application} requires RAM limit ${value} bytes"
                ;;
            swift-entry-symbol | required-symbol)
                grep -Fq "${value}" "${build_dir}/reports/symbols.txt" ||
                    giftui_nrf_error "${application} ELF does not contain required symbol: ${value}"
                ;;
            required-symbol-size)
                symbol="${value%%:*}"
                expected_size="${value#*:}"
                [[ -n "${symbol}" && "${expected_size}" =~ ^[0-9]+$ && "${symbol}" != "${value}" ]] ||
                    giftui_nrf_error "required-symbol-size must be SYMBOL:BYTES in ${checks_file}"
                symbol_size="$({
                    awk -v symbol="${symbol}" '$8 == symbol {print $3; count += 1} END {exit count == 1 ? 0 : 1}' \
                        "${build_dir}/reports/symbols.txt"
                })" || giftui_nrf_error "${application} ELF does not contain exactly one symbol: ${symbol}"
                if [[ "${symbol_size}" == 0x* ]]; then
                    actual_size=$((16#${symbol_size#0x}))
                else
                    actual_size=$((10#${symbol_size}))
                fi
                ((actual_size == expected_size)) ||
                    giftui_nrf_error "${application} ELF symbol ${symbol} is ${actual_size} bytes, expected ${expected_size}"
                ;;
            zero-heap)
                [[ "${value}" == "true" ]] ||
                    giftui_nrf_error "zero-heap must be true in ${checks_file}"
                grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${build_dir}/zephyr/.config" ||
                    giftui_nrf_error "${application} firmware must keep the Zephyr heap disabled"
                grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${build_dir}/zephyr/.config" ||
                    giftui_nrf_error "${application} firmware must keep the C allocation arena disabled"
                if awk '
                    $4 == "FUNC" && $5 == "GLOBAL" &&
                    ($8 == "malloc" || $8 == "calloc" || $8 == "realloc" ||
                     $8 == "aligned_alloc" ||
                     $8 == "k_malloc" || $8 == "k_calloc" || $8 == "k_realloc") {
                        found = 1
                    }
                    END { exit found ? 0 : 1 }
                ' "${build_dir}/reports/symbols.txt"; then
                    giftui_nrf_error "${application} ELF contains a heap allocation entry point"
                fi
                ;;
            *) giftui_nrf_error "unknown build check '${check}' in ${checks_file}" ;;
        esac
    done <"${checks_file}"
fi

printf 'ELF=%s\n' "${elf}"
printf 'HEX=%s\n' "${hex}"
printf 'MAP=%s\n' "${map}"
printf 'DEVICETREE=%s\n' "${dts}"
printf 'REPORTS=%s\n' "${build_dir}/reports"
