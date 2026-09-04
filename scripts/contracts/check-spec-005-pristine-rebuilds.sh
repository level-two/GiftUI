#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
OUTPUT_ROOT="${1:-${PROJECT_ROOT}/.build/contract-reports/spec-005/pristine-rebuilds}"
REVISION="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
TEMP_PARENT="${PROJECT_ROOT}/.build/contract-temp"
mkdir -p "${TEMP_PARENT}"
TEMP_ROOT="$(mktemp -d "${TEMP_PARENT}/spec-005-pristine.XXXXXX")"
PROFILES=(macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded)

cleanup() {
    local result=$?
    if [[ "${result}" -ne 0 ]]; then
        printf 'SPEC-005 pristine rebuild failure preserved at %s\n' \
            "${TEMP_ROOT}" >&2
        return
    fi
    rm -rf "${TEMP_ROOT}"
}
trap cleanup EXIT

link_project_toolchains() {
    local checkout="$1"
    local toolchain_path sdk_path sdk_entry destination

    mkdir -p "${checkout}/.toolchains" "${checkout}/.toolchains/sdk"
    for toolchain_path in "${PROJECT_ROOT}"/.toolchains/*; do
        [[ "$(basename "${toolchain_path}")" == "sdk" ]] && continue
        ln -s "${toolchain_path}" "${checkout}/.toolchains/$(basename "${toolchain_path}")"
    done
    for sdk_path in "${PROJECT_ROOT}"/.toolchains/sdk/*; do
        destination="${checkout}/.toolchains/sdk/$(basename "${sdk_path}")"
        mkdir -p "${destination}"
        for sdk_entry in "${sdk_path}"/* "${sdk_path}"/.[!.]*; do
            [[ -e "${sdk_entry}" ]] || continue
            if [[ "${sdk_entry}" == *.json ]]; then
                sed "s|${PROJECT_ROOT}|${checkout}|g" "${sdk_entry}" \
                    >"${destination}/$(basename "${sdk_entry}")"
            else
                ln -s "${sdk_entry}" "${destination}/$(basename "${sdk_entry}")"
            fi
        done
    done
}

rm -rf "${OUTPUT_ROOT}"
mkdir -p "${OUTPUT_ROOT}/logs"
for index in 1 2; do
    checkout="${TEMP_ROOT}/checkout-${index}"
    git clone --quiet --shared --no-checkout "${PROJECT_ROOT}" "${checkout}"
    git -C "${checkout}" checkout --quiet --detach "${REVISION}"
    [[ -z "$(git -C "${checkout}" status --porcelain --untracked-files=all)" ]] || {
        printf 'error: temporary checkout %s is not pristine\n' "${index}" >&2
        exit 1
    }
    link_project_toolchains "${checkout}"
    for local_environment in \
        scripts/raspberry-pi/local.env \
        scripts/nrf52840/local.env; do
        if [[ -f "${PROJECT_ROOT}/${local_environment}" ]]; then
            ln -s "${PROJECT_ROOT}/${local_environment}" \
                "${checkout}/${local_environment}"
        fi
    done
    for profile in "${PROFILES[@]}"; do
        printf 'SPEC-005 pristine checkout %s: %s\n' "${index}" "${profile}"
        "${checkout}/scripts/contracts/run-spec-005.sh" --profile "${profile}" \
            >"${OUTPUT_ROOT}/logs/checkout-${index}-${profile}.log" 2>&1
    done
done

"${SCRIPT_DIR}/compare-spec-005-pristine-rebuilds.rb" \
    "${TEMP_ROOT}/checkout-1" "${TEMP_ROOT}/checkout-2" \
    "${OUTPUT_ROOT}/normalized-artifacts.tsv"
printf 'SPEC-005 pristine rebuild check passed at revision %s; report: %s\n' \
    "${REVISION}" "${OUTPUT_ROOT}"
