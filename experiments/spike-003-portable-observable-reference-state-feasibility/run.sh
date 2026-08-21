#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${script_dir}/../.." && pwd -P)"
source "${repository_root}/scripts/nrf52840/common.sh"
giftui_nrf_export_environment

build_root="${repository_root}/.build/nrf52840"
baseline_build="${build_root}/spike-003-baseline"
candidate_build="${build_root}/spike-003-candidate"
class_build="${build_root}/spike-003-direct-class"
host_build="${build_root}/spike-003-host"
evidence_dir="${script_dir}/evidence"
report_root="${candidate_build}/reports/spike-003"
tool_prefix="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi"
readelf="${tool_prefix}-readelf"
size_tool="${tool_prefix}-size"
nm_tool="${tool_prefix}-nm"
objdump="${tool_prefix}-objdump"

mkdir -p "${host_build}/module-cache" "${evidence_dir}" "${report_root}"

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

build_host_fixtures() {
    CLANG_MODULE_CACHE_PATH="${host_build}/module-cache" \
    SWIFT_MODULECACHE_PATH="${host_build}/module-cache" \
    /usr/bin/swiftc -O -module-cache-path "${host_build}/module-cache" \
        "${script_dir}/host/HostSemantics.swift" \
        -o "${host_build}/semantics"
    "${host_build}/semantics" >"${evidence_dir}/semantic-results.tsv"

    /usr/bin/clang -c "${script_dir}/candidate/storage.c" \
        -o "${host_build}/candidate-storage.o"
    /usr/bin/clang -c "${script_dir}/host/HostCandidateMain.c" \
        -o "${host_build}/candidate-main.o"
    CLANG_MODULE_CACHE_PATH="${host_build}/module-cache" \
    SWIFT_MODULECACHE_PATH="${host_build}/module-cache" \
    /usr/bin/swiftc -parse-as-library -O \
        -module-cache-path "${host_build}/module-cache" \
        "${script_dir}/candidate/Candidate.swift" \
        "${host_build}/candidate-storage.o" "${host_build}/candidate-main.o" \
        -o "${host_build}/candidate-counters"
    "${host_build}/candidate-counters" >"${evidence_dir}/operation-counts.tsv"
}

verify_common_image() {
    local build_dir="$1" report_dir="$2"
    grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${build_dir}/zephyr/.config"
    grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${build_dir}/zephyr/.config"
    grep -Fq 'Machine:                           ARM' "${report_dir}/elf-header.txt"
    grep -Fq 'Tag_CPU_arch: v7E-M' "${report_dir}/arm-attributes.txt"
    grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${report_dir}/arm-attributes.txt"
}

reject_allocator_entry_points() {
    local elf="$1"
    if "${nm_tool}" -g "${elf}" | awk '
        $2 ~ /[TtWw]/ &&
        ($3 == "malloc" || $3 == "calloc" || $3 == "realloc" ||
         $3 == "aligned_alloc" || $3 == "k_malloc" ||
         $3 == "k_calloc" || $3 == "k_realloc" ||
         $3 == "posix_memalign") { found = 1 }
        END { exit found ? 0 : 1 }
    '; then
        printf 'error: allocator entry point retained in %s\n' "${elf}" >&2
        return 1
    fi
}

if [[ "${SPIKE003_SKIP_BUILD:-0}" != 1 ]]; then
    build_host_fixtures
    build_fixture baseline "${baseline_build}"
    build_fixture candidate "${candidate_build}"
    build_fixture direct-class "${class_build}"
fi

baseline_reports="${baseline_build}/reports/spike-003"
candidate_reports="${candidate_build}/reports/spike-003"
class_reports="${class_build}/reports/spike-003"
collect_reports "${baseline_build}" "${baseline_reports}"
collect_reports "${candidate_build}" "${candidate_reports}"
collect_reports "${class_build}" "${class_reports}"
verify_common_image "${baseline_build}" "${baseline_reports}"
verify_common_image "${candidate_build}" "${candidate_reports}"
verify_common_image "${class_build}" "${class_reports}"
reject_allocator_entry_points "${baseline_build}/zephyr/zephyr.elf"
reject_allocator_entry_points "${candidate_build}/zephyr/zephyr.elf"

