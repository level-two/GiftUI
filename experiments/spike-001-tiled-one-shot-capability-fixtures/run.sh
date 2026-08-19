#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd "${script_dir}/../.." && pwd)"
build_dir="${repository_root}/.build/spikes/spike-001"
result_dir="${build_dir}/results"
module_cache_dir="${build_dir}/module-cache"

mkdir -p "${build_dir}" "${result_dir}" "${module_cache_dir}"
CLANG_MODULE_CACHE_PATH="${module_cache_dir}" \
SWIFT_MODULECACHE_PATH="${module_cache_dir}" \
swiftc -O -module-cache-path "${module_cache_dir}" \
    "${script_dir}/main.swift" -o "${build_dir}/spike-001"
"${build_dir}/spike-001" "${result_dir}"
