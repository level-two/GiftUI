#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

application="${GIFTUI_NRF_APPLICATION}"
pristine="auto"

usage() {
    cat <<'USAGE'
Usage: scripts/nrf52840/build.sh [options]

Options:
  --application NAME  Firmware application under firmware/nrf52840/applications.
  --pristine          Discard this application's generated build before building.
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
    -DUSE_CCACHE=0

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
flash_bytes=0
ram_bytes=0
while read -r virtual_address file_size memory_size; do
    flash_bytes=$((flash_bytes + 16#${file_size#0x}))
    if [[ "${virtual_address}" == 0x2* ]]; then
        ram_bytes=$((ram_bytes + 16#${memory_size#0x}))
    fi
done < <(awk '$1 == "LOAD" {print $3, $5, $6}' "${build_dir}/reports/program-headers.txt")
printf 'FLASH_BYTES=%s\nRAM_BYTES=%s\nFLASH_WARNING_BYTES=%s\nFLASH_LIMIT_BYTES=%s\nRAM_LIMIT_BYTES=%s\n' \
    "${flash_bytes}" "${ram_bytes}" "${GIFTUI_NRF_FLASH_WARNING_BYTES}" \
    "${GIFTUI_NRF_FLASH_LIMIT_BYTES}" "${GIFTUI_NRF_RAM_LIMIT_BYTES}" \
    >"${build_dir}/reports/memory-summary.txt"
((ram_bytes <= GIFTUI_NRF_RAM_LIMIT_BYTES)) || giftui_nrf_error "firmware RAM use exceeds the 192 KiB limit"
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
if [[ -f "${checks_file}" ]]; then
    while IFS='=' read -r check value; do
        [[ -n "${check}" && "${check}" != \#* ]] || continue
        [[ -n "${value}" ]] ||
            giftui_nrf_error "empty ${check} value in ${checks_file}"
        case "${check}" in
            swift-entry-symbol | required-symbol)
                grep -Fq "${value}" "${build_dir}/reports/symbols.txt" ||
                    giftui_nrf_error "${application} ELF does not contain required symbol: ${value}"
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