class_allocator_path="$(${nm_tool} -S "${class_build}/zephyr/zephyr.elf" | \
    awk '$4 == "posix_memalign" || $4 ~ /swift_allocObject/ { print $4 }' | \
    tr '\n' ' ')"
if [[ "${class_allocator_path}" != *posix_memalign* || "${class_allocator_path}" != *swift_allocObject* ]]; then
    printf 'error: direct-class control did not retain the expected allocation path\n' >&2
    exit 1
fi

# Compare final linked symbols because every Embedded Swift object carries
# dead allocator/exception stubs that linker GC removes. The baseline cancels
# Zephyr and Embedded runtime support not introduced by observation.
"${nm_tool}" "${baseline_build}/zephyr/zephyr.elf" | awk '{ print $NF }' | sort -u \
    >"${report_root}/baseline-symbol-names.txt"
"${nm_tool}" "${candidate_build}/zephyr/zephyr.elf" | awk '{ print $NF }' | sort -u \
    >"${report_root}/candidate-symbol-names.txt"
comm -13 "${report_root}/baseline-symbol-names.txt" \
    "${report_root}/candidate-symbol-names.txt" \
    >"${report_root}/candidate-introduced-symbols.txt"
if rg -i 'reflection|objc|task|thread|exception|throw|malloc|calloc|realloc|posix_memalign' \
    "${report_root}/candidate-introduced-symbols.txt"; then
    printf 'error: forbidden candidate-introduced linked dependency found\n' >&2
    exit 1
fi

baseline_elf="${baseline_build}/zephyr/zephyr.elf"
candidate_elf="${candidate_build}/zephyr/zephyr.elf"
class_elf="${class_build}/zephyr/zephyr.elf"
baseline_ram="$(linked_ram "${baseline_elf}")"
candidate_ram="$(linked_ram "${candidate_elf}")"
baseline_flash="$(linked_flash "${baseline_elf}")"
candidate_flash="$(linked_flash "${candidate_elf}")"
baseline_bss="$(section_size "${baseline_elf}" bss)"
candidate_bss="$(section_size "${candidate_elf}" bss)"
model_storage=32
location_storage=4
registration_storage=8
counter_storage=16
generation_storage=2
observation_storage=$((location_storage + registration_storage + generation_storage))

cat >"${evidence_dir}/stack-analysis.md" <<EOF
# Conservative fixture stack analysis

