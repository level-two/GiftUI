cmake_minimum_required(VERSION 3.29)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
set(CMAKE_Swift_COMPILER_TARGET "${GIFTUI_SWIFT_TARGET}")
set(CMAKE_Swift_COMPILER_WORKS TRUE CACHE BOOL "Embedded Swift cross-compiler" FORCE)
project(Spike002Candidate LANGUAGES C Swift)

set(SPIKE002_SWIFT_SOURCE "${CMAKE_CURRENT_LIST_DIR}/Candidate.swift")
set(SPIKE002_EXTRA_C_SOURCE "${CMAKE_CURRENT_LIST_DIR}/storage.c")
include("${CMAKE_CURRENT_LIST_DIR}/../common.cmake")
