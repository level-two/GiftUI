#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
output="${project_root}/.build/contract-generated/spec-001/nrf-host-native-rehearsal"
mkdir -p "${output}"
"${project_root}/scripts/contracts/check-spec-001-nrf-host-native-rehearsal.sh" \
    > "${output}/baseline-fault-trace.tsv"
binary="${output}/host-native-rehearsal"

frame_hash() {
    awk -F '\t' -v revision="$1" \
        '$1 == "trace=frame" && $2 == "revision=" revision {
            for (i = 1; i <= NF; i++) if ($i ~ /^frame_hash=/) {
                sub(/^frame_hash=/, "", $i); print $i; exit
            }
        }' "${output}/baseline-fault-trace.tsv"
}
idle_hash="$(frame_hash 1)"
next_hash="$(frame_hash 2)"
[[ -n "${idle_hash}" && -n "${next_hash}" ]]

for mode in touch-startup display-startup write-initial write-next \
    input-idle read-input poll-after-frame; do
    trace="${output}/fault-${mode}.tsv"
    GIFTUI_REHEARSAL_FAULT="${mode}" "${binary}" > "${trace}"
    grep -Fq "fault=${mode}" "${trace}"
    grep -Fq $'result=-5\t' "${trace}"
    grep -Fq $'status=passed' "${trace}"
    if grep -q '^trace=action' "${trace}"; then
        printf 'unexpected action after %s fault\n' "${mode}" >&2
        exit 1
    fi
    case "${mode}" in
        input-idle | read-input | write-next)
            grep -Fq "last_frame_hash=${idle_hash}" "${trace}" ;;
        poll-after-frame) grep -Fq "last_frame_hash=${next_hash}" "${trace}" ;;
        *) grep -Fq 'last_frame_hash=1225258071749886757' "${trace}" ;;
    esac
done
printf 'SPEC-001 nRF production-loop faults passed: seven injected paths and retained frames.\n'
