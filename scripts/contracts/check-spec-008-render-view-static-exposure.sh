#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
PROBE="$PROJECT_ROOT/Tests/ContractFixtures/SPEC008/Instrumentation/RenderViewBorrowProbe.swift"
TEMPORARY_DIRECTORY="$(mktemp -d)"
trap 'rm -rf "$TEMPORARY_DIRECTORY"' EXIT
export CLANG_MODULE_CACHE_PATH="$TEMPORARY_DIRECTORY/clang-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$TEMPORARY_DIRECTORY/swiftpm-module-cache"

swift build --disable-sandbox -c release --target GiftUIRenderLowering >/dev/null
BIN_PATH="$(swift build --disable-sandbox -c release --show-bin-path)"
COMPILER="$(xcrun --find swiftc)"
SDK="$(xcrun --sdk macosx --show-sdk-path)"
SIL="$TEMPORARY_DIRECTORY/render-view-borrow.sil"
IR="$TEMPORARY_DIRECTORY/render-view-borrow.ll"
LOWERING_SIL="$TEMPORARY_DIRECTORY/render-lowering.sil"

"$COMPILER" -O -whole-module-optimization -parse-as-library -package-name giftui \
    -target arm64-apple-macosx26.0 -sdk "$SDK" \
    -I "$BIN_PATH/Modules" -emit-sil "$PROBE" -o "$SIL"
"$COMPILER" -O -whole-module-optimization -parse-as-library -package-name giftui \
    -target arm64-apple-macosx26.0 -sdk "$SDK" \
    -I "$BIN_PATH/Modules" -emit-ir "$PROBE" -o "$IR"

BODY="$(sed -n '/spec008BorrowedRenderViews/,/^}/p' "$SIL")"
[[ -n "$BODY" ]] || {
    printf 'SPEC-008 render view static exposure failed: probe body is missing\n' >&2
    exit 1
}
if printf '%s\n' "$BODY" | grep -Eq '\b(alloc_ref|alloc_box|swift_allocObject)\b'; then
    printf 'SPEC-008 render view static exposure failed: heap allocation instruction found\n' >&2
    exit 1
fi
PRODUCTION_BODY="$(sed -n '/spec008StaticRenderProductionEntry/,/^}/p' "$SIL")"
[[ -n "$PRODUCTION_BODY" ]] || {
    printf 'SPEC-008 render view static exposure failed: production probe body is missing\n' >&2
    exit 1
}
if printf '%s\n' "$PRODUCTION_BODY" | grep -Eq '\b(alloc_ref|alloc_box|swift_allocObject)\b'; then
    printf 'SPEC-008 render view static exposure failed: production entry heap allocation instruction found\n' >&2
    exit 1
fi

"$COMPILER" -O -whole-module-optimization -parse-as-library -package-name giftui \
    -module-name GiftUIRenderLowering -target arm64-apple-macosx26.0 -sdk "$SDK" \
    -I "$BIN_PATH/Modules" -emit-sil \
    "$PROJECT_ROOT"/Sources/GiftUIRenderLowering/*.swift -o "$LOWERING_SIL"
if grep -Ev '^\s*//' "$LOWERING_SIL" | grep -Eq '\b(alloc_ref|alloc_box|swift_allocObject)\b'; then
    printf 'SPEC-008 render view static exposure failed: lowering module heap allocation instruction found\n' >&2
    exit 1
fi

"$SCRIPT_DIR/check-spec-008-render-view-boundaries.rb"
"$SCRIPT_DIR/check-spec-008-render-work.rb"
"$SCRIPT_DIR/check-spec-008-render-resource-ir.rb" "$IR"
printf 'SPEC-008 render view static exposure passed: borrowed views and concrete static production have zero optimized heap allocation instructions.\n'
