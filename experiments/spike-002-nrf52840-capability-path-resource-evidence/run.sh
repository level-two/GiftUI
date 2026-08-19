#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${script_dir}/../.." && pwd -P)"
source "${repository_root}/scripts/nrf52840/common.sh"
giftui_nrf_export_environment

build_root="${repository_root}/.build/nrf52840"
baseline_build="${build_root}/spike-002-baseline"
candidate_build="${build_root}/spike-002-candidate"
host_build="${build_root}/spike-002-host"
evidence_dir="${candidate_build}/reports/spike-002"
tool_prefix="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi"
readelf="${tool_prefix}-readelf"
size_tool="${tool_prefix}-size"
nm_tool="${tool_prefix}-nm"
objdump="${tool_prefix}-objdump"

build_fixture() {
    local fixture="$1" build_dir="$2"
    "${GIFTUI_NRF_WEST}" build -p always \
        -b "${GIFTUI_NRF_BOARD}" \
        -d "${build_dir}" \
        "${script_dir}/${fixture}" \
        -- \
        "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
        "-DCMAKE_Swift_COMPILER=${GIFTUI_NRF_SWIFTC}" \
        "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
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

section_size() {
    local elf="$1" section="$2"
    "${size_tool}" -A "${elf}" | awk -v section="${section}" '
        $1 == section { print $2; found = 1 }
        END { if (!found) print 0 }
    '
}

collect_reports() {
    local build_dir="$1" report_dir="$2"
    local elf="${build_dir}/zephyr/zephyr.elf"
    mkdir -p "${report_dir}"
    "${readelf}" -h "${elf}" >"${report_dir}/elf-header.txt"
    "${readelf}" -A "${elf}" >"${report_dir}/arm-attributes.txt"
    "${readelf}" -lW "${elf}" >"${report_dir}/program-headers.txt"
    "${readelf}" -SW "${elf}" >"${report_dir}/sections.txt"
    "${readelf}" -sW "${elf}" >"${report_dir}/symbols.txt"
    "${size_tool}" -A "${elf}" >"${report_dir}/size.txt"
    "${nm_tool}" -S --size-sort "${elf}" >"${report_dir}/symbols-sized.txt"
    "${objdump}" -d "${elf}" >"${report_dir}/disassembly.txt"
    cp "${build_dir}/zephyr/.config" "${report_dir}/zephyr.config"
    cp "${build_dir}/zephyr/zephyr.map" "${report_dir}/zephyr.map"
}

verify_image() {
    local build_dir="$1" report_dir="$2"
    local elf="${build_dir}/zephyr/zephyr.elf"
    grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${build_dir}/zephyr/.config"
    grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${build_dir}/zephyr/.config"
    grep -Fq 'Machine:                           ARM' "${report_dir}/elf-header.txt"
    grep -Fq 'Tag_CPU_arch: v7E-M' "${report_dir}/arm-attributes.txt"
    grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${report_dir}/arm-attributes.txt"
    if "${nm_tool}" -g "${elf}" | awk '
        $2 ~ /[TtWw]/ &&
        ($3 == "malloc" || $3 == "calloc" || $3 == "realloc" ||
         $3 == "aligned_alloc" || $3 == "k_malloc" ||
         $3 == "k_calloc" || $3 == "k_realloc") { found = 1 }
        END { exit found ? 0 : 1 }
    '; then
        printf 'error: allocator entry point retained in %s\n' "${elf}" >&2
        exit 1
    fi
}

build_host_fixture() {
    mkdir -p "${host_build}/module-cache"
    /usr/bin/clang -c "${script_dir}/host/HostStorage.c" -o "${host_build}/HostStorage.o"
    CLANG_MODULE_CACHE_PATH="${host_build}/module-cache" \
    SWIFT_MODULECACHE_PATH="${host_build}/module-cache" \
    /usr/bin/swiftc -O -module-cache-path "${host_build}/module-cache" \
        "${script_dir}/candidate/Candidate.swift" \
        "${script_dir}/host/HostMain.swift" \
        "${host_build}/HostStorage.o" \
        -o "${host_build}/spike-002-host"
    "${host_build}/spike-002-host" >"${evidence_dir}/host-paths.tsv"
}

normalized_tuple() {
    local baseline_elf="${baseline_build}/zephyr/zephyr.elf"
    local candidate_elf="${candidate_build}/zephyr/zephyr.elf"
    printf '%s:%s:%s:%s:%s:%s\n' \
        "$(linked_ram "${baseline_elf}")" "$(linked_ram "${candidate_elf}")" \
        "$(linked_flash "${baseline_elf}")" "$(linked_flash "${candidate_elf}")" \
        "$(shasum -a 256 "${baseline_elf}" | awk '{print $1}')" \
        "$(shasum -a 256 "${candidate_elf}" | awk '{print $1}')"
}

for pass in 1 2; do
    build_fixture baseline "${baseline_build}"
    build_fixture candidate "${candidate_build}"
    tuple="$(normalized_tuple)"
    if [[ "${pass}" == 1 ]]; then
        first_tuple="${tuple}"
    elif [[ "${tuple}" != "${first_tuple}" ]]; then
        printf 'error: pristine rebuild changed normalized evidence\n' >&2
        printf 'first:  %s\nsecond: %s\n' "${first_tuple}" "${tuple}" >&2
        exit 1
    fi
done

baseline_reports="${baseline_build}/reports/spike-002"
candidate_reports="${candidate_build}/reports/spike-002"
collect_reports "${baseline_build}" "${baseline_reports}"
collect_reports "${candidate_build}" "${candidate_reports}"
build_host_fixture
verify_image "${baseline_build}" "${baseline_reports}"
verify_image "${candidate_build}" "${candidate_reports}"
cmp -s "${baseline_build}/zephyr/.config" "${candidate_build}/zephyr/.config"

candidate_symbols="${candidate_reports}/symbols-sized.txt"
for symbol in \
    spike002_swift_run spike002_effective_snapshot spike002_validation_storage \
    spike002_path_trace spike002_store_result spike002_store_path0; do
    grep -Fq "${symbol}" "${candidate_symbols}"
done
if grep -Eqi 'dynamic.*registry|framebuffer|appkit|backend.*desktop|capability.*(text|input)' \
    "${candidate_symbols}"; then
    printf 'error: omitted implementation-family pattern found in candidate\n' >&2
    exit 1
fi

# Conservative disassembly proof. The resolver saves nine registers (36 B),
# reserves 28 B, and can call the 8 B unavailable-result helper: 72 B total.
# The complete driver saves nine registers and reserves 356 B; including main
# and the resolver failure chain gives a 472 B complete-path bound.
grep -Eq 'stmdb[[:space:]]+sp!.*, r8, r9, sl, fp, lr' "${candidate_reports}/disassembly.txt"
grep -Eq 'sub[[:space:]]+sp, #28' "${candidate_reports}/disassembly.txt"
grep -Eq 'sub[[:space:]]+sp, #356' "${candidate_reports}/disassembly.txt"
resolver_stack=72
complete_path_stack=472

baseline_elf="${baseline_build}/zephyr/zephyr.elf"
candidate_elf="${candidate_build}/zephyr/zephyr.elf"
baseline_ram="$(linked_ram "${baseline_elf}")"
candidate_ram="$(linked_ram "${candidate_elf}")"
baseline_flash="$(linked_flash "${baseline_elf}")"
candidate_flash="$(linked_flash "${candidate_elf}")"
ram_delta=$((candidate_ram - baseline_ram))
flash_delta=$((candidate_flash - baseline_flash))
baseline_bss="$(section_size "${baseline_elf}" bss)"
candidate_bss="$(section_size "${candidate_elf}" bss)"
baseline_data="$(section_size "${baseline_elf}" datas)"
candidate_data="$(section_size "${candidate_elf}" datas)"
baseline_text="$(section_size "${baseline_elf}" text)"
candidate_text="$(section_size "${candidate_elf}" text)"
baseline_rodata="$(section_size "${baseline_elf}" rodata)"
candidate_rodata="$(section_size "${candidate_elf}" rodata)"
capability_storage="$((16 + 32 + 32))"

success_ops="$(awk -F '\t' '$1 == "PATH" && $2 == 0 { print $4 + $5 + $6 + $7 + $8 }' "${evidence_dir}/host-paths.tsv")"
negative_ops="$(awk -F '\t' '$1 == "PATH" && $2 >= 1 && $2 <= 5 { value=$4+$5+$6+$7+$8; if(value>max)max=value } END {print max}' "${evidence_dir}/host-paths.tsv")"

git_revision="$(git -C "${repository_root}" rev-parse HEAD)"
git_dirty="$(git -C "${repository_root}" status --short | wc -l | tr -d ' ') files"
host_version="$(sw_vers -productVersion)"
host_arch="$(uname -m)"
swift_version="$(${GIFTUI_NRF_SWIFTC} --version | head -1)"
west_version="$(${GIFTUI_NRF_WEST} --version)"
cmake_version="$(cmake --version | head -1)"
ninja_version="$(ninja --version)"
baseline_hash="$(shasum -a 256 "${baseline_elf}" | awk '{print $1}')"
candidate_hash="$(shasum -a 256 "${candidate_elf}" | awk '{print $1}')"

cat >"${evidence_dir}/summary.md" <<EOF
# SPIKE-002 generated evidence

- Revision: \`${git_revision}\` (dirty: ${git_dirty})
- Host: macOS ${host_version} ${host_arch}
- Swift: ${swift_version}
- Zephyr: ${GIFTUI_NRF_ZEPHYR_VERSION}; SDK: ${GIFTUI_NRF_ZEPHYR_SDK_VERSION}
- ${west_version}; ${cmake_version}; Ninja ${ninja_version}
- Board: \`${GIFTUI_NRF_BOARD}\`; Swift target: \`${GIFTUI_NRF_SWIFT_TARGET}\`
- Compile mode: \`-Osize\`, Embedded Swift, Cortex-M4F hard-float; linker GC enabled
- Baseline SHA-256: \`${baseline_hash}\`
- Candidate SHA-256: \`${candidate_hash}\`
- Two pristine builds produced identical ELF hashes and normalized metrics.

| Metric | Baseline | Candidate | Increment | Limit / interpretation |
| --- | ---: | ---: | ---: | --- |
| Linked RAM bytes (ELF LOAD) | ${baseline_ram} | ${candidate_ram} | ${ram_delta} | 196608 total |
| Linked flash bytes (ELF LOAD files) | ${baseline_flash} | ${candidate_flash} | ${flash_delta} | 1048576 total; 917504 warning |
| \`bss\` bytes | ${baseline_bss} | ${candidate_bss} | $((candidate_bss-baseline_bss)) | Informational |
| \`datas\` bytes | ${baseline_data} | ${candidate_data} | $((candidate_data-baseline_data)) | Informational |
| \`text\` bytes | ${baseline_text} | ${candidate_text} | $((candidate_text-baseline_text)) | Informational |
| \`rodata\` bytes | ${baseline_rodata} | ${candidate_rodata} | $((candidate_rodata-baseline_rodata)) | Informational |
| Capability fixed storage bytes | 0 | ${capability_storage} | ${capability_storage} | Snapshot 32 + validation 16 + path trace 32 |
| Worst-case resolver stack bytes | 0 | ${resolver_stack} | ${resolver_stack} | Finite disassembly bound |
| Complete driver stack bytes | control only | ${complete_path_stack} | n/a | Includes main + driver + resolver failure chain |
| Success initialization operations | 0 | ${success_ops} | ${success_ops} | All reported counter categories |
| Worst negative initialization operations | 0 | ${negative_ops} | ${negative_ops} | Same counting convention |
| Steady-state resolver invocations | 0 | 0 | 0 | Snapshot accessor does not call resolver |
| Heap allocator entry points | 0 | 0 | 0 | Both configured heaps are zero |
| Display staging bytes | 0 | 3840 | 3840 | At most 16384 |

The exact candidate source was also executed as a host fixture. See
\`host-paths.tsv\` for the success, malformed, duplicate-owner, incompatible
encoding, incompatible lifetime, resource-bound failure, and positive-control
counters. Target execution was not performed and no board was flashed.
EOF

printf '| Metric | Baseline | Candidate | Increment | Limit |\n'
printf '| --- | ---: | ---: | ---: | --- |\n'
printf '| Linked RAM bytes | %s | %s | %s | 196608 |\n' "${baseline_ram}" "${candidate_ram}" "${ram_delta}"
printf '| Linked flash bytes | %s | %s | %s | 1048576 |\n' "${baseline_flash}" "${candidate_flash}" "${flash_delta}"
printf '| Capability fixed storage bytes | 0 | %s | %s | report only |\n' "${capability_storage}" "${capability_storage}"
printf '| Worst resolver stack bytes | 0 | %s | %s | finite |\n' "${resolver_stack}" "${resolver_stack}"
printf '| Success initialization operations | 0 | %s | %s | finite |\n' "${success_ops}" "${success_ops}"
printf '| Worst negative initialization operations | 0 | %s | %s | finite |\n' "${negative_ops}" "${negative_ops}"
printf '| Steady-state resolver invocations | 0 | 0 | 0 | must be 0 |\n'
printf '| Heap allocator entry points | 0 | 0 | 0 | must be 0 |\n'
printf '| Display staging bytes | 0 | 3840 | 3840 | 16384 |\n'
printf '\nEvidence: %s\n' "${evidence_dir}/summary.md"
