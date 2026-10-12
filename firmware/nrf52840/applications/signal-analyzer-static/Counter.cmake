# The supported boundary verifies the exact current source recipe first.
# Every owner, including base GiftUI, receives fresh firmware-specific objects.
include("${GIFTUI_COUNTER_SOURCE_INPUTS}")
# Preserve statically resolved Embedded Swift runtime-function references in ROM.
zephyr_linker_sources(RODATA counter_got.ld)
if(NOT giftui_counter_owners OR NOT CONFIG_FP_HARDABI)
    message(FATAL_ERROR "Verified P08 owners and Cortex-M4F hard-float are required")
endif()
set(giftui_counter_flags
    -parse-as-library -Osize -swift-version 6 -package-name giftui -enable-testing -disable-sandbox
    -DGIFTUI_NRF_EMBEDDED -DGIFTUI_REFERENCE_BITMAP_ONLY -DGIFTUI_COUNTER_TILED
    "SHELL:-enable-experimental-feature Embedded"
    "SHELL:-enable-experimental-feature LifetimeDependence"
    "SHELL:-enable-experimental-feature Lifetimes"
    "SHELL:-module-cache-path ${CMAKE_CURRENT_BINARY_DIR}/swift-cache"
    "SHELL:-load-plugin-executable ${giftui_counter_macro}"
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=hard"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -fno-pic"
    "SHELL:-Xcc -fno-pie"
    "SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include")
foreach(owner ${giftui_counter_owners})
    add_library(giftui_counter_${owner} OBJECT ${giftui_counter_sources_${owner}})
    set_target_properties(giftui_counter_${owner} PROPERTIES
        Swift_MODULE_NAME ${owner}
        Swift_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/swift-modules/${owner}")
    target_compile_options(giftui_counter_${owner} PRIVATE ${giftui_counter_flags})
    add_dependencies(giftui_counter_${owner} syscall_list_h_target)
    foreach(flag ${TOOLCHAIN_C_FLAGS})
        string(FIND "${flag}" "-imacro" is_imacro)
        string(FIND "${flag}" "-mfp16-format" is_mfp16)
        string(FIND "${flag}" "--sysroot" is_sysroot)
        if(is_imacro EQUAL -1 AND is_mfp16 EQUAL -1 AND is_sysroot EQUAL -1)
            target_compile_options(giftui_counter_${owner} PRIVATE "SHELL:-Xcc ${flag}")
        endif()
    endforeach()
    target_sources(app PRIVATE $<TARGET_OBJECTS:giftui_counter_${owner}>)
endforeach()
# Only direct and transitive lower-owner modules are visible, as in the
# supported application recipe. Source lists and imports remain separate.
foreach(owner ${giftui_counter_owners})
    set(pending_imports ${giftui_counter_imports_${owner}})
    set(visible_imports "")
    while(pending_imports)
        list(POP_FRONT pending_imports dependency)
        if(NOT dependency IN_LIST visible_imports)
            list(APPEND visible_imports "${dependency}")
            list(APPEND pending_imports ${giftui_counter_imports_${dependency}})
            add_dependencies(giftui_counter_${owner} giftui_counter_${dependency})
            target_compile_options(giftui_counter_${owner} PRIVATE
                "-I${CMAKE_CURRENT_BINARY_DIR}/swift-modules/${dependency}")
        endif()
    endwhile()
endforeach()
get_target_property(zephyr_defines zephyr_interface INTERFACE_COMPILE_DEFINITIONS)
foreach(flag ${zephyr_defines})
    string(FIND "${flag}" "$<" is_expression)
    if(is_expression EQUAL -1 AND zephyr_defines)
        target_compile_options(giftui_counter_P08CounterRuntime PRIVATE "SHELL:-Xcc -D${flag}")
    endif()
endforeach()
target_sources(app PRIVATE src/counter_main.c src/spi_tft.c src/fault.c src/stubs.c)
target_include_directories(app PRIVATE include)
set_target_properties(app PROPERTIES LINKER_LANGUAGE C)
