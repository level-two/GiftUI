#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
REGISTRY="${PROJECT_ROOT}/scripts/governance/focused-checks.tsv"

usage() { printf 'Usage: scripts/check-task.sh --spec SPEC-NNN --task Tn.n\n'; }
spec=""; task=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --spec) spec="$2"; shift 2 ;;
        --task) task="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'error: unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ "${spec}" =~ ^SPEC-[0-9]{3}$ && "${task}" =~ ^T[0-9]+\.[0-9]+$ ]] || { usage >&2; exit 2; }

printf 'gate-level=focused-task spec=%s task=%s\n' "${spec}" "${task}"
printf 'command: scripts/governance/check-task-evidence.rb --spec %s --task %s\n' "${spec}" "${task}"
if ! "${PROJECT_ROOT}/scripts/governance/check-task-evidence.rb" --spec "${spec}" --task "${task}"; then
    printf 'fail: task-evidence\n' >&2
    exit 1
fi
printf 'pass: task-evidence\n'

compact_spec="${spec/-/}"
manifest="${PROJECT_ROOT}/Tests/ContractFixtures/${compact_spec}/task-evidence.yaml"
checks="$(ruby -ryaml -e 'm=YAML.safe_load(File.read(ARGV[0]), aliases: false); Array(m.fetch("tasks").fetch(ARGV[1]).fetch("checks")).each { |item| puts item }' "${manifest}" "${task}")" || exit 1
failures=0; selected=0; skipped=0
while IFS= read -r check; do
    [[ -n "${check}" ]] || continue
    selected=$((selected + 1))
    row="$(awk -F '\t' -v wanted="${check}" '$1 == wanted { print; exit }' "${REGISTRY}")"
    if [[ -z "${row}" ]]; then
        printf 'fail: unregistered focused check %s\n' "${check}" >&2
        failures=$((failures + 1)); continue
    fi
    IFS=$'\t' read -ra fields <<<"${row}"
    mode="${fields[1]}"
    if [[ "${mode}" != direct ]]; then
        printf 'skipped: %s (registered for %s gate)\n' "${check}" "${mode}"
        skipped=$((skipped + 1)); continue
    fi
    command=("${PROJECT_ROOT}/${check}")
    for ((index=2; index<${#fields[@]}; index++)); do command+=("${PROJECT_ROOT}/${fields[index]}"); done
    printf 'command:'; printf ' %q' "${command[@]}"; printf '\n'
    if "${command[@]}"; then printf 'pass: %s\n' "${check}"; else
        printf 'fail: %s\n' "${check}" >&2; failures=$((failures + 1))
    fi
done <<<"${checks}"
printf 'focused-task-summary selected=%s passed=%s skipped=%s failed=%s\n' \
    "${selected}" "$((selected - skipped - failures))" "${skipped}" "${failures}"
[[ "${failures}" -eq 0 ]]
