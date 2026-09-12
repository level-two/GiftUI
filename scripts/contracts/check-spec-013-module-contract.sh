#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
# shellcheck source=../lib/swiftpm.sh
source "${PROJECT_ROOT}/scripts/lib/swiftpm.sh"

work_dir="$(mktemp -d /private/tmp/giftui-spec-013-module-contract.XXXXXX)"
trap 'rm -rf "${work_dir}"' EXIT

giftui_swiftpm \
    --package-path "${PROJECT_ROOT}" \
    --scratch-path "${work_dir}/swiftpm" \
    --cache-root "${work_dir}" \
    --disable-sandbox \
    -- package dump-package >"${work_dir}/package.json"
"${SCRIPT_DIR}/check-spec-013-module-contract.rb" <"${work_dir}/package.json"
