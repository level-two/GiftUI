cmake_minimum_required(VERSION 3.29)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(Spike008Spec012Declarations LANGUAGES C Swift)

if(NOT DEFINED SPIKE008_SWIFT_SOURCE)
    set(SPIKE008_SWIFT_SOURCE "${CMAKE_CURRENT_LIST_DIR}/Candidate.swift")
endif()

set(CMAKE_Swift_COMPILATION_MODE wholemodule)
target_sources(app PRIVATE
    "${CMAKE_CURRENT_LIST_DIR}/heap_disabled.c"
    "${CMAKE_CURRENT_LIST_DIR}/main.c"
)

add_library(app_swift OBJECT
    "${SPIKE008_SWIFT_SOURCE}"
    ${SPIKE008_EXTRA_SWIFT_SOURCES}
)
add_dependencies(app_swift syscall_list_h_target)

if(CONFIG_FP_HARDABI)
    set(spike008_float_abi hard)
elseif(CONFIG_FP_SOFTABI)
    set(spike008_float_abi soft)
else()
    message(FATAL_ERROR "Zephyr did not resolve an ARM float ABI")
endif()

target_compile_options(app_swift PRIVATE
    -parse-as-library
    -Osize
    -enable-experimental-feature Embedded
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=${spike008_float_abi}"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -fno-pic"
    "SHELL:-Xcc -fno-pie"
    "SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include"
)

if(SPIKE008_EXACT_CALLABLE)
    target_compile_options(app_swift PRIVATE -DSPIKE008_EXACT_CALLABLE)
endif()

if(SPIKE008_NO_THROW_VALUES)
    target_compile_options(app_swift PRIVATE -DSPIKE008_NO_THROW_VALUES)
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
