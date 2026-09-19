#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
# shellcheck source=../raspberry-pi/common.sh
source "${PROJECT_ROOT}/scripts/raspberry-pi/common.sh"

host="${GIFTUI_PI_HOST}"
user="${GIFTUI_PI_USER}"
remote_dir="${GIFTUI_PI_REMOTE_DIR}"
host_key_alias=""
product="GiftUIFailureRaspberryPiLatencyProbe"

usage() {
    cat <<'USAGE'
Usage: scripts/contracts/run-spec-003-connected-pi.sh [options]

Options:
  --host HOST             Raspberry Pi host; default from the Pi workflow.
  --user USER             SSH user; default from the Pi workflow.
  --remote-dir DIR        Directory relative to the remote home.
  --host-key-alias NAME   Verify HOST against this saved SSH host-key name.
  -h, --help              Show this help.
USAGE
}

fail() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)
            [[ $# -ge 2 ]] || fail "--host requires a value"
            host="$2"
            shift 2
            ;;
        --user)
            [[ $# -ge 2 ]] || fail "--user requires a value"
            user="$2"
            shift 2
            ;;
        --remote-dir)
            [[ $# -ge 2 ]] || fail "--remote-dir requires a value"
            remote_dir="$2"
            shift 2
            ;;
        --host-key-alias)
            [[ $# -ge 2 ]] || fail "--host-key-alias requires a value"
            host_key_alias="$2"
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *) fail "unknown option: $1" ;;
    esac
done

[[ "${host}" =~ ^[A-Za-z0-9._-]+$ ]] || fail "invalid host: ${host}"
[[ "${user}" =~ ^[A-Za-z0-9._-]+$ ]] || fail "invalid user: ${user}"
[[ "${remote_dir}" =~ ^[A-Za-z0-9._/-]+$ && "${remote_dir}" != *".."* ]] ||
    fail "invalid remote directory: ${remote_dir}"
if [[ -n "${host_key_alias}" ]]; then
    [[ "${host_key_alias}" =~ ^[A-Za-z0-9._-]+$ ]] ||
        fail "invalid host-key alias: ${host_key_alias}"
fi

revision="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
[[ -z "$(git -C "${PROJECT_ROOT}" status --porcelain --untracked-files=normal)" ]] ||
    fail "connected evidence requires a clean repository revision"

input_digest="$({
    shasum -a 256 \
        "${PROJECT_ROOT}/Sources/GiftUIFailureCore/GiftUIFailureCore.swift" \
        "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC003/Instrumentation/LatencyProbe/main.swift" \
        "${PROJECT_ROOT}/scripts/contracts/run-spec-003-connected-pi.sh" \
        "${PROJECT_ROOT}/scripts/contracts/run-spec-003.sh" \
        "${PROJECT_ROOT}/scripts/raspberry-pi/deploy.sh" \
        "${PROJECT_ROOT}/scripts/raspberry-pi/toolchain.env"
} | shasum -a 256 | cut -c 1-16)"
run_id="${revision}-${input_digest}"
report_root="${PROJECT_ROOT}/.build/contract-reports/spec-003-connected-pi"
report_dir="${report_root}/${run_id}"
[[ ! -e "${report_dir}" ]] || fail "immutable report already exists: ${report_dir}"
staging_dir="$(mktemp -d "${PROJECT_ROOT}/.build/spec-003-connected-pi.XXXXXX")"
build_dir="${staging_dir}/build"
mkdir -p "${build_dir}" "${staging_dir}/resource-evidence"

cleanup() {
    if [[ -d "${staging_dir}" ]]; then
        rm -rf "${staging_dir}"
    fi
}
trap cleanup EXIT

commands_path="${staging_dir}/commands.txt"
: >"${commands_path}"
record_command() {
    printf '%q ' "$@" >>"${commands_path}"
    printf '\n' >>"${commands_path}"
}

"${PROJECT_ROOT}/scripts/raspberry-pi/doctor.sh" >"${staging_dir}/toolchain-doctor.txt"
"${PROJECT_ROOT}/scripts/contracts/run-spec-003.sh" --profile raspberry-pi-armv6
resource_run_id="$(<"${PROJECT_ROOT}/.build/contract-reports/spec-003/latest-raspberry-pi-armv6.txt")"
resource_dir="${PROJECT_ROOT}/.build/contract-reports/spec-003/${resource_run_id}/raspberry-pi-armv6"
[[ "${resource_run_id}" == "${revision}-"* ]] ||
    fail "resource evidence revision differs: ${resource_run_id}"
cp "${resource_dir}/metadata.txt" "${staging_dir}/resource-evidence/metadata.txt"
cp "${resource_dir}/resources/build-1/resource-summary.tsv" \
    "${staging_dir}/resource-evidence/resource-summary.tsv"
cp "${resource_dir}/resources/build-1/call-graph.tsv" \
    "${staging_dir}/resource-evidence/call-graph.tsv"
cp "${resource_dir}/resources/build-1/sections.tsv" \
    "${staging_dir}/resource-evidence/sections.tsv"

giftui_pi_require_sdk
giftui_pi_prepare_build_environment
compiler="${GIFTUI_PI_HOST_BIN_DIR}/swiftc"
sdk_root="${GIFTUI_PI_SDK_DIR}/${GIFTUI_PI_DISTRIBUTION}"
core_object="${build_dir}/GiftUIFailureCore.o"
probe="${build_dir}/${product}"
common_flags=(
    -target "${GIFTUI_PI_TARGET}"
    -sdk "${sdk_root}"
    -use-ld=lld
    -resource-dir "${sdk_root}/usr/lib/swift_static"
    -Xcc "--gcc-toolchain=${sdk_root}/usr"
    -Xcc -march=armv6
    -Xcc -mfpu=vfp
    -Xcc -mfloat-abi=hard
    -O -whole-module-optimization -cross-module-optimization
    -DGIFTUI_DYNAMIC_PROFILE -language-mode 6
)
core_command=(
    "${compiler}" "${common_flags[@]}" -enable-testing -parse-as-library
    -emit-module -emit-object -module-name GiftUIFailureCore
    "${PROJECT_ROOT}/Sources/GiftUIFailureCore/GiftUIFailureCore.swift"
    -emit-module-path "${build_dir}/GiftUIFailureCore.swiftmodule"
    -o "${core_object}"
)
record_command "${core_command[@]}"
"${core_command[@]}"
probe_command=(
    "${compiler}" "${common_flags[@]}" -DGIFTUI_RASPBERRY_PI_PROFILE
    -I "${build_dir}"
    "${PROJECT_ROOT}/Tests/ContractFixtures/SPEC003/Instrumentation/LatencyProbe/main.swift"
    "${core_object}" -static-stdlib -latomic
    -Xlinker --gc-sections -Xlinker --no-pie -Xlinker --build-id=none
    -o "${probe}"
)
record_command "${probe_command[@]}"
"${probe_command[@]}"
chmod 0755 "${probe}"
giftui_pi_verify_armv6_binary "${probe}" >"${staging_dir}/artifact-file.txt"
"${GIFTUI_PI_HOST_BIN_DIR}/llvm-objdump" -s -j .ARM.attributes "${probe}" \
    >"${staging_dir}/artifact-arm-attributes.txt"
artifact_sha256="$(shasum -a 256 "${probe}" | awk '{print $1}')"

ssh_options=(-o BatchMode=yes -o ConnectTimeout=30)
if [[ -n "${host_key_alias}" ]]; then
    ssh_options+=(-o "HostKeyAlias=${host_key_alias}" -o StrictHostKeyChecking=yes)
fi
target="${user}@${host}"
remote_program="${remote_dir}/${product}"
record_command ssh "${ssh_options[@]}" "${target}" uname -m
remote_arch="$(ssh "${ssh_options[@]}" "${target}" uname -m)"
[[ "${remote_arch}" == armv6l ]] || fail "remote reports ${remote_arch}; expected armv6l"
ssh "${ssh_options[@]}" "${target}" \
    'uname -a; cat /etc/os-release; cat /proc/cpuinfo; getconf PAGE_SIZE' \
    >"${staging_dir}/target-identity.txt"

deploy_command=(
    "${PROJECT_ROOT}/scripts/raspberry-pi/deploy.sh"
    --host "${host}" --user "${user}" --remote-dir "${remote_dir}"
    --product "${product}" --artifact "${probe}"
)
if [[ -n "${host_key_alias}" ]]; then
    deploy_command+=(--host-key-alias "${host_key_alias}")
fi
record_command "${deploy_command[@]}"
"${deploy_command[@]}" >"${staging_dir}/deployment.txt"

remote_sha256="$(ssh "${ssh_options[@]}" "${target}" "sha256sum '${remote_program}'" | awk '{print $1}')"
[[ "${remote_sha256}" == "${artifact_sha256}" ]] || fail "deployed artifact digest differs"
remote_run_command="'${remote_program}'; probe_status=\$?; rm -f '${remote_program}'; if test -e '${remote_program}'; then printf 'teardown=present\\n' >&2; exit 71; fi; printf 'teardown=removed\\n' >&2; exit \${probe_status}"
record_command ssh "${ssh_options[@]}" "${target}" "${remote_run_command}"
ssh "${ssh_options[@]}" "${target}" "${remote_run_command}" \
    >"${staging_dir}/latency-samples.txt" \
    2>"${staging_dir}/teardown.txt"
grep -Fxq 'warmup_iterations=1000' "${staging_dir}/latency-samples.txt" ||
    fail "remote latency warm-up count differs"
grep -Fxq 'measured_iterations=10000' "${staging_dir}/latency-samples.txt" ||
    fail "remote latency sample count differs"
grep -Fxq 'p99_limit_nanoseconds=150000' "${staging_dir}/latency-samples.txt" ||
    fail "remote latency limit differs"
[[ "$(grep -c '^sample_nanoseconds\[[0-9][0-9]*\]=' "${staging_dir}/latency-samples.txt")" -eq 10000 ]] ||
    fail "remote latency raw sample count differs"
awk -F= '/^p99_nanoseconds=/ { if ($2 > 150000) exit 1; found = 1 } END { if (!found) exit 1 }' \
    "${staging_dir}/latency-samples.txt" || fail "remote p99 exceeds 150 microseconds"
grep -Fxq 'teardown=removed' "${staging_dir}/teardown.txt" ||
    fail "remote probe teardown was not verified"

compiler_version="$("${compiler}" --version)"
p99_nanoseconds="$(awk -F= '/^p99_nanoseconds=/ { print $2 }' "${staging_dir}/latency-samples.txt")"
{
    printf 'schema_version=1\n'
    printf 'spec=SPEC-003\ntask=T6.2\nevidence_kind=connected-target\n'
    printf 'repository_revision=%s\ninput_digest=%s\n' "${revision}" "${input_digest}"
    printf 'target=%s\nremote_arch=%s\n' "${target}" "${remote_arch}"
    printf 'host_key_alias=%s\n' "${host_key_alias:-none}"
    printf 'target_triple=%s\noptimization=-O -whole-module-optimization\n' "${GIFTUI_PI_TARGET}"
    printf 'compiler=%s\n' "${compiler_version//$'\n'/; }"
    printf 'artifact_sha256=%s\nremote_artifact_sha256=%s\n' \
        "${artifact_sha256}" "${remote_sha256}"
    printf 'resource_run_id=%s\n' "${resource_run_id}"
    printf 'warmup_iterations=1000\nmeasured_iterations=10000\n'
    printf 'p99_nanoseconds=%s\np99_limit_nanoseconds=150000\n' "${p99_nanoseconds}"
    printf 'deployment=true\nservice_restart=false\nteardown=true\nstatus=complete\n'
} >"${staging_dir}/metadata.txt"

mkdir -p "${report_root}"
mv "${staging_dir}" "${report_dir}"
trap - EXIT
printf '%s\n' "${run_id}" >"${report_root}/latest.txt"
printf 'SPEC-003 connected Raspberry Pi evidence passed\n'
printf 'REPORT=%s\n' "${report_dir}"
