cmake_minimum_required(VERSION 3.29)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(Spike005Candidate LANGUAGES C)
target_sources(app PRIVATE
    main.c
    validator.c
    ${CMAKE_CURRENT_LIST_DIR}/../../generated/nrf-resource-data.c
)
target_include_directories(app PRIVATE ${CMAKE_CURRENT_LIST_DIR}/../../generated)
target_compile_options(app PRIVATE -fstack-usage)
