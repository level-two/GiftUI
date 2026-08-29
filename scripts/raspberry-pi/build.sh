#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

package_path="${GIFTUI_PI_PROJECT_ROOT}"
product=""
configuration="release"
link_static=1
probe=0
clean=0

usage() {
    cat <<'USAGE'
Usage: scripts/raspberry-pi/build.sh [options]

Options:
  --product NAME       SwiftPM executable product to build.
  --package-path PATH  Package directory; defaults to the repository root.
  --configuration CFG  release (default) or debug.
  --dynamic            Do not statically link the Swift standard library.
  --clean              Clean this product's cross-build scratch directory.
  --probe              Build the bundled ARMv6 toolchain probe.
  -h, --help           Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --product)
            [[ $# -ge 2 ]] || giftui_pi_error "--product requires a value"
            product="$2"
            shift
            ;;
        --package-path)
            [[ $# -ge 2 ]] || giftui_pi_error "--package-path requires a value"
            package_path="$2"
            shift
            ;;
        --configuration)
            [[ $# -ge 2 ]] || giftui_pi_error "--configuration requires a value"
            configuration="$2"
            shift
            ;;
        --dynamic)
            link_static=0
            ;;
        --clean)
            clean=1
            ;;
        --probe)
            probe=1
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

[[ "${configuration}" == "release" || "${configuration}" == "debug" ]] ||
    giftui_pi_error "configuration must be release or debug"

if [[ "${probe}" -eq 1 ]]; then
    package_path="${GIFTUI_PI_PROBE_PACKAGE}"
    product="${GIFTUI_PI_PROBE_PRODUCT}"
else
    [[ -n "${product}" ]] ||
        giftui_pi_error "--product is required unless --probe is used"
fi
[[ "${product}" =~ ^[A-Za-z0-9._-]+$ ]] ||
    giftui_pi_error "invalid product name: ${product}"

if [[ "${package_path}" != /* ]]; then
    package_path="${GIFTUI_PI_PROJECT_ROOT}/${package_path}"
fi
[[ -f "${package_path}/Package.swift" ]] ||
    giftui_pi_error "Package.swift not found under ${package_path}"
package_path="$(giftui_pi_absolute_path "${package_path}")"

giftui_pi_require_sdk
giftui_pi_prepare_build_environment
host_swift="$(giftui_pi_host_swift)"
host_version="$(giftui_pi_host_swift_version_line)"
[[ "${host_version}" == *"Swift version ${GIFTUI_PI_SWIFT_VERSION}"* ]] ||
    giftui_pi_error "host Swift ${GIFTUI_PI_SWIFT_VERSION} is required; found: ${host_version}"

if [[ "${link_static}" -eq 1 ]]; then
    destination="${GIFTUI_PI_STATIC_DESTINATION}"
    linkage="static"
else
    destination="${GIFTUI_PI_DYNAMIC_DESTINATION}"
    linkage="dynamic"
fi

scratch_path="${GIFTUI_PI_BUILD_ROOT}/scratch/${product}-${configuration}-${linkage}"
artifact_path="${GIFTUI_PI_ARTIFACTS_DIR}/${product}"

if [[ "${clean}" -eq 1 && -d "${scratch_path}" ]]; then
    giftui_pi_note "cleaning ${scratch_path}"
    rm -rf "${scratch_path}"
fi

mkdir -p "${scratch_path}" "${GIFTUI_PI_ARTIFACTS_DIR}"

build_arguments=(
    build
    --package-path "${package_path}"
    --scratch-path "${scratch_path}"
    --destination "${destination}"
    --configuration "${configuration}"
    --product "${product}"
)
if [[ "${link_static}" -eq 1 ]]; then
    build_arguments+=(--static-swift-stdlib)
fi

giftui_pi_note "building ${product} for ${GIFTUI_PI_TARGET} (${configuration}, ${linkage} Swift runtime)"
"${host_swift}" "${build_arguments[@]}"

binary_directory="$(
    "${host_swift}" build \
        --package-path "${package_path}" \
        --scratch-path "${scratch_path}" \
        --destination "${destination}" \
        --configuration "${configuration}" \
        --show-bin-path
)"
binary_path="${binary_directory}/${product}"
[[ -f "${binary_path}" ]] ||
    giftui_pi_error "SwiftPM completed but ${binary_path} was not produced"

cp -f "${binary_path}" "${artifact_path}"
giftui_pi_note "stripping deploy artifact"
"${GIFTUI_PI_HOST_BIN_DIR}/llvm-objcopy" --strip-all "${artifact_path}"
chmod 0755 "${artifact_path}"

file_description="$(giftui_pi_verify_armv6_binary "${artifact_path}")"
giftui_pi_note "verified ARMv6 hard-float binary: ${file_description}"
printf 'ARTIFACT=%s\n' "${artifact_path}"
