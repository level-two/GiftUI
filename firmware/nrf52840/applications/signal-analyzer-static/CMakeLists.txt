cmake_minimum_required(VERSION 3.29)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

if(NOT DEFINED GIFTUI_SWIFT_TARGET)
    message(FATAL_ERROR "GIFTUI_SWIFT_TARGET must be supplied")
endif()
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(GiftUISignalAnalyzerStatic LANGUAGES C Swift)

set(giftui_project_root "${CMAKE_CURRENT_SOURCE_DIR}/../../../..")
find_program(GIFTUI_RUBY_EXECUTABLE ruby REQUIRED)
set(giftui_workload_generator
    "${giftui_project_root}/scripts/contracts/generate-spec-015-workload.rb")
set(giftui_workload_descriptor
    "${giftui_project_root}/Tests/ContractFixtures/SPEC015/signal-analyzer-workload.tsv")
set(giftui_hierarchy_descriptor
    "${giftui_project_root}/Tests/ContractFixtures/SPEC001/hierarchy-shape-cases.tsv")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
    "${giftui_workload_generator}"
    "${giftui_workload_descriptor}"
    "${giftui_hierarchy_descriptor}")
execute_process(
    COMMAND "${GIFTUI_RUBY_EXECUTABLE}" "${giftui_workload_generator}" --check
    WORKING_DIRECTORY "${giftui_project_root}"
    RESULT_VARIABLE giftui_generated_model_check
    OUTPUT_VARIABLE giftui_generated_model_output
    ERROR_VARIABLE giftui_generated_model_error)
if(NOT giftui_generated_model_check EQUAL 0)
    message(FATAL_ERROR
        "Signal Analyzer generated workload/model descriptor is stale:\n${giftui_generated_model_error}")
endif()
target_sources(app PRIVATE
    src/ads7846.c
    src/device_validation.c
    src/fault.c
    src/ili9486.c
    src/main.c
    src/static_input_bridge.c
    src/static_host_clock.c
    src/static_host_lifecycle.c
    src/static_host_scheduler.c
    src/static_touch_pipeline.c
    src/storage.c
    src/stubs.c
    src/touch_input.c
)
target_include_directories(app PRIVATE include)

set(giftui_static_swift_source "${CMAKE_CURRENT_BINARY_DIR}/SignalAnalyzerStatic.swift")
file(WRITE "${giftui_static_swift_source}" "")
set(giftui_static_swift_inputs
    "${giftui_project_root}/Sources/GiftUI/GiftUI.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/ExecutionValues.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/AdmissionValues.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/InputSourceSequenceState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalAnalyzerDiagnostic.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/AcquisitionState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalPrimitiveValues.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalCaptureChange.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostApplicationOpportunityGate.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostNormalizedInputGate.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInputCoordinator.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInputABI.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureStorage.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureRecord.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureSnapshotView.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelCaptureState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFRegionMap.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelLocation.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFModelDescriptor.generated.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticPreset.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticInputABI.swift"
)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
    ${giftui_static_swift_inputs})
foreach(source ${giftui_static_swift_inputs})
    file(READ "${source}" giftui_static_swift_fragment)
    string(REGEX REPLACE "(^|\n)import [A-Za-z0-9_]+\r?\n" "\\1"
        giftui_static_swift_fragment "${giftui_static_swift_fragment}")
    file(APPEND "${giftui_static_swift_source}"
        "${giftui_static_swift_fragment}\n")
endforeach()

add_library(app_swift OBJECT "${giftui_static_swift_source}")
add_dependencies(app_swift syscall_list_h_target)

if(NOT CONFIG_FP_HARDABI)
    message(FATAL_ERROR "Signal Analyzer Static requires Cortex-M4F hard-float")
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
