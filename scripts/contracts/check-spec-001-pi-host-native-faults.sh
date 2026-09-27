#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
output="${project_root}/.build/contract-generated/spec-001/pi-host-native-rehearsal"
mkdir -p "${output}"

for mode in display-initial display-next input-overflow; do
    trace="${output}/fault-${mode}.tsv"
    GIFTUI_REHEARSAL_FAULT="${mode}" \
        "${project_root}/scripts/contracts/check-spec-001-pi-host-native-rehearsal.sh" \
        > "${trace}"
    grep -Fq "fault=${mode}" "${trace}"
    grep -Fq $'status=passed' "${trace}"
    if grep -q '^trace=action' "${trace}"; then
        printf 'unexpected action after %s fault\n' "${mode}" >&2
        exit 1
    fi
done
printf 'SPEC-001 Pi production-loop faults passed: startup display, later display, and input overflow.\n'
