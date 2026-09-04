#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
for test_file in "${PROJECT_ROOT}"/Tests/GovernanceTooling/*_test.rb; do
    printf 'governance-tooling-test: %s\n' "${test_file#"${PROJECT_ROOT}/"}"
    ruby "${test_file}"
done
