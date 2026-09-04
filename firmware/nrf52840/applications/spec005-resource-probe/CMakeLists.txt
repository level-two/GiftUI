cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
if(NOT DEFINED GIFTUI_SWIFT_TARGET)
    message(FATAL_ERROR "GIFTUI_SWIFT_TARGET must be supplied by the SPEC-005 driver")
endif()
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(GiftUISPEC005ResourceProbe LANGUAGES C Swift)

set(giftui_project_root "${CMAKE_CURRENT_SOURCE_DIR}/../../../..")
target_sources(app PRIVATE
    "${giftui_project_root}/Tests/ContractFixtures/SPEC005/ResourceHarness/main.c"
    src/stubs.c
)

set(giftui_combined_source "${CMAKE_CURRENT_BINARY_DIR}/SPEC005ResourceProbe.swift")
file(READ "${giftui_project_root}/Sources/GiftUI/GiftUI.swift" giftui_foundation_source)
set(giftui_swift_source "${giftui_foundation_source}")
if(NOT DEFINED GIFTUI_SPEC005_CANDIDATE OR GIFTUI_SPEC005_CANDIDATE)
    foreach(source IN ITEMS
        Sources/GiftUITextResources/GiftUITextResources.swift
        Sources/GiftUIReferenceTextResources/Generated/ReferenceCatalogue.generated.swift
        Sources/GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift
        Sources/GiftUIReferenceTextResources/GiftUIReferenceTextResources.swift
    )
        file(READ "${giftui_project_root}/${source}" source_contents)
        string(REGEX REPLACE "(^|\n)import (GiftUI|GiftUITextResources)\n" "\\1"
            source_contents "${source_contents}")
        string(APPEND giftui_swift_source "\n${source_contents}")
    endforeach()
endif()
file(READ
    "${giftui_project_root}/Tests/ContractFixtures/SPEC005/ResourceHarness/ResourceProbe.swift"
    giftui_probe_source)
string(APPEND giftui_swift_source "\n${giftui_probe_source}")
file(WRITE "${giftui_combined_source}" "${giftui_swift_source}")

add_library(app_swift OBJECT "${giftui_combined_source}")
add_dependencies(app_swift syscall_list_h_target)
if(NOT CONFIG_FP_HARDABI)
    message(FATAL_ERROR "SPEC-005 requires the Cortex-M4F hard-float ABI")
endif()
target_compile_options(app_swift PRIVATE
    -parse-as-library -Osize -package-name GiftUI
    -enable-experimental-feature Embedded
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=hard"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -fno-pic"
    "SHELL:-Xcc -fno-pie"
    "SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include"
)
if(NOT DEFINED GIFTUI_SPEC005_CANDIDATE OR GIFTUI_SPEC005_CANDIDATE)
    target_compile_options(app_swift PRIVATE
        -DGIFTUI_SPEC005_CANDIDATE -DGIFTUI_REFERENCE_BITMAP_ONLY)
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
