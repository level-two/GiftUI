#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

host="${GIFTUI_PI_HOST}"
user="${GIFTUI_PI_USER}"
remote_dir="${GIFTUI_PI_REMOTE_DIR}"
product="${GIFTUI_PI_PRODUCT}"
artifact=""
identity="${GIFTUI_PI_SSH_IDENTITY:-}"
configuration="release"
build_first=1
run_after=0
restart_service=""
dry_run=0

usage() {
    cat <<'USAGE'
Usage: scripts/raspberry-pi/deploy.sh [options]

Options:
  --host HOST             Raspberry Pi host; default giftui-pi.local.
  --user USER             SSH user; default giftui.
  --remote-dir DIR        Directory relative to the remote home.
  --identity FILE         SSH private key.
  --product NAME          SwiftPM executable product to build and deploy.
  --artifact PATH         Deploy an existing ARM ELF binary.
  --configuration CFG     release (default) or debug.
  --no-build              Deploy the existing local artifact.
  --run                   Run the binary over SSH after deployment.
  --restart-service NAME  Restart a user systemd service after deployment.
  --dry-run               Print remote-changing commands without running them.
  -h, --help              Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)
            [[ $# -ge 2 ]] || giftui_pi_error "--host requires a value"
            host="$2"
            shift
            ;;
        --user)
            [[ $# -ge 2 ]] || giftui_pi_error "--user requires a value"
            user="$2"
            shift
            ;;
        --remote-dir)
            [[ $# -ge 2 ]] || giftui_pi_error "--remote-dir requires a value"
            remote_dir="$2"
            shift
            ;;
        --identity)
            [[ $# -ge 2 ]] || giftui_pi_error "--identity requires a value"
            identity="$2"
            shift
            ;;
        --product)
            [[ $# -ge 2 ]] || giftui_pi_error "--product requires a value"
            product="$2"
            shift
            ;;
        --artifact)
            [[ $# -ge 2 ]] || giftui_pi_error "--artifact requires a value"
            artifact="$2"
            build_first=0
            shift
            ;;
        --configuration)
            [[ $# -ge 2 ]] || giftui_pi_error "--configuration requires a value"
            configuration="$2"
            shift
            ;;
        --no-build)
            build_first=0
            ;;
        --run)
            run_after=1
            ;;
        --restart-service)
            [[ $# -ge 2 ]] || giftui_pi_error "--restart-service requires a value"
            restart_service="$2"
            shift
            ;;
        --dry-run)
            dry_run=1
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            giftui_pi_error "unknown option: $1"
            ;;
    esac
    shift
done

[[ "${host}" =~ ^[A-Za-z0-9._-]+$ ]] || giftui_pi_error "invalid host: ${host}"
[[ "${user}" =~ ^[A-Za-z0-9._-]+$ ]] || giftui_pi_error "invalid user: ${user}"
[[ "${product}" =~ ^[A-Za-z0-9._-]+$ ]] || giftui_pi_error "invalid product: ${product}"
[[ "${remote_dir}" =~ ^[A-Za-z0-9._/-]+$ ]] ||
    giftui_pi_error "invalid remote directory: ${remote_dir}"
[[ "${remote_dir}" != *".."* ]] ||
    giftui_pi_error "remote directory must not contain '..'"
if [[ -n "${restart_service}" ]]; then
    [[ "${restart_service}" =~ ^[A-Za-z0-9@._-]+$ ]] ||
        giftui_pi_error "invalid service name: ${restart_service}"
fi

if [[ "${build_first}" -eq 1 ]]; then
    "${SCRIPT_DIR}/build.sh" \
        --product "${product}" \
        --configuration "${configuration}"
    artifact="${GIFTUI_PI_ARTIFACTS_DIR}/${product}"
elif [[ -z "${artifact}" ]]; then
    artifact="${GIFTUI_PI_ARTIFACTS_DIR}/${product}"
fi

if [[ "${artifact}" != /* ]]; then
    artifact="${GIFTUI_PI_PROJECT_ROOT}/${artifact}"
fi
[[ -f "${artifact}" ]] || giftui_pi_error "artifact not found: ${artifact}"

file_description="$(giftui_pi_verify_armv6_binary "${artifact}")"
giftui_pi_note "verified deploy artifact: ${file_description}"

ssh_options=(-o BatchMode=yes -o ConnectTimeout=30)
scp_options=(-o BatchMode=yes -o ConnectTimeout=30)
if [[ -n "${identity}" ]]; then
    [[ -f "${identity}" ]] || giftui_pi_error "SSH identity not found: ${identity}"
    ssh_options+=(-i "${identity}")
    scp_options+=(-i "${identity}")
fi

target="${user}@${host}"
incoming="${remote_dir}/${product}.incoming"
deployed="${remote_dir}/${product}"

print_command() {
    printf '+'
    printf ' %q' "$@"
    printf '\n'
}

if [[ "${dry_run}" -eq 1 ]]; then
    print_command ssh "${ssh_options[@]}" "${target}" "uname -m"
    print_command ssh "${ssh_options[@]}" "${target}" "mkdir -p -- '${remote_dir}'"
    print_command scp "${scp_options[@]}" "${artifact}" "${target}:${incoming}"
    print_command ssh "${ssh_options[@]}" "${target}" \
        "chmod 0755 '${incoming}' && mv -f '${incoming}' '${deployed}'"
    if [[ -n "${restart_service}" ]]; then
        print_command ssh "${ssh_options[@]}" "${target}" \
            "systemctl --user restart '${restart_service}'"
    fi
    if [[ "${run_after}" -eq 1 ]]; then
        print_command ssh "${ssh_options[@]}" "${target}" "'${deployed}'"
    fi
    exit 0
fi

giftui_pi_note "checking ${target}"
remote_arch="$(ssh "${ssh_options[@]}" "${target}" uname -m)"
[[ "${remote_arch}" == "armv6l" ]] ||
    giftui_pi_error "remote host reports ${remote_arch}; expected armv6l"

giftui_pi_note "deploying ${product} to ${target}:${deployed}"
ssh "${ssh_options[@]}" "${target}" "mkdir -p -- '${remote_dir}'"
scp "${scp_options[@]}" "${artifact}" "${target}:${incoming}"
ssh "${ssh_options[@]}" "${target}" \
    "chmod 0755 '${incoming}' && mv -f '${incoming}' '${deployed}'"

if [[ -n "${restart_service}" ]]; then
    giftui_pi_note "restarting user service ${restart_service}"
    ssh "${ssh_options[@]}" "${target}" \
        "systemctl --user restart '${restart_service}'"
fi

if [[ "${run_after}" -eq 1 ]]; then
    giftui_pi_note "running ${deployed}"
    ssh "${ssh_options[@]}" "${target}" "'${deployed}'"
fi

printf 'DEPLOYED=%s:%s\n' "${target}" "${deployed}"
