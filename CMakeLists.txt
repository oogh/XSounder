cmake_minimum_required(VERSION 3.4.1)

project(XSound CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(LibraryName "coresound")
add_definitions("-DANDROID")

set(DIR_SOURCE ./coresound)

# 添加头文件目录
include_directories(${DIR_SOURCE})

# 添加源码目录
aux_source_directory(${DIR_SOURCE} SRC_CORE)
aux_source_directory(${DIR_SOURCE}/Android SRC_CORE_ANDROID)

SET(SRC_MEDIA ${SRC_CORE} ${SRC_CORE_ANDROID})

# 生成链接库
add_library(${LibraryName}
            SHARED
            ${SRC_MEDIA})

find_library(
        log-lib
        log)

find_library(
        android
        android)

find_library(
        open-sl
        OpenSLES)

SET(EXTRAL_LIBRARY
        ${log-lib}
        ${open-sl}
        ${android})

# 添加链接库
target_link_libraries(${LibraryName}
        ${EXTRAL_LIBRARY})
