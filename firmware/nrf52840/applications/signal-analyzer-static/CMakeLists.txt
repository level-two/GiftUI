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
    src/spi_tft.c
    src/main.c
    src/production_host.c
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
    "${giftui_project_root}/Sources/GiftUIRasterCore/RasterPayloadLimits.swift"
    "${giftui_project_root}/Sources/GiftUIRasterCore/RasterFrameWork.swift"
    "${giftui_project_root}/Sources/GiftUIRasterCore/RasterWorkTracker.swift"
    "${giftui_project_root}/Sources/GiftUIRasterCore/RasterFrameSink.swift"
    "${giftui_project_root}/Sources/GiftUIFailureCore/GiftUIFailureCore.swift"
    "${giftui_project_root}/Sources/GiftUIDisplayCore/DisplayContracts.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDisplayTarget.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFSPITFTTransport.swift"
    "${giftui_project_root}/Sources/GiftUIBackendIntegration/OperationMajorTileTraversal.swift"
    "${giftui_project_root}/Sources/GiftUIBackendIntegration/RasterFrameWorkAdmission.swift"
    "${giftui_project_root}/Sources/GiftUIBackendIntegration/RGB565TilePayloadEmitter.swift"
    "${giftui_project_root}/Sources/GiftUIBackendIntegration/OperationMajorRGB565RasterSession.swift"
    "${giftui_project_root}/Sources/GiftUIBackendIntegration/RasterBackendEndpoint.swift"
    "${giftui_project_root}/Sources/GiftUIBackendIntegration/OneShotRasterBackendEndpoint.swift"
    "${giftui_reference_bitmap}"
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
    "${giftui_project_root}/Sources/GiftUIExecution/IdentityAllocators.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/PointerActionCapture.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/FrameHandoffValues.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/AdmissionValues.swift"
    "${giftui_project_root}/Sources/GiftUIInteraction/InteractionValues.swift"
    "${giftui_project_root}/Sources/GiftUIInteraction/InteractionStorage.swift"
    "${giftui_project_root}/Sources/GiftUIInteraction/InteractionState.swift"
    "${giftui_project_root}/Sources/GiftUIInteraction/ExecutionGestureAdapter.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/RunCycleValues.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/WakeValues.swift"
    "${giftui_project_root}/Sources/GiftUIRuntimeCore/RuntimeOwnerFailure.swift"
    "${giftui_project_root}/Sources/GiftUIRuntimeCore/RuntimeCompletePipeline.swift"
    "${giftui_project_root}/Sources/GiftUIRuntimeCore/RuntimeCoordinatorCleanup.swift"
    "${giftui_project_root}/Sources/GiftUIRuntimeCore/RuntimeInteractionCandidateCoordinator.swift"
    "${giftui_project_root}/Sources/GiftUIRuntimeCore/RuntimeInteractionCandidateTransaction.swift"
    "${giftui_project_root}/Sources/GiftUIRuntimeCore/RuntimeFocusedFailureState.swift"
    "${giftui_project_root}/Sources/GiftUIObservableState/ObservableStateProtocols.swift"
    "${giftui_project_root}/Sources/GiftUIObservableState/ObservableStateValues.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleOwnerFailure.swift"
    "${giftui_project_root}/Sources/GiftUIRuntimeStatic/StaticInteractionStorage.swift"
    "${giftui_project_root}/Sources/GiftUIExecution/InputSourceSequenceState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalAnalyzerDiagnostic.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/AcquisitionState.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalPrimitiveValues.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerDomain/SignalCaptureChange.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerData/DeterministicSignalGenerator.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostResidualPolicyContracts.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostResidualPolicyTableValidation.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostResidualFailureRouting.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostPresentationRecovery.swift"
    "${giftui_project_root}/Sources/GiftUIHostConfiguration/HostEndpointHealthController.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerPresentation/SignalAnalyzerRuntimeFailureNormalizer.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerPresentation/SignalAnalyzerFailurePolicyValues.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerPresentation/SignalAnalyzerRuntimeFailureRule.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleFailureNormalizer.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleResidualPolicyOwner.swift"
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
    "${giftui_project_root}/Sources/SignalAnalyzerPresentation/SignalAnalyzerRuntimeCondition.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerPresentation/SignalAnalyzerLayoutConstraints.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerPresentation/SignalAnalyzerTimelineFormatting.swift"
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
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFInteractionTargetProjection.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedInteractionOwner.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedGestureSession.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedInputHandler.swift"
    "${giftui_project_root}/Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedActionDispatcher.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticPreset.swift"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticInputABI.swift"
)
list(APPEND giftui_static_swift_inputs
    "${giftui_project_root}/Sources/GiftUI/ActionHandler.swift"
    "${giftui_project_root}/Sources/GiftUI/BoundedText.swift"
    "${giftui_project_root}/Sources/GiftUI/Button.swift"
    "${giftui_project_root}/Sources/GiftUI/Canvas.swift"
    "${giftui_project_root}/Sources/GiftUI/DeclarativeView.swift"
    "${giftui_project_root}/Sources/GiftUI/Disabled.swift"
    "${giftui_project_root}/Sources/GiftUI/LayoutContainers.swift"
    "${giftui_project_root}/Sources/GiftUI/LayoutModifiers.swift"
    "${giftui_project_root}/Sources/GiftUI/ObservableState.swift"
    "${giftui_project_root}/Sources/GiftUI/StyleModifiers.swift"
    "${giftui_project_root}/Sources/GiftUI/Text.swift"
    "${giftui_project_root}/Sources/GiftUISemanticCore/GiftUISemanticCore.swift"
    "${giftui_project_root}/Sources/GiftUISemanticCore/SemanticLayoutView.swift"
    "${giftui_project_root}/Sources/GiftUITextResources/GiftUITextResources.swift"
    "${giftui_project_root}/Sources/GiftUILayout/Layout.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutPublication.swift"
    "${giftui_project_root}/Sources/GiftUILayout/LayoutResultSink.swift"
    "${giftui_project_root}/Sources/GiftUIReferenceTextResources/GiftUIReferenceTextResources.swift"
    "${giftui_project_root}/Sources/GiftUIReferenceTextResources/Generated/ReferenceCatalogue.generated.swift"
)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
    ${giftui_static_swift_inputs})
