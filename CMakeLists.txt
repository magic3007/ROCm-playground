cmake_minimum_required(VERSION 3.14)

project(DREAMPlace LANGUAGES CXX)
set(CMAKE_VERBOSE_MAKEFILE ON)

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/install" CACHE PATH "Prefix prepended to install directories" FORCE )
endif()
message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING
        "Choose the type of build, options are: Debug Release."
        FORCE)
endif(NOT CMAKE_BUILD_TYPE)
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

# This is a dirty fix for CMake on some machines that generates default CXX standard and override the custom settings,
# because CUDA does not support C++17 and higher.
# You can check the CMAKE_CXX_FLAGS in CMakeCache.txt to verify the issue.
if(CMAKE_CXX_FLAGS)
string(REGEX REPLACE "-std=c\\+\\+([0-9a-z]+)" " " CMAKE_CXX_FLAGS_INIT ${CMAKE_CXX_FLAGS})
endif(CMAKE_CXX_FLAGS)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_INIT}" CACHE STRING "Flags used by the compiler during all build types." FORCE)

if(NOT CMAKE_CXX_ABI)
    set(CMAKE_CXX_ABI 0 CACHE STRING
        "Choose the value for _GLIBCXX_USE_CXX11_ABI, options are: 0|1."
        FORCE)
endif(NOT CMAKE_CXX_ABI)
message(STATUS "CMAKE_CXX_ABI: _GLIBCXX_USE_CXX11_ABI=${CMAKE_CXX_ABI}")
add_definitions(-D_GLIBCXX_USE_CXX11_ABI=${CMAKE_CXX_ABI})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# for CUDA, must be put before finding PyTorch
# link dynamic libraries rather than static ones
set(CUDA_USE_STATIC_CUDA_RUNTIME OFF)
# critical for cuda_add_library, as we need to turn off -O flags
# to make sure the symbols generated by nvcc and gcc are the same
set(CUDA_PROPAGATE_HOST_FLAGS ON)
#set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--expt-extended-lambda)
# required for executable to run at the install directory
# it will change the RPATH when installing
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

include(cmake/TorchExtension.cmake)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# without this, clang will complain about linking
#set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set_property(GLOBAL PROPERTY POSITION_INDEPENDENT_CODE TRUE)

find_package(OpenMP REQUIRED)
#find_program(PYTHON "python" REQUIRED)
find_package(ZLIB REQUIRED)
set(Boost_NO_BOOST_CMAKE TRUE)
find_package(Boost 1.55.0 REQUIRED)
message(STATUS "Boost_INCLUDE_DIRS = ${Boost_INCLUDE_DIRS}")

if (CUDA_FOUND)
  if (NOT CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 6.0 6.1 7.0)
    if (${CUDA_VERSION_MAJOR} VERSION_GREATER "9")
      list(APPEND CMAKE_CUDA_ARCHITECTURES 7.5)
    endif(${CUDA_VERSION_MAJOR} VERSION_GREATER "9")
    if (${CUDA_VERSION_MAJOR} VERSION_GREATER "10")
      list(APPEND CMAKE_CUDA_ARCHITECTURES 8.0)
      # arch 8.6 removed for compatability with 3090
      # list(APPEND CMAKE_CUDA_ARCHITECTURES 8.6)
    endif(${CUDA_VERSION_MAJOR} VERSION_GREATER "10")
  endif(NOT CMAKE_CUDA_ARCHITECTURES)

  # for cuda_add_library
  cuda_select_nvcc_arch_flags(CUDA_ARCH_FLAGS ${CMAKE_CUDA_ARCHITECTURES})
  message(STATUS "CUDA_ARCH_FLAGS: ${CUDA_ARCH_FLAGS}")
  list(APPEND CUDA_NVCC_FLAGS ${CUDA_ARCH_FLAGS} --compiler-options;-fPIC)
endif(CUDA_FOUND)
