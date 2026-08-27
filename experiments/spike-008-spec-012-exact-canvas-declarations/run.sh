#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${script_dir}/../.." && pwd -P)"
source "${repository_root}/scripts/nrf52840/common.sh"
giftui_nrf_export_environment

build_root="${repository_root}/.build/nrf52840"
host_build="${build_root}/spike-008-host"
evidence_dir="${script_dir}/evidence"
tool_prefix="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi"
readelf="${tool_prefix}-readelf"
size_tool="${tool_prefix}-size"
nm_tool="${tool_prefix}-nm"
objdump="${tool_prefix}-objdump"
mkdir -p "${host_build}/module-cache" "${evidence_dir}"

build_fixture() {
    local variant="$1"
    local source="$2"
    shift 2
    local build_dir="${build_root}/spike-008-${variant}"
    "${GIFTUI_NRF_WEST}" build -p always \
        -b "${GIFTUI_NRF_BOARD}" \
        -d "${build_dir}" \
        "${script_dir}" \
        -- \
        "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
        "-DCMAKE_Swift_COMPILER=${GIFTUI_NRF_SWIFTC}" \
        "-DGIFTUI_SWIFT_TARGET=${GIFTUI_NRF_SWIFT_TARGET}" \
        "-DSPIKE008_SWIFT_SOURCE=${script_dir}/${source}" \
        "-DDTC=$(giftui_nrf_dtc)" \
        -DUSE_CCACHE=0 \
        "$@"
}

