#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${script_dir}/../.." && pwd -P)"
source "${repository_root}/scripts/nrf52840/common.sh"
giftui_nrf_export_environment

build_root="${repository_root}/.build/nrf52840"
baseline_build="${build_root}/spike-006-baseline"
candidate_build="${build_root}/spike-006-candidate"
evidence_dir="${script_dir}/evidence"
report_dir="${candidate_build}/reports/spike-006"
baseline_source="${script_dir}/Baseline.swift"
candidate_source="${script_dir}/Candidate.swift"
tool_prefix="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi"
readelf="${tool_prefix}-readelf"
size_tool="${tool_prefix}-size"
nm_tool="${tool_prefix}-nm"
objdump="${tool_prefix}-objdump"

mkdir -p "${evidence_dir}"

build_fixture() {
    local source="$1" build_dir="$2"
    "${GIFTUI_NRF_WEST}" build -p always \
        -b "${GIFTUI_NRF_BOARD}" \
        -d "${build_dir}" \
        "${script_dir}" \
        -- \
        "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
        "-DCMAKE_Swift_COMPILER=${GIFTUI_NRF_SWIFTC}" \
        "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
        "-DSPIKE006_SWIFT_SOURCE=${source}" \
        "-DDTC=$(giftui_nrf_dtc)" \
        -DUSE_CCACHE=0
}

linked_flash() {
    local total=0 file_size
    while read -r file_size; do
        total=$((total + 16#${file_size#0x}))
    done < <("${readelf}" -lW "$1" | awk '$1 == "LOAD" { print $5 }')
    printf '%s\n' "${total}"
}

linked_ram() {
    local total=0 memory_size
    while read -r memory_size; do
        total=$((total + 16#${memory_size#0x}))
    done < <("${readelf}" -lW "$1" | awk '$1 == "LOAD" && $3 ~ /^0x2/ { print $6 }')
    printf '%s\n' "${total}"
}

build_fixture "${baseline_source}" "${baseline_build}"
build_fixture "${candidate_source}" "${candidate_build}"
mkdir -p "${report_dir}"

baseline_elf="${baseline_build}/zephyr/zephyr.elf"
candidate_elf="${candidate_build}/zephyr/zephyr.elf"

grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${candidate_build}/zephyr/.config"
grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${candidate_build}/zephyr/.config"
"${readelf}" -A "${candidate_elf}" >"${evidence_dir}/arm-attributes.txt"
grep -Fq 'Tag_CPU_arch: v7E-M' "${evidence_dir}/arm-attributes.txt"
grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${evidence_dir}/arm-attributes.txt"

"${nm_tool}" "${baseline_elf}" | awk '{ print $NF }' | sort -u \
    >"${report_dir}/baseline-symbol-names.txt"
"${nm_tool}" "${candidate_elf}" | awk '{ print $NF }' | sort -u \
    >"${report_dir}/candidate-symbol-names.txt"
comm -13 "${report_dir}/baseline-symbol-names.txt" \
    "${report_dir}/candidate-symbol-names.txt" \
    >"${evidence_dir}/candidate-introduced-symbols.txt"

if rg -i 'reflection|objc|task|thread|malloc|calloc|realloc|posix_memalign|swift_allocObject' \
    "${evidence_dir}/candidate-introduced-symbols.txt"; then
    printf 'error: forbidden candidate-introduced linked dependency found\n' >&2
    exit 1
fi

if "${nm_tool}" -g "${candidate_elf}" | awk '
    $2 ~ /[TtWw]/ &&
    ($3 == "malloc" || $3 == "calloc" || $3 == "realloc" ||
     $3 == "aligned_alloc" || $3 == "posix_memalign" ||
     $3 == "swift_allocObject") { found = 1 }
    END { exit found ? 0 : 1 }
'; then
    printf 'error: allocator entry point retained in candidate ELF\n' >&2
    exit 1
fi

"${size_tool}" -A "${baseline_elf}" | sed '/^$/d' \
    >"${evidence_dir}/baseline-size.txt"
"${size_tool}" -A "${candidate_elf}" | sed '/^$/d' \
    >"${evidence_dir}/candidate-size.txt"
"${objdump}" -d "${candidate_elf}" >"${report_dir}/candidate-disassembly.txt"

baseline_ram="$(linked_ram "${baseline_elf}")"
candidate_ram="$(linked_ram "${candidate_elf}")"
baseline_flash="$(linked_flash "${baseline_elf}")"
candidate_flash="$(linked_flash "${candidate_elf}")"
baseline_hash="$(shasum -a 256 "${baseline_elf}" | awk '{ print $1 }')"
candidate_hash="$(shasum -a 256 "${candidate_elf}" | awk '{ print $1 }')"
source_hash="$(shasum -a 256 "${candidate_source}" | awk '{ print $1 }')"
git_revision="$(git -C "${repository_root}" rev-parse HEAD)"
swift_version="$(${GIFTUI_NRF_SWIFTC} --version | head -1)"

cat >"${evidence_dir}/summary.md" <<EOF
# SPIKE-006 generated evidence

- Revision: \`${git_revision}\`
- Swift: \`${swift_version}\`
- Zephyr: \`${GIFTUI_NRF_ZEPHYR_VERSION}\`; SDK: \`${GIFTUI_NRF_ZEPHYR_SDK_VERSION}\`
- Board: \`${GIFTUI_NRF_BOARD}\`; Swift target: \`${GIFTUI_NRF_SWIFT_TARGET}\`
- Compile mode: \`-Osize\`, Embedded Swift, Cortex-M4F hard-float
- Candidate source SHA-256: \`${source_hash}\`
- Baseline ELF SHA-256: \`${baseline_hash}\`
- Candidate ELF SHA-256: \`${candidate_hash}\`

| Metric | Baseline | SPEC-010 declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | ${baseline_flash} | ${candidate_flash} | $((candidate_flash-baseline_flash)) |
| Linked RAM bytes | ${baseline_ram} | ${candidate_ram} | $((candidate_ram-baseline_ram)) |

The exact SPEC-010 public declaration spellings for \`State\`,
\`_GiftUIObservableChangeSink\`, \`_GiftUIObservableReference\`, and
\`_GiftUIObservationAttachment\` compile and link in one Embedded Swift image.
The fixture instantiates \`@State var model: ObservableModel\`, conforms a
bounded typed handle to the consuming-sink protocol, transfers and reports
through the noncopyable sink, and detaches the returned attachment.

The candidate ELF reports ARMv7E-M and VFP register arguments. Both configured
heaps are zero. The candidate retains no allocator entry point and introduces
no linked reflection, Objective-C, task, thread, or allocator symbol relative
to the configuration-equivalent baseline. The fixture was not flashed or run
on connected hardware.
EOF

printf 'SPIKE-006 passed\n'
printf 'Evidence: %s\n' "${evidence_dir}/summary.md"
