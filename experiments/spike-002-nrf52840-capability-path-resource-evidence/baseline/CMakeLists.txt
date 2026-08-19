cmake_minimum_required(VERSION 3.29)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(Spike002Baseline LANGUAGES C Swift)

set(SPIKE002_SWIFT_SOURCE "${CMAKE_CURRENT_LIST_DIR}/Baseline.swift")
include("${CMAKE_CURRENT_LIST_DIR}/../common.cmake")
