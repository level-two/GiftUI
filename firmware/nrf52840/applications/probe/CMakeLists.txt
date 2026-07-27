cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

if(NOT DEFINED GIFTUI_SWIFT_TARGET)
    message(FATAL_ERROR "GIFTUI_SWIFT_TARGET must be supplied by scripts/nrf52840/build.sh")
endif()
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
# CMake's generic compiler test omits Embedded Swift mode and cannot link a
# freestanding Zephyr executable. The real app_swift object below is the probe.
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(GiftUINRF52840Probe LANGUAGES C Swift)

target_sources(app PRIVATE src/main.c src/stubs.c)

add_library(app_swift OBJECT src/Probe.swift)
add_dependencies(app_swift syscall_list_h_target)

if(CONFIG_FP_HARDABI)
    set(giftui_swift_float_abi hard)
elseif(CONFIG_FP_SOFTABI)
    set(giftui_swift_float_abi soft)
else()
    message(FATAL_ERROR "Zephyr did not resolve an ARM float ABI")
endif()

target_compile_options(app_swift PRIVATE
    -parse-as-library
    -Osize
    -enable-experimental-feature Embedded
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=${giftui_swift_float_abi}"
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

target_include_directories(app_swift PRIVATE "$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>")
target_link_libraries(app PRIVATE app_swift)
# On macOS, CMake otherwise selects Apple's Swift archive driver for `app`,
# which cannot archive ELF objects. Zephyr's ARM C toolchain must own the link.
set_target_properties(app PROPERTIES LINKER_LANGUAGE C)
