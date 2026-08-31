cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
if(NOT DEFINED GIFTUI_SWIFT_TARGET)
    message(FATAL_ERROR "GIFTUI_SWIFT_TARGET must be supplied by the SPEC-004 driver")
endif()
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(GiftUISPEC004ResourceProbe LANGUAGES C Swift)

set(giftui_project_root "${CMAKE_CURRENT_SOURCE_DIR}/../../../..")
target_sources(app PRIVATE
    "${giftui_project_root}/Tests/ContractFixtures/SPEC004/ResourceHarness/main.c"
    src/stubs.c
)
set(giftui_swift_sources
    "${giftui_project_root}/Tests/ContractFixtures/SPEC004/ResourceHarness/ResourceProbe.swift"
)
if(NOT DEFINED GIFTUI_SPEC004_CANDIDATE OR GIFTUI_SPEC004_CANDIDATE)
    file(READ "${giftui_project_root}/Sources/GiftUICapabilities/GiftUICapabilities.swift"
        giftui_capability_source)
    file(READ "${giftui_project_root}/Tests/ContractFixtures/SPEC004/ResourceHarness/ResourceProbe.swift"
        giftui_resource_probe_source)
    set(giftui_combined_source "${CMAKE_CURRENT_BINARY_DIR}/SPEC004Candidate.swift")
    file(WRITE "${giftui_combined_source}"
        "${giftui_capability_source}\n${giftui_resource_probe_source}")
    set(giftui_swift_sources "${giftui_combined_source}")
endif()
add_library(app_swift OBJECT ${giftui_swift_sources})
add_dependencies(app_swift syscall_list_h_target)

if(NOT CONFIG_FP_HARDABI)
    message(FATAL_ERROR "SPEC-004 requires the Cortex-M4F hard-float ABI")
endif()
target_compile_options(app_swift PRIVATE
    -parse-as-library -Osize
    -enable-experimental-feature Embedded
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=hard"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -fno-pic"
    "SHELL:-Xcc -fno-pie"
    "SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include"
)
if(NOT DEFINED GIFTUI_SPEC004_CANDIDATE OR GIFTUI_SPEC004_CANDIDATE)
    target_compile_options(app_swift PRIVATE -DGIFTUI_SPEC004_CANDIDATE)
endif()
foreach(flag ${TOOLCHAIN_C_FLAGS})
    string(FIND "${flag}" "-imacro" is_imacro)
    string(FIND "${flag}" "-mfp16-format" is_mfp16)
    string(FIND "${flag}" "--sysroot" is_sysroot)
    if(is_imacro EQUAL -1 AND is_mfp16 EQUAL -1 AND is_sysroot EQUAL -1)
        target_compile_options(app_swift PRIVATE "SHELL:-Xcc ${flag}")
    endif()
endforeach()
get_target_property(zephyr_defines zephyr_interface INTERFACE_COMPILE_DEFINITIONS)
if(zephyr_defines)
    foreach(flag ${zephyr_defines})
        string(FIND "${flag}" "$<" is_expression)
        if(is_expression EQUAL -1)
            target_compile_options(app_swift PRIVATE "SHELL:-Xcc -D${flag}")
        endif()
    endforeach()
endif()
target_include_directories(app_swift PRIVATE "$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>")
target_link_libraries(app PRIVATE app_swift)
set_target_properties(app PROPERTIES LINKER_LANGUAGE C)
