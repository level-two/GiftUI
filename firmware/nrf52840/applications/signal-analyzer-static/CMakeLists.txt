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
set(giftui_nrf_font_generator
    "${giftui_project_root}/scripts/contracts/generate-spec-001-nrf-font.rb")
set(giftui_nrf_canvas_generator
    "${giftui_project_root}/scripts/contracts/generate-spec-001-nrf-canvas-table.rb")
set(giftui_nrf_canvas_manifest
    "${giftui_project_root}/Tests/ContractFixtures/SPEC001/nrf-static-canvas-manifest.yaml")
set(giftui_reference_catalogue
    "${giftui_project_root}/Sources/GiftUIReferenceTextResources/Generated/ReferenceCatalogue.generated.swift")
set(giftui_reference_bitmap
    "${giftui_project_root}/Sources/GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
    "${giftui_workload_generator}"
    "${giftui_workload_descriptor}"
    "${giftui_hierarchy_descriptor}"
    "${giftui_nrf_font_generator}"
    "${giftui_nrf_canvas_generator}"
    "${giftui_nrf_canvas_manifest}"
    "${giftui_reference_catalogue}"
    "${giftui_reference_bitmap}")
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
execute_process(
    COMMAND "${GIFTUI_RUBY_EXECUTABLE}" "${giftui_nrf_font_generator}" --check
    WORKING_DIRECTORY "${giftui_project_root}"
    RESULT_VARIABLE giftui_nrf_font_check
    ERROR_VARIABLE giftui_nrf_font_error)
if(NOT giftui_nrf_font_check EQUAL 0)
    message(FATAL_ERROR "nRF reference font projection is stale:\n${giftui_nrf_font_error}")
endif()
execute_process(
    COMMAND "${GIFTUI_RUBY_EXECUTABLE}" "${giftui_nrf_canvas_generator}" --check
    WORKING_DIRECTORY "${giftui_project_root}"
    RESULT_VARIABLE giftui_nrf_canvas_check
    ERROR_VARIABLE giftui_nrf_canvas_error)
if(NOT giftui_nrf_canvas_check EQUAL 0)
    message(FATAL_ERROR "nRF Canvas target table is stale:\n${giftui_nrf_canvas_error}")
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
    "${giftui_project_root}/Sources/GiftUI/LayoutValues.swift"
    "${giftui_project_root}/Sources/GiftUI/Color.swift"
    "${giftui_project_root}/Sources/GiftUICapabilities/GiftUICapabilities.swift"
    "${giftui_project_root}/Sources/GiftUISurfaceCore/SurfaceValues.swift"
    "${giftui_project_root}/Sources/GiftUIRasterCore/RGB565TileWorkspace.swift"
    "${giftui_project_root}/Sources/GiftUIRasterCore/RasterFillCoverage.swift"
    "${giftui_project_root}/Sources/GiftUIRasterCore/RasterStrokeCoverage.swift"
    "${giftui_project_root}/Sources/GiftUIRasterCore/RasterGlyphCoverage.swift"
    "${giftui_project_root}/Sources/GiftUIFailureCore/GiftUIFailureCore.swift"
    "${giftui_project_root}/Sources/GiftUIDisplayCore/DisplayContracts.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDisplayTarget.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFILI9486Transport.swift"
    "${giftui_project_root}/Sources/GiftUIBackendIntegration/OperationMajorTileTraversal.swift"
    "${giftui_reference_bitmap}"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedFontRaster.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFTileStorage.swift"
    "${giftui_project_root}/Sources/GiftUI/DrawingStyles.swift"
    "${giftui_project_root}/Sources/GiftUI/DrawingSurface.swift"
    "${giftui_project_root}/Sources/GiftUIRenderCore/DrawingOperationSink.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/DrawingValues.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/DrawingLimits.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/DrawingPlan.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/PathConstruction.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/StrokeSnapshot.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/CanvasInvocationSource.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/CanvasPlanProducer.swift"
    "${giftui_project_root}/Sources/GiftUIDrawing/CanvasRenderProducer.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFLivePathStorage.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDrawingPlanRecords.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDrawingPlanStorage.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDrawingWorkspace.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedCanvasSource.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedCanvasPayload.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFEmbeddedCanvasTable.generated.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutInterfaces.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutAdapters.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCommonLayoutWorkspace.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCommonLayoutPass.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutError.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutValues.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutCounters.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutWorkspace.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutGeometry.swift"
    "${giftui_project_root}/Sources/GiftUILayout/ResolvedRenderLayoutView.swift"
    "${giftui_project_root}/Sources/GiftUISemanticCore/SemanticRenderView.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter.swift"
    "${giftui_project_root}/Sources/GiftUIRenderCore/RenderValues.swift"
    "${giftui_project_root}/Sources/GiftUIRenderCore/RenderOperationSink.swift"
    "${giftui_project_root}/Sources/GiftUIRenderLowering/RenderProductionValues.swift"
    "${giftui_project_root}/Sources/GiftUIRenderLowering/RenderExtensions.swift"
    "${giftui_project_root}/Sources/GiftUIRenderLowering/RenderPreflight.swift"
    "${giftui_project_root}/Sources/GiftUIRenderLowering/RenderStreaming.swift"
    "${giftui_project_root}/Sources/GiftUIRenderLowering/RenderProducer.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFRenderWorkspace.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedCountingSink.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedRasterSink.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedTileRuns.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedRenderPreflight.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutSemanticValidation.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutEngine.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/ExecutionValues.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/AdmissionValues.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/InputSourceSequenceState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalAnalyzerDiagnostic.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/AcquisitionState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalPrimitiveValues.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalCaptureChange.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerData/DeterministicSignalGenerator.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostApplicationOpportunityGate.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostNormalizedInputGate.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInputCoordinator.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInputABI.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureStorage.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureHistory.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDeterministicSource.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFRepositoryProducer.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureRecord.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCompactCaptureFact.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCompactPresentationFact.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFOperationalFailureFact.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCompactFactRing.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureFactAdmission.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFSealedFactApplication.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureSnapshotView.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFSnapshotFact.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelCaptureState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFRegionMap.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelLocation.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFModelDescriptor.generated.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFReferenceMetrics.generated.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFPackedSemanticRecords.generated.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFTopologyWriter.generated.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFUTF8TextPool.generated.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelTextWriter.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelModifierWriter.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedSemanticValidator.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedSemanticRegion.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedSemanticView.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutPrimitive.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutModifier.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedTextMeasure.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedTextPlace.swift"
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
    -parse-as-library -Osize -package-name GiftUI -D GIFTUI_NRF_EMBEDDED
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
