cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

if(NOT DEFINED GIFTUI_SWIFT_TARGET)
    message(FATAL_ERROR "GIFTUI_SWIFT_TARGET must be supplied by the SPEC-008 driver")
endif()
if(NOT DEFINED GIFTUI_SPEC008_CANDIDATE)
    message(FATAL_ERROR "GIFTUI_SPEC008_CANDIDATE must be supplied by the SPEC-008 driver")
endif()
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(GiftUISPEC008RenderProbe LANGUAGES C Swift)

target_sources(app PRIVATE src/main.c src/stubs.c)
add_library(app_swift OBJECT src/RenderProbe.swift)
add_dependencies(app_swift syscall_list_h_target)

if(CONFIG_FP_HARDABI)
    set(giftui_swift_float_abi hard)
else()
    message(FATAL_ERROR "SPEC-008 requires the Cortex-M4F hard-float ABI")
endif()

target_compile_options(app_swift PRIVATE
    -parse-as-library
    -Osize
    -package-name giftui
    -enable-experimental-feature Embedded
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=${giftui_swift_float_abi}"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -fno-pic"
    "SHELL:-Xcc -fno-pie"
    "SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include"
)
if(GIFTUI_SPEC008_CANDIDATE)
    if(NOT DEFINED GIFTUI_MODULE_DIR OR NOT DEFINED GIFTUI_PREBUILT_OBJECTS)
        message(FATAL_ERROR "candidate module directory and objects are required")
    endif()
    target_compile_options(app_swift PRIVATE
        -DGIFTUI_SPEC008_CANDIDATE
        "SHELL:-I ${GIFTUI_MODULE_DIR}"
    )
    set_source_files_properties(${GIFTUI_PREBUILT_OBJECTS}
        PROPERTIES EXTERNAL_OBJECT TRUE GENERATED TRUE)
    target_sources(app PRIVATE ${GIFTUI_PREBUILT_OBJECTS})
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
