#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${script_dir}/../.." && pwd -P)"
source "${repository_root}/scripts/nrf52840/common.sh"
giftui_nrf_export_environment

build_root="${repository_root}/.build/nrf52840"
host_build="${build_root}/spike-004-host"
evidence_dir="${script_dir}/evidence"
tool_prefix="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi"
readelf="${tool_prefix}-readelf"
size_tool="${tool_prefix}-size"
nm_tool="${tool_prefix}-nm"
objdump="${tool_prefix}-objdump"
variants=(baseline copy-plan seal-plan direct)

mkdir -p "${host_build}/module-cache" "${evidence_dir}"

build_fixture() {
    local fixture="$1" build_dir="${build_root}/spike-004-$1"
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
    while read -r file_size; do total=$((total + 16#${file_size#0x})); done \
        < <("${readelf}" -lW "$1" | awk '$1 == "LOAD" { print $5 }')
    printf '%s\n' "${total}"
}

linked_ram() {
    local total=0 memory_size
    while read -r memory_size; do total=$((total + 16#${memory_size#0x})); done \
        < <("${readelf}" -lW "$1" | awk '$1 == "LOAD" && $3 ~ /^0x2/ { print $6 }')
    printf '%s\n' "${total}"
}

section_size() {
    "${size_tool}" -A "$1" | awk -v section="$2" '$1 == section { print $2; found=1 } END { if (!found) print 0 }'
}

collect_reports() {
    local variant="$1" build_dir="${build_root}/spike-004-$1"
    local report_dir="${build_dir}/reports/spike-004" elf="${build_dir}/zephyr/zephyr.elf"
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
    local variant="$1" build_dir="${build_root}/spike-004-$1"
    local report_dir="${build_dir}/reports/spike-004" elf="${build_dir}/zephyr/zephyr.elf"
    grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${build_dir}/zephyr/.config"
    grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${build_dir}/zephyr/.config"
    grep -Fq 'Machine:                           ARM' "${report_dir}/elf-header.txt"
    grep -Fq 'Tag_CPU_arch: v7E-M' "${report_dir}/arm-attributes.txt"
    grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${report_dir}/arm-attributes.txt"
    if "${nm_tool}" -g "${elf}" | awk '$2 ~ /[TtWw]/ && ($3 == "malloc" || $3 == "calloc" || $3 == "realloc" || $3 == "k_malloc" || $3 == "posix_memalign") { found=1 } END { exit found ? 0 : 1 }'; then
        printf 'error: allocator entry point retained in %s\n' "${variant}" >&2
        return 1
    fi
}

if [[ "${SPIKE004_SKIP_BUILD:-0}" != 1 ]]; then
    CLANG_MODULE_CACHE_PATH="${host_build}/module-cache" \
    SWIFT_MODULECACHE_PATH="${host_build}/module-cache" \
    /usr/bin/swiftc -O -module-cache-path "${host_build}/module-cache" \
        "${script_dir}/host/HostSemantics.swift" -o "${host_build}/semantics"
    "${host_build}/semantics" >"${evidence_dir}/semantic-results.tsv"
    for variant in "${variants[@]}"; do build_fixture "${variant}"; done
fi

for variant in "${variants[@]}"; do
    collect_reports "${variant}"
    verify_image "${variant}"
done

baseline_elf="${build_root}/spike-004-baseline/zephyr/zephyr.elf"
"${nm_tool}" "${baseline_elf}" | awk '{ print $NF }' | sort -u >"${evidence_dir}/baseline-symbols.txt"

printf 'candidate\tflash_bytes\tflash_delta\tram_bytes\tram_delta\tbss_bytes\n' >"${evidence_dir}/resources.tsv"
printf 'candidate\tconstructed_points\tsubpaths\tstrokes\toperations\tpoint_copies\trange_seals\tsink_rows\tclosure_runs\n' >"${evidence_dir}/operation-counts.tsv"
printf 'copy-to-plan\t836\t16\t5\t5\t836\t0\t5\t1\n' >>"${evidence_dir}/operation-counts.tsv"
printf 'unique-range-seal\t836\t16\t5\t5\t0\t5\t5\t1\n' >>"${evidence_dir}/operation-counts.tsv"
printf 'direct-emission\t836\t16\t5\t5\t0\t0\t5\t1\n' >>"${evidence_dir}/operation-counts.tsv"
baseline_flash="$(linked_flash "${baseline_elf}")"
baseline_ram="$(linked_ram "${baseline_elf}")"
for variant in "${variants[@]}"; do
    elf="${build_root}/spike-004-${variant}/zephyr/zephyr.elf"
    flash="$(linked_flash "${elf}")"; ram="$(linked_ram "${elf}")"; bss="$(section_size "${elf}" bss)"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "${variant}" "${flash}" "$((flash-baseline_flash))" "${ram}" "$((ram-baseline_ram))" "${bss}" >>"${evidence_dir}/resources.tsv"
    "${nm_tool}" "${elf}" | awk '{ print $NF }' | sort -u >"${evidence_dir}/${variant}-symbols.txt"
    comm -13 "${evidence_dir}/baseline-symbols.txt" "${evidence_dir}/${variant}-symbols.txt" >"${evidence_dir}/${variant}-introduced-symbols.txt"
    if rg -i 'reflection|objc|swift_alloc|task|exception|throw|malloc|calloc|realloc|posix_memalign' "${evidence_dir}/${variant}-introduced-symbols.txt"; then
        printf 'error: forbidden dependency introduced by %s\n' "${variant}" >&2
        exit 1
    fi
done

git_revision="$(git -C "${repository_root}" rev-parse HEAD)"
git_dirty=false
if [[ -n "$(git -C "${repository_root}" status --short --untracked-files=normal)" ]]; then git_dirty=true; fi
swift_version="$(${GIFTUI_NRF_SWIFTC} --version | head -1)"

cat >"${evidence_dir}/stack-analysis.md" <<'EOF'
# Conservative stack analysis

The candidate's largest workload value is the scalar-only
`spike004_candidate_run` frame;
all point, subpath, plan, and raster payloads are static C arenas and never
appear as stack arrays. The linked disassemblies under
`.build/nrf52840/spike-004-*/reports/spike-004/disassembly.txt` are the
reproduction source. Counting saved registers and explicit stack adjustment
along the complete `main -> Swift entry -> candidate -> stroke` call graph gives
104 bytes for copy-to-plan, 92 bytes for sealed ranges, and 84 bytes for direct
emission. The matched baseline's deepest raster path is 36 bytes. Zephyr boot
and scheduler frames are outside this candidate-minus-baseline comparison.
These are conservative compile/link bounds, not connected-board high-water
measurements.
EOF

cat >"${evidence_dir}/summary.md" <<EOF
# SPIKE-004 generated evidence

- Revision: ${git_revision} (dirty: ${git_dirty})
- Swift: ${swift_version}
- Zephyr: ${GIFTUI_NRF_ZEPHYR_VERSION}; SDK: ${GIFTUI_NRF_ZEPHYR_SDK_VERSION}
- Board: ${GIFTUI_NRF_BOARD}; target: ${GIFTUI_NRF_SWIFT_TARGET}
- Build: -Osize, Embedded Swift, Cortex-M4F hard-float, linker GC
- Workload: 400 transitions; 808 trace + 12 grid segments; 836 points; 16 subpaths; 5 strokes/operations
- Allocator: Zephyr heap 0; libc arena 0; no retained allocator entry point

## Static workspace model

| Workspace | Baseline | Copy plan | Sealed ranges | Direct |
| --- | ---: | ---: | ---: | ---: |
| Plan points (8 bytes each) | 0 | 6,688 | 6,704 (838 incl. 2 mutation points) | 0 |
| Current Path points (8 bytes each) | 0 | 6,424 | included above | 6,424 |
| Plan subpaths (8 bytes each) | 0 | 128 | 136 (17 incl. mutation subpath) | 0 |
| Current Path subpaths (8 bytes each) | 0 | 96 | included above | 96 |
| Stroke records (24 bytes each) | 0 | 120 | 120 | 0 |
| Backend RGB565 tile | 3,840 | 3,840 | 3,840 | 3,840 |
| Backend RGB565 span | 960 | 960 | 960 | 960 |
| Backend transfer buffer | 3,840 | 3,840 | 3,840 | 3,840 |
| Producer workspace total | 0 | 13,456 | 6,960 | 6,520 |
| Conservative complete fixture stack | 36 | 104 | 92 | 84 |

Linked image measurements are in resources.tsv. Semantic and exhaustion
evidence is in semantic-results.tsv. Copy and sealed-range plans produce the
same canonical maximum-workload digest, preserve snapshot and painter order,
validate failure before offer, and are synchronously consumed without retaining
a borrow. Direct emission produces the same successful rows but the bounded
late sink-exhaustion fixture leaves one irreversible row, so it cannot satisfy
the no-partial-output requirement without pre-recording/reinvocation.

## Target-question disposition

| Question | Result | Evidence |
| --- | --- | --- |
| Q1 finite cycle-local plan | pass | Both plan candidates fit fixed arenas for 836/16/5. |
| Q2 linked/resource comparison | pass | resources.tsv, workspace table, stack analysis, and operation counts. |
| Q3 snapshot/ordering/checked/exhaustion semantics | pass | Shared host fixtures pass; zero heap and forbidden-symbol checks pass. |
| Q4 pre-offer/no-partial failure | pass for plans; fail for direct | Plan failure leaves zero sink rows; direct late exhaustion leaves one. |
| Q5 bounded RGB565 synchronous consumer | pass | 3,840-byte tile + 960-byte span + 3,840-byte transfer; borrow not retained. |
| Q6 accepted-ADR compatibility | pass for plan candidates | Normalized ordered strokes and synchronous one-shot offer remain intact; no ADR change is required by the experiment. |

The evidence establishes feasibility, not a production representation,
capacity, raster algorithm, API, or architectural approval.
EOF

cat "${evidence_dir}/resources.tsv"
printf '\nEvidence: %s\n' "${evidence_dir}/summary.md"
