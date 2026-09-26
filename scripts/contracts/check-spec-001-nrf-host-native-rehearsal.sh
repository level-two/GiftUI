#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
application="${project_root}/firmware/nrf52840/applications/signal-analyzer-static"
source_file="${project_root}/.build/nrf52840/signal-analyzer-static/SignalAnalyzerStatic.swift"
output="${project_root}/.build/contract-generated/spec-001/nrf-host-native-rehearsal"

[[ -f "${source_file}" ]] || {
    printf 'nRF amalgamated Swift source missing; build signal-analyzer-static first\n' >&2
    exit 1
}
mkdir -p "${output}" "${output}/clang-cache"
export CLANG_MODULE_CACHE_PATH="${output}/clang-cache"

swiftc -parse-as-library -Osize -package-name GiftUI -D GIFTUI_NRF_EMBEDDED \
    -emit-object "${source_file}" -o "${output}/application.o"

c_sources=(
    "${application}/src/main.c"
    "${application}/src/production_host.c"
    "${application}/src/static_host_lifecycle.c"
    "${application}/src/static_host_scheduler.c"
    "${application}/src/static_touch_pipeline.c"
    "${application}/src/static_input_bridge.c"
    "${application}/src/touch_input.c"
    "${application}/src/storage.c"
    "${application}/tests/host_native_rehearsal.c"
)
objects=("${output}/application.o")
for source in "${c_sources[@]}"; do
    object="${output}/$(basename "${source}" .c).o"
    if [[ "$(basename "${source}")" == main.c ]]; then
        cc -std=c99 -O2 -Wall -Wextra -Werror \
            -I "${application}/tests/fake-zephyr" \
            -I "${application}/include" \
            -Dmain=giftui_firmware_main -c "${source}" -o "${object}"
        objects+=("${object}")
        continue
    fi
    cc -std=c99 -O2 -Wall -Wextra -Werror \
        -I "${application}/tests/fake-zephyr" \
        -I "${application}/include" \
        -c "${source}" -o "${object}"
    objects+=("${object}")
done
swiftc "${objects[@]}" -o "${output}/host-native-rehearsal"
"${output}/host-native-rehearsal"