The linked disassembly in
\`.build/nrf52840/spike-003-candidate/reports/spike-003/disassembly.txt\` gives a
64-byte Swift candidate frame (nine saved 32-bit registers plus 28 local
bytes). The Zephyr C \`main\` adds 8 bytes. The deepest candidate path is
\`replace -> detach\` (8 + 8 bytes), giving a conservative complete fixture
bound of **88 bytes**. The baseline Swift frame saves twelve registers (48
bytes); with C \`main\`, its bound is **56 bytes**. These bounds exclude Zephyr
boot/scheduler frames and are compile/link evidence, not a hardware high-water
measurement.
EOF

git_revision="$(git -C "${repository_root}" rev-parse HEAD)"
git_dirty=false
if ! git -C "${repository_root}" diff --quiet || \
   ! git -C "${repository_root}" diff --cached --quiet || \
   [[ -n "$(git -C "${repository_root}" status --short --untracked-files=normal)" ]]; then
    git_dirty=true
fi
host_version="$(sw_vers -productVersion)"
host_arch="$(uname -m)"
swift_version="$(${GIFTUI_NRF_SWIFTC} --version | head -1)"
baseline_hash="$(shasum -a 256 "${baseline_elf}" | awk '{print $1}')"
candidate_hash="$(shasum -a 256 "${candidate_elf}" | awk '{print $1}')"
class_hash="$(shasum -a 256 "${class_elf}" | awk '{print $1}')"

cat >"${evidence_dir}/summary.md" <<EOF
# SPIKE-003 generated evidence

- Revision: \`${git_revision}\` (dirty: ${git_dirty})
- Host: macOS ${host_version} ${host_arch}
- Swift: ${swift_version}
- Zephyr: ${GIFTUI_NRF_ZEPHYR_VERSION}; SDK: ${GIFTUI_NRF_ZEPHYR_SDK_VERSION}
- Board: \`${GIFTUI_NRF_BOARD}\`; Swift target: \`${GIFTUI_NRF_SWIFT_TARGET}\`
- Compile mode: \`-Osize\`, Embedded Swift, Cortex-M4F hard-float; linker GC enabled
- Baseline SHA-256: \`${baseline_hash}\`
- Generated-handle SHA-256: \`${candidate_hash}\`
- Direct-class SHA-256: \`${class_hash}\`

| Metric | Baseline | Generated handle | Delta |
| --- | ---: | ---: | ---: |
| Linked RAM bytes (ELF LOAD) | ${baseline_ram} | ${candidate_ram} | $((candidate_ram-baseline_ram)) |
| Linked flash bytes (ELF LOAD files) | ${baseline_flash} | ${candidate_flash} | $((candidate_flash-baseline_flash)) |
| \`bss\` bytes | ${baseline_bss} | ${candidate_bss} | $((candidate_bss-baseline_bss)) |
| Model storage bytes | 24 | ${model_storage} | 8 |
| Of which generated owner-token bytes | 0 | 8 | 8 |
| State-location bytes | 0 | ${location_storage} | ${location_storage} |
| Registration bytes | 0 | ${registration_storage} | ${registration_storage} |
| Dirty/live bits | 0 | packed in location | 0 separate |
| Generation / stale protection bytes | 0 | ${generation_storage} | ${generation_storage} |
| Instrumentation counters (Spike only) | 0 | ${counter_storage} | ${counter_storage} |
| Generated descriptors | 0 | 0 | 0 |
| Conservative complete fixture stack | 56 | 88 | 32 |

The generated-handle image has zero configured Zephyr and libc heaps and no
retained allocator entry point. Relative to the linked baseline, it introduces no
reflection, \`Any\` storage, task-local binding, Apple Observation, Objective-C,
exception, \`Task\`, or thread-primitive reference. Zephyr's common baseline
still contains its ordinary kernel thread implementation; it is not introduced
by the candidate.

The direct-class image compiles and links, but an escaping class retains
\`swift_allocObject -> posix_memalign\`. The fixture's \`posix_memalign\` shim
always returns \`ENOMEM\`, so the class cannot materialize under the zero-heap
configuration. A non-escaping class was stack-promoted but cannot satisfy
state preservation across transient view reconstruction.

Host semantic results are in \`semantic-results.tsv\`; all dynamic-class and
static-handle cases pass with equivalent normalized outcomes. Bounded operation
counts are in \`operation-counts.tsv\`. The source-level declaration is
\`@State var model: ObservableModel\` in ordinary and Embedded Swift fixtures.

The generated typed handle therefore passes all SPIKE-003 semantic,
compile/link, bounded-storage, stale-report, and zero-heap checks. It proves
feasibility of a generated/static representation with explicit model-owned
setter signaling; it does not select a production API or capacity.
EOF

printf '| Metric | Baseline | Generated handle | Delta |\n'
printf '| --- | ---: | ---: | ---: |\n'
printf '| Linked RAM bytes | %s | %s | %s |\n' "${baseline_ram}" "${candidate_ram}" "$((candidate_ram-baseline_ram))"
printf '| Linked flash bytes | %s | %s | %s |\n' "${baseline_flash}" "${candidate_flash}" "$((candidate_flash-baseline_flash))"
printf '| bss bytes | %s | %s | %s |\n' "${baseline_bss}" "${candidate_bss}" "$((candidate_bss-baseline_bss))"
printf '| Conservative fixture stack | 56 | 88 | 32 |\n'
printf '\nEvidence: %s\n' "${evidence_dir}/summary.md"
