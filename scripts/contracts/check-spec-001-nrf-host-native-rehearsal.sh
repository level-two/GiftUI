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
cat "${source_file}" \
    "${application}/tests/host_native_rehearsal_hooks.swift" \
    > "${output}/host_native_rehearsal.swift"

owner_output="${project_root}/.build/contract-generated/spec-001/nrf-native-owners"
python3 "${project_root}/scripts/contracts/compile-spec-001-nrf-native-owners.py" --output "${owner_output}"
owner_objects=()
while IFS= read -r object; do owner_objects+=("${object}"); done < "${owner_output}/owner-objects.txt"
native_optimization="${GIFTUI_NATIVE_OPTIMIZATION:--Osize}"
swiftc -I "${owner_output}/modules" -DGIFTUI_REFERENCE_BITMAP_ONLY -parse-as-library "${native_optimization}" -package-name GiftUI -D GIFTUI_NRF_EMBEDDED \
    -emit-object "${output}/host_native_rehearsal.swift" -o "${output}/application.o"

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
objects=("${output}/application.o" "${owner_objects[@]}")
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
if [[ "${GIFTUI_REHEARSAL_COMMON_OWNER:-}" == 1 ]]; then exit 0; fi
# Keep negative touch probes in a separate firmware lifetime so their idle time
# cannot shift the paced acquisition corpus compared with the macOS oracle.
env -u GIFTUI_REHEARSAL_RASTERS -u GIFTUI_REHEARSAL_FAULT -u GIFTUI_REHEARSAL_DIAGNOSTIC \
    GIFTUI_REHEARSAL_TOUCH_PROBE=1 "${output}/host-native-rehearsal" \
    > "${output}/touch-probes.tsv"
grep '^trace=touch-probe' "${output}/touch-probes.tsv"

# Typed failures exercise the actual selected firmware owner in a fresh lifetime.
env -u GIFTUI_REHEARSAL_RASTERS -u GIFTUI_REHEARSAL_FAULT -u GIFTUI_REHEARSAL_DIAGNOSTIC \
    GIFTUI_REHEARSAL_COMMON_OWNER=1 "${output}/host-native-rehearsal" \
    > "${output}/common-owner-probes.tsv"
grep "^static-owner-" "${output}/common-owner-probes.tsv"
