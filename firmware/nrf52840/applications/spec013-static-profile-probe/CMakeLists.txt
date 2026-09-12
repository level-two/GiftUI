cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

if(NOT DEFINED GIFTUI_SWIFT_TARGET OR NOT DEFINED GIFTUI_MODULE_DIR OR
   NOT DEFINED GIFTUI_PREBUILT_OBJECTS)
    message(FATAL_ERROR "SPEC-013 module directory, objects, and Swift target are required")
endif()

set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(GiftUISPEC013StaticProfileProbe LANGUAGES C Swift)

target_sources(app PRIVATE src/main.c src/stubs.c)
add_library(app_swift OBJECT src/RuntimeProbe.swift)
add_dependencies(app_swift syscall_list_h_target)

if(NOT CONFIG_FP_HARDABI)
    message(FATAL_ERROR "SPEC-013 requires the Cortex-M4F hard-float ABI")
endif()

target_compile_options(app_swift PRIVATE
    -parse-as-library -Osize -package-name GiftUI
    -enable-experimental-feature Embedded
    "SHELL:-I ${GIFTUI_MODULE_DIR}"
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=hard"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -fno-pic"
    "SHELL:-Xcc -fno-pie"
    "SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include"
)

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

set_source_files_properties(${GIFTUI_PREBUILT_OBJECTS}
    PROPERTIES EXTERNAL_OBJECT TRUE GENERATED TRUE)
target_sources(app PRIVATE ${GIFTUI_PREBUILT_OBJECTS})
target_include_directories(app_swift PRIVATE "$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>")
target_link_libraries(app PRIVATE app_swift)
set_target_properties(app PROPERTIES LINKER_LANGUAGE C)
