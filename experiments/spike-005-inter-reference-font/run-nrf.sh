#!/usr/bin/env bash
set -euo pipefail

experiment_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${experiment_dir}/../.." && pwd -P)"
source "${repository_root}/scripts/nrf52840/common.sh"
giftui_nrf_export_environment

build_root="${repository_root}/.build/nrf52840"
baseline_build="${build_root}/spike-005-font-baseline"
candidate_build="${build_root}/spike-005-font-candidate"
evidence_dir="${experiment_dir}/evidence/nrf52840"
tool_prefix="${GIFTUI_NRF_SDK_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi"
readelf="${tool_prefix}-readelf"
size_tool="${tool_prefix}-size"
nm_tool="${tool_prefix}-nm"

build_fixture() {
    local fixture="$1" build_dir="$2"
    "${GIFTUI_NRF_WEST}" build -p always \
        -b "${GIFTUI_NRF_BOARD}" \
        -d "${build_dir}" \
        "${experiment_dir}/nrf/${fixture}" \
        -- \
        "-DCMAKE_MAKE_PROGRAM=$(giftui_nrf_ninja)" \
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

normalize_report() {
    awk '
        {
            sub(/[[:space:]]+$/, "")
            lines[NR] = $0
            if ($0 != "") last = NR
        }
        END {
            for (line_number = 1; line_number <= last; ++line_number) print lines[line_number]
        }
    '
}

if [[ "${1:-}" != "--reports-only" ]]; then
    for pass in 1 2; do
        build_fixture baseline "${baseline_build}"
        build_fixture candidate "${candidate_build}"
        baseline_elf="${baseline_build}/zephyr/zephyr.elf"
        candidate_elf="${candidate_build}/zephyr/zephyr.elf"
        tuple="$(linked_flash "${baseline_elf}"):$(linked_flash "${candidate_elf}"):$(linked_ram "${baseline_elf}"):$(linked_ram "${candidate_elf}")"
        if [[ "${pass}" == 1 ]]; then
            first_tuple="${tuple}"
        elif [[ "${tuple}" != "${first_tuple}" ]]; then
            printf 'error: pristine rebuild changed normalized size evidence\n' >&2
            exit 1
        fi
    done
fi

mkdir -p "${evidence_dir}/stack-usage"
baseline_elf="${baseline_build}/zephyr/zephyr.elf"
candidate_elf="${candidate_build}/zephyr/zephyr.elf"
"${readelf}" -h "${candidate_elf}" | normalize_report >"${evidence_dir}/elf-header.txt"
"${readelf}" -A "${candidate_elf}" | normalize_report >"${evidence_dir}/arm-attributes.txt"
"${readelf}" -lW "${candidate_elf}" | normalize_report >"${evidence_dir}/program-headers.txt"
"${size_tool}" -A "${baseline_elf}" | normalize_report >"${evidence_dir}/baseline-size.txt"
"${size_tool}" -A "${candidate_elf}" | normalize_report >"${evidence_dir}/candidate-size.txt"
"${nm_tool}" -S --size-sort "${candidate_elf}" >"${evidence_dir}/candidate-symbols.txt"
find "${candidate_build}" -name '*.su' -type f -exec cp {} "${evidence_dir}/stack-usage/" \;
cp "${candidate_build}/zephyr/.config" "${evidence_dir}/candidate-config.txt"

grep -Fq 'Machine:                           ARM' "${evidence_dir}/elf-header.txt"
grep -Fq 'Tag_CPU_arch: v7E-M' "${evidence_dir}/arm-attributes.txt"
grep -Fq 'Tag_ABI_VFP_args: VFP registers' "${evidence_dir}/arm-attributes.txt"
grep -Fqx 'CONFIG_HEAP_MEM_POOL_SIZE=0' "${candidate_build}/zephyr/.config"
grep -Fqx 'CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0' "${candidate_build}/zephyr/.config"
if "${nm_tool}" -g "${candidate_elf}" | awk '
    $2 ~ /[TtWw]/ &&
    ($3 == "malloc" || $3 == "calloc" || $3 == "realloc" ||
     $3 == "aligned_alloc" || $3 == "k_malloc" ||
     $3 == "k_calloc" || $3 == "k_realloc") { found = 1 }
    END { exit found ? 0 : 1 }
'; then
    printf 'error: allocator entry point retained in candidate ELF\n' >&2
    exit 1
fi

cc -std=c99 -Wall -Wextra -Werror \
    "${experiment_dir}/nrf/host-check.c" \
    "${experiment_dir}/nrf/candidate/validator.c" \
    "${experiment_dir}/generated/nrf-resource-data.c" \
    -I "${experiment_dir}/generated" \
    -o "${build_root}/spike-005-host-check"
"${build_root}/spike-005-host-check" >"${evidence_dir}/host-validation.txt"

baseline_flash="$(linked_flash "${baseline_elf}")"
candidate_flash="$(linked_flash "${candidate_elf}")"
baseline_ram="$(linked_ram "${baseline_elf}")"
candidate_ram="$(linked_ram "${candidate_elf}")"
baseline_bss="$(section_size "${baseline_elf}" bss)"
candidate_bss="$(section_size "${candidate_elf}" bss)"
baseline_data="$(section_size "${baseline_elf}" datas)"
candidate_data="$(section_size "${candidate_elf}" datas)"
main_stack="$(awk -F '\t' '$1 ~ /:main$/ { print $2 }' "${evidence_dir}/stack-usage/main.c.su")"
validate_stack="$(awk -F '\t' '$1 ~ /:spike005_validate$/ { print $2 }' "${evidence_dir}/stack-usage/validator.c.su")"
validate_inputs_stack="$(awk -F '\t' '$1 ~ /:spike005_validate_inputs$/ { print $2 }' "${evidence_dir}/stack-usage/validator.c.su")"
digest_stack="$(awk -F '\t' '$1 ~ /:validate_digest$/ { print $2 }' "${evidence_dir}/stack-usage/validator.c.su")"
update_stack="$(awk -F '\t' '$1 ~ /:update$/ { print $2 }' "${evidence_dir}/stack-usage/validator.c.su")"
validation_stack=$((main_stack + validate_stack + validate_inputs_stack + digest_stack + update_stack))
flash_delta=$((candidate_flash-baseline_flash))
ram_delta=$((candidate_ram-baseline_ram))

((flash_delta <= 98304)) || { printf 'error: resource flash delta exceeds SPEC-005 ceiling\n' >&2; exit 1; }
((ram_delta <= 512)) || { printf 'error: resource fixed RAM delta exceeds SPEC-005 ceiling\n' >&2; exit 1; }
((validation_stack <= 1024)) || { printf 'error: validation stack exceeds SPEC-005 ceiling\n' >&2; exit 1; }

cat >"${evidence_dir}/measurements.tsv" <<EOF
metric	baseline	candidate	delta	ceiling
linked_flash_bytes	${baseline_flash}	${candidate_flash}	${flash_delta}	98304
linked_ram_bytes	${baseline_ram}	${candidate_ram}	${ram_delta}	512
bss_bytes	${baseline_bss}	${candidate_bss}	$((candidate_bss-baseline_bss))	512
data_bytes	${baseline_data}	${candidate_data}	$((candidate_data-baseline_data))	512
validation_stack_bytes	0	${validation_stack}	${validation_stack}	1024
EOF

git_revision="$(git -C "${repository_root}" rev-parse HEAD)"
git_dirty="$(git -C "${repository_root}" status --short | wc -l | tr -d ' ') files"
baseline_hash="$(shasum -a 256 "${baseline_elf}" | awk '{print $1}')"
candidate_hash="$(shasum -a 256 "${candidate_elf}" | awk '{print $1}')"
cat >"${evidence_dir}/summary.md" <<EOF
# SPIKE-005 nRF52840 resource evidence

- Revision: ${git_revision} (dirty: ${git_dirty})
- Board: ${GIFTUI_NRF_BOARD}; ARMv7E-M hard-float ELF verified
- Zephyr: ${GIFTUI_NRF_ZEPHYR_VERSION}; SDK: ${GIFTUI_NRF_ZEPHYR_SDK_VERSION}
- Baseline ELF SHA-256: ${baseline_hash}
- Candidate ELF SHA-256: ${candidate_hash}
- Two pristine builds produced identical normalized size results.
- Both configured heaps are zero; no allocator entry point remains linked.
- Host execution recomputed and accepted both SHA-256 digests.

| Metric | Baseline | Candidate | Delta | SPEC-005 draft ceiling |
| --- | ---: | ---: | ---: | ---: |
| Linked flash bytes | ${baseline_flash} | ${candidate_flash} | ${flash_delta} | 98304 |
| Linked RAM bytes | ${baseline_ram} | ${candidate_ram} | ${ram_delta} | 512 |
| bss bytes | ${baseline_bss} | ${candidate_bss} | $((candidate_bss-baseline_bss)) | 512 |
| data bytes | ${baseline_data} | ${candidate_data} | $((candidate_data-baseline_data)) | 512 |
| Conservative validation call-chain stack | 0 | ${validation_stack} | ${validation_stack} | 1024 |

The stack value sums GCC static stack-usage results along the complete
main -> spike005_validate -> spike005_validate_inputs -> validate_digest ->
update call chain. It is
not a connected-hardware high-water measurement. No board was flashed or run.
EOF

printf 'SPIKE-005 nRF52840 resource evidence generated at %s\n' "${evidence_dir}"
