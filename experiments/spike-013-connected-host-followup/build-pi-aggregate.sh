#!/usr/bin/env bash
set -euo pipefail
# Run at repository root; reuse the supported build command and preserve its old artifact.
aggregate_root="$PWD/.build/raspberry-pi/spike-013/aggregate"
original_artifact="$PWD/.build/raspberry-pi/artifacts/SignalAnalyzerPiResearch"
cp "$original_artifact" "$aggregate_root/verbose-artifact-backup"
trap 'cp "$aggregate_root/verbose-artifact-backup" "$original_artifact"' EXIT
scripts/raspberry-pi/build.sh --package-path "$aggregate_root/package" --product SignalAnalyzerPiResearch
cp "$original_artifact" "$PWD/.build/raspberry-pi/artifacts/SignalAnalyzerPiAggregateResearch"
