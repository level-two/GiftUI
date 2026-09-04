#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
CONFIGURATION="${PROJECT_ROOT}/.swift-format"

usage() {
  printf '%s\n' \
    'Usage: scripts/format-swift.sh [--lint]' \
    '' \
    'With no argument, formats maintained Swift files in place.' \
    'With --lint, reports formatting differences without changing files.'
}

mode="format"
case $# in
  0) ;;
  1)
    case "$1" in
      --lint) mode="lint" ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        exit 2
        ;;
    esac
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if ! command -v swift >/dev/null 2>&1 || ! swift format --version >/dev/null 2>&1; then
  printf '%s\n' \
    'error: the selected Swift toolchain does not provide the swift format command' >&2
  exit 1
fi

files=()
while IFS= read -r path; do
  case "${path}" in
    Package.swift | Sources/*.swift | Tests/*Tests/*.swift | \
      demo/SignalAnalyzer/Package.swift | demo/SignalAnalyzer/Sources/*.swift | \
      demo/SignalAnalyzer/Tests/*.swift | scripts/raspberry-pi/probe/Package.swift | \
      scripts/raspberry-pi/probe/Sources/*.swift)
      case "${path}" in
        */Generated/* | Sources/GiftUIFailureDiagnostics/GiftUIFixedDiagnosticBuffer.swift) ;;
        *) files+=("${PROJECT_ROOT}/${path}") ;;
      esac
      ;;
  esac
done < <(git -C "${PROJECT_ROOT}" ls-files --cached --others --exclude-standard '*.swift')

if [[ ${#files[@]} -eq 0 ]]; then
  printf '%s\n' 'error: no maintained Swift files found' >&2
  exit 1
fi

if [[ "${mode}" == "lint" ]]; then
  swift format lint \
    --configuration "${CONFIGURATION}" \
    --strict \
    --parallel \
    --no-color-diagnostics \
    "${files[@]}"
else
  swift format format \
    --configuration "${CONFIGURATION}" \
    --in-place \
    --parallel \
    --no-color-diagnostics \
    "${files[@]}"
fi
