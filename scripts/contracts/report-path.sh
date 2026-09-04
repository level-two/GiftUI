#!/usr/bin/env bash

giftui_contract_profile_report() {
    local report_root="$1" profile="$2"
    if [[ -n "${GIFTUI_CONTRACT_RUN_ID:-}" ]]; then
        local matched="${report_root}/${GIFTUI_CONTRACT_RUN_ID}/${profile}"
        [[ -d "${matched}" ]] || return 1
        printf '%s\n' "${matched}"
        return 0
    fi
    local pointer="${report_root}/latest-${profile}.txt"
    if [[ -f "${pointer}" ]]; then
        local run_id
        run_id="$(tr -d '\n' <"${pointer}")"
        [[ -d "${report_root}/${run_id}/${profile}" ]] || return 1
        printf '%s\n' "${report_root}/${run_id}/${profile}"
        return 0
    fi
    [[ -d "${report_root}/${profile}" ]] || return 1
    printf '%s\n' "${report_root}/${profile}"
}
