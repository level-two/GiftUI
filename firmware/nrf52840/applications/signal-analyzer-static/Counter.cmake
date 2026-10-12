# The supported build boundary verifies every current source/object identity
# before this finite existing-application image branch is configured.
include("${GIFTUI_COUNTER_OBJECT_INPUTS}")
if(NOT giftui_counter_objects)
    message(FATAL_ERROR "Verified P08 counter objects are required")
endif()
set_source_files_properties(${giftui_counter_objects} PROPERTIES
    EXTERNAL_OBJECT TRUE GENERATED TRUE)
target_sources(app PRIVATE
    ${giftui_counter_objects}
    src/counter_main.c
    src/spi_tft.c
    src/fault.c
    src/stubs.c)
target_include_directories(app PRIVATE include)