# Compile selected sources in their owning modules. Only composition-root
# fragments are combined; cross-owner imports are retained and checked.
set(giftui_swift_owners "")
foreach(source ${giftui_static_swift_inputs})
    if(source MATCHES "/Sources/([A-Za-z0-9_]+)/")
        set(owner "${CMAKE_MATCH_1}")
    else()
        set(owner SignalAnalyzerTargetHost)
    endif()
    if(owner STREQUAL SignalAnalyzerTargetHost)
        file(READ "${source}" fragment)
        file(APPEND "${giftui_static_swift_source}" "${fragment}\n")
    else()
        list(APPEND giftui_sources_${owner} "${source}")
        list(APPEND giftui_swift_owners "${owner}")
    endif()
endforeach()
list(REMOVE_DUPLICATES giftui_swift_owners)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/swift-owner-sources.tsv" "owner\tsource\n")
foreach(owner ${giftui_swift_owners})
    # One WMO translation unit per owner avoids redundant Embedded runtime
    # partitions while retaining a distinct module and its checked imports.
    set(owner_source "${CMAKE_CURRENT_BINARY_DIR}/${owner}.swift")
    file(WRITE "${owner_source}" "")
    foreach(source ${giftui_sources_${owner}})
        file(READ "${source}" fragment)
        file(APPEND "${owner_source}" "${fragment}\n")
    endforeach()
    add_library(giftui_${owner} OBJECT "${owner_source}")
    set_target_properties(giftui_${owner} PROPERTIES
        Swift_MODULE_NAME "${owner}"
        Swift_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/swift-modules/${owner}")
    foreach(source ${giftui_sources_${owner}})
        file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/swift-owner-sources.tsv" "${owner}\t${source}\n")
    endforeach()
    target_sources(app PRIVATE $<TARGET_OBJECTS:giftui_${owner}>)
endforeach()
# The host composes every selected owner; lower owners can see only their
# declared imports. A module directory is never shared across owner closures.
set(host_imports "")
foreach(owner ${giftui_swift_owners})
    string(APPEND host_imports "import ${owner}\n")
endforeach()
file(READ "${giftui_static_swift_source}" host_fragments)
file(WRITE "${giftui_static_swift_source}" "${host_imports}\n${host_fragments}")
add_library(app_swift OBJECT "${giftui_static_swift_source}")
set_target_properties(app_swift PROPERTIES Swift_MODULE_NAME SignalAnalyzerTargetHost)
add_dependencies(app_swift syscall_list_h_target)
foreach(owner ${giftui_swift_owners})
    add_dependencies(app_swift giftui_${owner})
    target_compile_options(app_swift PRIVATE "-I${CMAKE_CURRENT_BINARY_DIR}/swift-modules/${owner}")
    set(owner_imports "")
    foreach(source ${giftui_sources_${owner}})
        file(STRINGS "${source}" import_lines REGEX "^import [A-Za-z0-9_]+$")
        foreach(line ${import_lines})
            string(REGEX REPLACE "^import " "" dependency "${line}")
            list(APPEND owner_imports "${dependency}")
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES owner_imports)
    set(giftui_imports_${owner} ${owner_imports})
    foreach(dependency ${owner_imports})
        if(NOT TARGET giftui_${dependency})
            message(FATAL_ERROR "Selected ${owner} imports unavailable owner ${dependency}")
        endif()
        add_dependencies(giftui_${owner} giftui_${dependency})
        target_compile_options(giftui_${owner} PRIVATE "-I${CMAKE_CURRENT_BINARY_DIR}/swift-modules/${dependency}")
    endforeach()
