cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

if(NOT DEFINED GIFTUI_SWIFT_TARGET)
    message(FATAL_ERROR "GIFTUI_SWIFT_TARGET must be supplied by scripts/nrf52840/build.sh")
endif()
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(GiftUIILI9486BringUp LANGUAGES C Swift)

target_sources(app PRIVATE src/ads7846.c src/ili9486.c src/main.c src/stubs.c)
target_include_directories(app PRIVATE include)

if(CONFIG_FP_HARDABI)
    set(giftui_swift_float_abi hard)
elseif(CONFIG_FP_SOFTABI)
    set(giftui_swift_float_abi soft)
else()
    message(FATAL_ERROR "Zephyr did not resolve an ARM float ABI")
endif()

get_target_property(zephyr_defines zephyr_interface INTERFACE_COMPILE_DEFINITIONS)
set(giftui_root "${CMAKE_CURRENT_SOURCE_DIR}/../../../..")
set(giftui_swift_module_dir "${CMAKE_CURRENT_BINARY_DIR}/swift-modules")

function(giftui_configure_swift_target target module_name)
    add_dependencies(${target} syscall_list_h_target)
    set_target_properties(${target} PROPERTIES
        Swift_MODULE_NAME "${module_name}"
        Swift_MODULE_DIRECTORY "${giftui_swift_module_dir}"
    )
    target_compile_options(${target} PRIVATE
        -parse-as-library
        -Osize
        -enable-experimental-feature Embedded
        -package-name GiftUI
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
            target_compile_options(${target} PRIVATE "SHELL:-Xcc ${flag}")
        endif()
    endforeach()
    if(zephyr_defines)
        foreach(flag ${zephyr_defines})
            string(FIND "${flag}" "$<" is_expression)
            if(is_expression EQUAL -1)
                target_compile_options(${target} PRIVATE "SHELL:-Xcc -D${flag}")
            endif()
        endforeach()
    endif()
    target_include_directories(${target} PRIVATE
        "${giftui_swift_module_dir}"
        "$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>"
    )
endfunction()

add_library(giftui_core OBJECT
    ${giftui_root}/Sources/GiftUI/GiftUI.swift
    ${giftui_root}/Sources/GiftUI/Geometry/Point.swift
    ${giftui_root}/Sources/GiftUI/Geometry/ProposedSize.swift
    ${giftui_root}/Sources/GiftUI/Geometry/Rect.swift
    ${giftui_root}/Sources/GiftUI/Geometry/Size.swift
    ${giftui_root}/Sources/GiftUI/Input/ActionID.swift
    ${giftui_root}/Sources/GiftUI/Input/HitRegion.swift
    ${giftui_root}/Sources/GiftUI/Input/InputEvent.swift
    ${giftui_root}/Sources/GiftUI/Layout/LayoutArithmetic.swift
    ${giftui_root}/Sources/GiftUI/Rendering/Color.swift
    ${giftui_root}/Sources/GiftUI/Rendering/RenderBackend.swift
    ${giftui_root}/Sources/GiftUI/Rendering/RenderOperation.swift
    ${giftui_root}/Sources/GiftUI/Rendering/RenderOperationSink.swift
    ${giftui_root}/Sources/GiftUI/Rendering/TextRun.swift
    ${giftui_root}/Sources/GiftUI/Runtime/RuntimeProfile.swift
    ${giftui_root}/Sources/GiftUI/View/PrimitiveView.swift
    ${giftui_root}/Sources/GiftUI/View/View.swift
    ${giftui_root}/Sources/GiftUI/View/ViewBuilder.swift
    ${giftui_root}/Sources/GiftUI/View/ViewVisitor.swift
    ${giftui_root}/Sources/GiftUI/Composition/ConditionalContent.swift
    ${giftui_root}/Sources/GiftUI/Composition/EmptyView.swift
    ${giftui_root}/Sources/GiftUI/Composition/OptionalContent.swift
    ${giftui_root}/Sources/GiftUI/Composition/TupleView.swift
    ${giftui_root}/Sources/GiftUI/Containers/HStack.swift
    ${giftui_root}/Sources/GiftUI/Containers/VStack.swift
    ${giftui_root}/Sources/GiftUI/PrimitiveViews/Button.swift
    ${giftui_root}/Sources/GiftUI/PrimitiveViews/Text.swift
)
giftui_configure_swift_target(giftui_core GiftUI)

add_library(giftui_builtin_font OBJECT
    ${giftui_root}/Sources/GiftUIBuiltinFont/BuiltinFont8x12.swift
    ${giftui_root}/Sources/GiftUIBuiltinFont/GiftUIBuiltinFont.swift
)
giftui_configure_swift_target(giftui_builtin_font GiftUIBuiltinFont)

add_library(giftui_runtime_static OBJECT
    ${giftui_root}/Sources/GiftUIRuntimeStatic/GiftUIRuntimeStatic.swift
    ${giftui_root}/Sources/GiftUIRuntimeStatic/StaticStateStorage.swift
    ${giftui_root}/Sources/GiftUIRuntimeStatic/StaticRuntime.swift
)
giftui_configure_swift_target(giftui_runtime_static GiftUIRuntimeStatic)
target_link_libraries(giftui_runtime_static PRIVATE giftui_core)

add_library(giftui_rgb565 OBJECT
    ${giftui_root}/Sources/GiftUIBackendRGB565/GiftUIBackendRGB565.swift
    ${giftui_root}/Sources/GiftUIBackendRGB565/RGB565Pixel.swift
    ${giftui_root}/Sources/GiftUIBackendRGB565/RGB565RendererConfiguration.swift
    ${giftui_root}/Sources/GiftUIBackendRGB565/RGB565TileRenderer.swift
    ${giftui_root}/Sources/GiftUIBackendRGB565/RGB565TileStorage.swift
)
giftui_configure_swift_target(giftui_rgb565 GiftUIBackendRGB565)
target_link_libraries(giftui_rgb565 PRIVATE giftui_core giftui_builtin_font)

add_library(giftui_thermostat_view OBJECT
    ${giftui_root}/Sources/GiftUIExampleThermostatPortableView/ThermostatModel.swift
    ${giftui_root}/Sources/GiftUIExampleThermostatPortableView/ThermostatPortableView.swift
)
giftui_configure_swift_target(
    giftui_thermostat_view
    GiftUIExampleThermostatPortableView
)
target_link_libraries(giftui_thermostat_view PRIVATE giftui_core)

add_library(app_swift OBJECT src/ILI9486BringUp.swift)
giftui_configure_swift_target(app_swift GiftUIILI9486BringUp)
target_link_libraries(app_swift PRIVATE
    giftui_core
    giftui_rgb565
    giftui_runtime_static
    giftui_thermostat_view
)

target_link_libraries(app PRIVATE
    app_swift
    giftui_builtin_font
    giftui_core
    giftui_rgb565
    giftui_runtime_static
    giftui_thermostat_view
)
set_target_properties(app PROPERTIES LINKER_LANGUAGE C)
