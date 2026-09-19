cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(GiftUISPEC003ResourceProbe LANGUAGES C)

if(NOT DEFINED GIFTUI_SPEC003_SWIFT_ARCHIVE)
    message(FATAL_ERROR "GIFTUI_SPEC003_SWIFT_ARCHIVE must be supplied by the SPEC-003 driver")
endif()
if(NOT CONFIG_FP_HARDABI)
    message(FATAL_ERROR "SPEC-003 requires the Cortex-M4F hard-float ABI")
endif()

set(giftui_project_root "${CMAKE_CURRENT_SOURCE_DIR}/../../../..")
target_sources(app PRIVATE
    "${giftui_project_root}/Tests/ContractFixtures/SPEC003/ResourceHarness/main.c"
    src/stubs.c
)

add_library(spec003_swift STATIC IMPORTED GLOBAL)
set_target_properties(spec003_swift PROPERTIES
    IMPORTED_LOCATION "${GIFTUI_SPEC003_SWIFT_ARCHIVE}"
)
target_link_libraries(app PRIVATE spec003_swift)