endforeach()

# Swift's serialized modules also need their transitive lower-owner modules
# available for deserialization. No sibling/higher owner directories are added.
foreach(owner ${giftui_swift_owners})
    set(pending_imports ${giftui_imports_${owner}})
    set(visible_imports "")
    while(pending_imports)
        list(POP_FRONT pending_imports dependency)
        if(NOT dependency IN_LIST visible_imports)
            list(APPEND visible_imports "${dependency}")
            list(APPEND pending_imports ${giftui_imports_${dependency}})
            add_dependencies(giftui_${owner} giftui_${dependency})
            target_compile_options(giftui_${owner} PRIVATE
                "-I${CMAKE_CURRENT_BINARY_DIR}/swift-modules/${dependency}")
        endif()
    endwhile()
endforeach()

if(NOT CONFIG_FP_HARDABI)
    message(FATAL_ERROR "Signal Analyzer Static requires Cortex-M4F hard-float")
endif()

set(giftui_swift_compile_flags
    -parse-as-library -Osize -package-name GiftUI -DGIFTUI_NRF_EMBEDDED
    -enable-experimental-feature Embedded
    "SHELL:-Xfrontend -function-sections"
    "SHELL:-Xfrontend -disable-stack-protector"
    "SHELL:-Xcc -mfloat-abi=hard"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -fno-pic"
    "SHELL:-Xcc -fno-pie"
    "SHELL:-Xcc -I -Xcc ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/picolibc/include"
)

foreach(swift_target app_swift ${giftui_swift_owners})
    if(NOT swift_target STREQUAL app_swift)
        set(swift_target giftui_${swift_target})
    endif()
    target_compile_options(${swift_target} PRIVATE ${giftui_swift_compile_flags}
        -DGIFTUI_REFERENCE_BITMAP_ONLY)
endforeach()

foreach(flag ${TOOLCHAIN_C_FLAGS})
    string(FIND "${flag}" "-imacro" is_imacro)
    string(FIND "${flag}" "-mfp16-format" is_mfp16)
    string(FIND "${flag}" "--sysroot" is_sysroot)
    if(is_imacro EQUAL -1 AND is_mfp16 EQUAL -1 AND is_sysroot EQUAL -1)
        target_compile_options(app_swift PRIVATE "SHELL:-Xcc ${flag}")
        foreach(owner ${giftui_swift_owners})
            target_compile_options(giftui_${owner} PRIVATE "SHELL:-Xcc ${flag}")
        endforeach()
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