expect_embedded_failure() {
    local variant="$1"
    local expected_pattern="$2"
    shift 2
    local log="${evidence_dir}/embedded-${variant}-diagnostic.txt"
    local full_log="${build_root}/spike-008-${variant}-expected-failure.log"
    set +e
    build_fixture "${variant}" Candidate.swift "$@" >"${full_log}" 2>&1
    local status=$?
    set -e
    if [[ ${status} -eq 0 ]]; then
        printf 'error: embedded %s fixture unexpectedly compiled\n' "${variant}" >&2
        exit 1
    fi
    rg -n -C 4 'error:|note:' "${full_log}" >"${log}"
    rg -q "${expected_pattern}" "${log}"
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

host_swiftc=/usr/bin/swiftc
host_candidate="${host_build}/candidate"
"${host_swiftc}" -O -module-cache-path "${host_build}/module-cache" \
    "${script_dir}/Candidate.swift" "${script_dir}/HostMain.swift" \
    -o "${host_candidate}"
"${host_candidate}" >"${evidence_dir}/macos-runtime.tsv"
rg -q $'^status\tpass$' "${evidence_dir}/macos-runtime.tsv"

expect_host_failure() {
    local name="$1"
    local expected_pattern="$2"
    shift 2
    local log="${evidence_dir}/macos-${name}-diagnostic.txt"
    set +e
    "${host_swiftc}" -emit-library \
        -module-cache-path "${host_build}/module-cache" \
        "$@" -o "${host_build}/${name}.dylib" >"${log}" 2>&1
    local status=$?
    set -e
    if [[ ${status} -eq 0 ]]; then
        printf 'error: macOS %s fixture unexpectedly compiled\n' "${name}" >&2
        exit 1
    fi
    rg -q "${expected_pattern}" "${log}"
}

expect_host_failure outer-context-access 'overlapping accesses.*context' \
    "${script_dir}/Candidate.swift" \
    "${script_dir}/IllegalOuterContextAccess.swift"
expect_host_failure path-copy 'borrowed and cannot be consumed' \
    "${script_dir}/Candidate.swift" "${script_dir}/IllegalPathCopy.swift"
expect_host_failure path-escape 'requires that.*Path.*conform to.*Copyable' \
    "${script_dir}/Candidate.swift" "${script_dir}/IllegalPathEscape.swift"

build_fixture baseline Baseline.swift
build_fixture candidate Candidate.swift
expect_embedded_failure outer-context-access 'overlapping accesses.*context' \
    "-DSPIKE008_EXTRA_SWIFT_SOURCES=${script_dir}/IllegalOuterContextAccess.swift"
expect_embedded_failure path-copy 'borrowed and cannot be consumed' \
    "-DSPIKE008_EXTRA_SWIFT_SOURCES=${script_dir}/IllegalPathCopy.swift"
expect_embedded_failure path-escape 'requires that.*Path.*conform to.*Copyable' \
    "-DSPIKE008_EXTRA_SWIFT_SOURCES=${script_dir}/IllegalPathEscape.swift"

baseline_dir="${build_root}/spike-008-baseline"
candidate_dir="${build_root}/spike-008-candidate"
baseline_elf="${baseline_dir}/zephyr/zephyr.elf"
candidate_elf="${candidate_dir}/zephyr/zephyr.elf"
report_dir="${candidate_dir}/reports/spike-008"
mkdir -p "${report_dir}"
cp "${candidate_dir}/zephyr/.config" "${report_dir}/zephyr.config"
"${readelf}" -h "${candidate_elf}" >"${evidence_dir}/elf-header.txt"
"${readelf}" -A "${candidate_elf}" >"${evidence_dir}/arm-attributes.txt"
"${size_tool}" -A "${baseline_elf}" >"${evidence_dir}/baseline-size.txt"
"${size_tool}" -A "${candidate_elf}" >"${evidence_dir}/candidate-size.txt"
"${nm_tool}" "${baseline_elf}" | awk '{ print $NF }' | sort -u >"${report_dir}/baseline-symbol-names.txt"
"${nm_tool}" "${candidate_elf}" | awk '{ print $NF }' | sort -u >"${report_dir}/candidate-symbol-names.txt"
comm -13 "${report_dir}/baseline-symbol-names.txt" "${report_dir}/candidate-symbol-names.txt" >"${evidence_dir}/candidate-introduced-symbols.txt"
"${objdump}" -d "${candidate_elf}" >"${report_dir}/candidate-disassembly.txt"
perl -pi -e 's/[ \t]+$//' "${evidence_dir}"/*.txt
perl -0pi -e 's/\n+\z/\n/' "${evidence_dir}"/*.txt

grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${report_dir}/zephyr.config"
grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${report_dir}/zephyr.config"
grep -Fq 'Machine:                           ARM' "${evidence_dir}/elf-header.txt"
grep -Fq 'Tag_CPU_arch: v7E-M' "${evidence_dir}/arm-attributes.txt"
grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${evidence_dir}/arm-attributes.txt"
if rg -i 'reflection|objc|task|thread|malloc|calloc|realloc|posix_memalign|swift_allocObject|swift_slowAlloc|swift_(allocError|deallocError|getErrorValue|willThrow|unexpectedError)|__cxa_|ErrorExistential' "${evidence_dir}/candidate-introduced-symbols.txt"; then
    printf 'error: forbidden candidate-introduced linked dependency found\n' >&2
    exit 1
fi

baseline_flash="$(linked_flash "${baseline_elf}")"
candidate_flash="$(linked_flash "${candidate_elf}")"
baseline_ram="$(linked_ram "${baseline_elf}")"
candidate_ram="$(linked_ram "${candidate_elf}")"
git_revision="$(git -C "${repository_root}" rev-parse HEAD)"
host_swift_version="$("${host_swiftc}" --version | head -1)"
embedded_swift_version="$("${GIFTUI_NRF_SWIFTC}" --version | head -1)"
candidate_hash="$(shasum -a 256 "${script_dir}/Candidate.swift" | awk '{ print $1 }')"
candidate_elf_hash="$(shasum -a 256 "${candidate_elf}" | awk '{ print $1 }')"

cat >"${evidence_dir}/summary.md" <<EOF
# SPIKE-008 generated evidence

- Revision: \`${git_revision}\`
- macOS Swift: \`${host_swift_version}\`
- Embedded Swift: \`${embedded_swift_version}\`
- Zephyr: \`${GIFTUI_NRF_ZEPHYR_VERSION}\`; SDK: \`${GIFTUI_NRF_ZEPHYR_SDK_VERSION}\`
- Board: \`${GIFTUI_NRF_BOARD}\`; Swift target: \`${GIFTUI_NRF_SWIFT_TARGET}\`
- Candidate source SHA-256: \`${candidate_hash}\`
- Candidate ELF SHA-256: \`${candidate_elf_hash}\`

## Result

The corrected SPEC-012 declarations and generated bounded callable compile and
link on macOS and Embedded Swift. The callable exercises concrete typed
\`DrawingError\` throws and the two-\`inout\` \`withPath\` source form, including
stroke-mutate-stroke reuse of one scoped Path. The macOS runtime fixture passes
both normal and throwing \`withPath\` cleanup paths.

Illegal outer-context access, borrowed-Path consumption, and \`withPath\` Path
escape fixtures fail compilation on both compilers as intended. The exact
diagnostics are retained beside this summary.

| Metric | Baseline | Declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | ${baseline_flash} | ${candidate_flash} | $((candidate_flash-baseline_flash)) |
| Linked RAM bytes | ${baseline_ram} | ${candidate_ram} | $((candidate_ram-baseline_ram)) |

The candidate ELF reports ARMv7E-M and VFP register arguments. Both configured
heaps are zero. The candidate introduces no linked \`any Error\`, reflection,
Objective-C, task, thread, exception-runtime, or allocator symbol relative to
the configuration-equivalent baseline. No board was flashed or operated.
EOF

printf 'SPIKE-008 completed with corrected exact-composition evidence\n'
printf 'Evidence: %s\n' "${evidence_dir}/summary.md"
