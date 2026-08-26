#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${script_dir}/../.." && pwd -P)"
source "${repository_root}/scripts/nrf52840/common.sh"
giftui_nrf_export_environment

build_root="${repository_root}/.build/nrf52840"
evidence_dir="${script_dir}/evidence"
host_build="${build_root}/spike-007-host"
tool_prefix="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi"
readelf="${tool_prefix}-readelf"
size_tool="${tool_prefix}-size"
nm_tool="${tool_prefix}-nm"
objdump="${tool_prefix}-objdump"
mkdir -p "${evidence_dir}" "${host_build}/module-cache"

build_variant() {
    local variant="$1"
    local source="$2"
    local build_dir="${build_root}/spike-007-${variant}"
    "${GIFTUI_NRF_WEST}" build -p always \
        -b "${GIFTUI_NRF_BOARD}" \
        -d "${build_dir}" \
        "${script_dir}" \
        -- \
        "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
        "-DCMAKE_Swift_COMPILER=${GIFTUI_NRF_SWIFTC}" \
        "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
        "-DSPIKE007_SWIFT_SOURCE=${script_dir}/${source}" \
        "-DDTC=$(giftui_nrf_dtc)" \
        -DUSE_CCACHE=0
}

linked_flash() {
    local total=0 file_size
    while read -r file_size; do total=$((total + 16#${file_size#0x})); done < <("${readelf}" -lW "$1" | awk '$1 == "LOAD" { print $5 }')
    printf '%s\n' "${total}"
}

linked_ram() {
    local total=0 memory_size
    while read -r memory_size; do total=$((total + 16#${memory_size#0x})); done < <("${readelf}" -lW "$1" | awk '$1 == "LOAD" && $3 ~ /^0x2/ { print $6 }')
    printf '%s\n' "${total}"
}

collect_reports() {
    local variant="$1"
    local build_dir="${build_root}/spike-007-${variant}"
    local report_dir="${build_dir}/reports/spike-007"
    local elf="${build_dir}/zephyr/zephyr.elf"
    mkdir -p "${report_dir}"
    "${readelf}" -h "${elf}" >"${report_dir}/elf-header.txt"
    "${readelf}" -A "${elf}" >"${report_dir}/arm-attributes.txt"
    "${readelf}" -lW "${elf}" >"${report_dir}/program-headers.txt"
    "${size_tool}" -A "${elf}" >"${report_dir}/size.txt"
    "${nm_tool}" -S --size-sort "${elf}" >"${report_dir}/symbols-sized.txt"
    "${objdump}" -d "${elf}" >"${report_dir}/disassembly.txt"
    cp "${build_dir}/zephyr/.config" "${report_dir}/zephyr.config"
}

verify_image() {
    local variant="$1"
    local build_dir="${build_root}/spike-007-${variant}"
    local report_dir="${build_dir}/reports/spike-007"
    grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${report_dir}/zephyr.config"
    grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${report_dir}/zephyr.config"
    grep -Fq 'Machine:                           ARM' "${report_dir}/elf-header.txt"
    grep -Fq 'Tag_CPU_arch: v7E-M' "${report_dir}/arm-attributes.txt"
    grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${report_dir}/arm-attributes.txt"
    "${nm_tool}" "${build_dir}/zephyr/zephyr.elf" | awk '{ print $NF }' | sort -u >"${report_dir}/symbol-names.txt"
}

/usr/bin/swiftc -O -module-cache-path "${host_build}/module-cache" "${script_dir}/HostSemantics.swift" -o "${host_build}/semantics"
"${host_build}/semantics" >"${evidence_dir}/semantic-results.tsv"

if [[ "${SPIKE007_SKIP_BUILD:-0}" != 1 ]]; then
    build_variant baseline Baseline.swift
    build_variant direct DirectClosure.swift
    build_variant tagged Tagged.swift
fi

for variant in baseline direct tagged; do
    collect_reports "${variant}"
    verify_image "${variant}"
done

baseline_symbols="${build_root}/spike-007-baseline/reports/spike-007/symbol-names.txt"
direct_symbols="${build_root}/spike-007-direct/reports/spike-007/symbol-names.txt"
tagged_symbols="${build_root}/spike-007-tagged/reports/spike-007/symbol-names.txt"
direct_introduced="${evidence_dir}/direct-introduced-symbols.txt"
tagged_introduced="${evidence_dir}/tagged-introduced-symbols.txt"
comm -13 "${baseline_symbols}" "${direct_symbols}" >"${direct_introduced}"
comm -13 "${baseline_symbols}" "${tagged_symbols}" >"${tagged_introduced}"

if rg -q '\tfail\t' "${evidence_dir}/semantic-results.tsv"; then
    printf 'error: semantic fixture failed\n' >&2
    exit 1
fi
rg -q 'posix_memalign' "${direct_introduced}"
rg -q 'swift_allocObject' "${direct_introduced}"
if rg -i 'malloc|calloc|realloc|posix_memalign|swift_allocObject|swift_slowAlloc|reflection|objc|task|thread|exception|throw' "${tagged_introduced}"; then
    printf 'error: tagged candidate introduced a forbidden linked dependency\n' >&2
    exit 1
fi

section_size() {
    local elf="$1" section="$2"
    "${size_tool}" -A "${elf}" | awk -v section="${section}" '$1 == section { print $2; found=1 } END { if (!found) print 0 }'
}

baseline_elf="${build_root}/spike-007-baseline/zephyr/zephyr.elf"
baseline_fixed=$(( $(section_size "${baseline_elf}" datas) + $(section_size "${baseline_elf}" bss) ))
printf 'variant\tflash_bytes\tram_bytes\tdatas_bytes\tbss_bytes\tfixed_delta\tallocator_symbols\tforbidden_introduced\n' >"${evidence_dir}/resources.tsv"
for variant in baseline direct tagged; do
    elf="${build_root}/spike-007-${variant}/zephyr/zephyr.elf"
    flash="$(linked_flash "${elf}")"
    ram="$(linked_ram "${elf}")"
    datas="$(section_size "${elf}" datas)"
    bss="$(section_size "${elf}" bss)"
    fixed_delta=$((datas + bss - baseline_fixed))
    allocator="$(${nm_tool} "${elf}" | awk '$NF ~ /^(malloc|calloc|realloc|aligned_alloc|posix_memalign|swift_allocObject|swift_slowAlloc|k_malloc|k_calloc|k_realloc)$/ { print $NF }' | sort -u | tr '\n' ',' | sed 's/,$//')"
    introduced_file="${evidence_dir}/${variant}-introduced-symbols.txt"
    forbidden=""
    if [[ -f "${introduced_file}" ]]; then
        forbidden="$(rg -i 'reflection|objc|task|thread|exception|throw' "${introduced_file}" || true)"
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "${variant}" "${flash}" "${ram}" "${datas}" "${bss}" "${fixed_delta}" "${allocator:-none}" "${forbidden:-none}" >>"${evidence_dir}/resources.tsv"
done

cat >"${evidence_dir}/stack-analysis.md" <<'EOF'
# Conservative fixture stack analysis

The linked disassemblies give these complete fixture bounds, including the
8-byte C `main` frame:

- baseline: **8 bytes**; the Swift entry is a tail call and creates no frame;
- direct stored closure: **80 bytes** on the deepest
  `Swift entry (32) -> install (24) -> allocation wrapper (16)` path; and
- generated tagged callable: **56 bytes** on the deepest
  `Swift entry (32) -> install (16)` path.

The bounds exclude Zephyr boot and scheduler frames and are hardware-free
call-graph evidence, not connected-board stack high-water measurements.
EOF

git_revision="$(git -C "${repository_root}" rev-parse HEAD)"
swift_version="$(${GIFTUI_NRF_SWIFTC} --version | head -1)"
{
    printf '# SPIKE-007 generated evidence\n\n'
    printf -- '- Revision: `%s`\n' "${git_revision}"
    printf -- '- Swift: `%s`\n' "${swift_version}"
    printf -- '- Zephyr: `%s`; SDK: `%s`\n' "${GIFTUI_NRF_ZEPHYR_VERSION}" "${GIFTUI_NRF_ZEPHYR_SDK_VERSION}"
    printf -- '- Board: `%s`; Swift target: `%s`\n' "${GIFTUI_NRF_BOARD}" "${GIFTUI_NRF_SWIFT_TARGET}"
    printf -- '- Compile mode: `-Osize`, Embedded Swift, Cortex-M4F hard-float\n\n'
    printf '## Semantic results\n\n```text\n'
    cat "${evidence_dir}/semantic-results.tsv"
    printf '```\n\n## Resources and linked dependencies\n\n```text\n'
    cat "${evidence_dir}/resources.tsv"
    printf '```\n\n## Stack\n\n'
    cat "${evidence_dir}/stack-analysis.md"
} >"${evidence_dir}/summary.md"

cat "${evidence_dir}/summary.md"
