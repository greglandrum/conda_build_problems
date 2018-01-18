cmake_minimum_required(VERSION 3.1)

project (RDKit)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

enable_testing()

set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/Code/cmake/Modules/")

add_library(rdkit_base INTERFACE)

option(RDK_BUILD_PYTHON_WRAPPERS "build the standard python wrappers" ON )
option(RDK_INSTALL_INTREE "install the rdkit in the source tree (former behavior)" OFF )
option(RDK_INSTALL_STATIC_LIBS "install the rdkit static libraries" OFF )
option(RDK_BUILD_CPP_TESTS "build the c++ tests (disabing can speed up builds" OFF)

# At build time put runtime binaries in the bin subdirectory
set(RDK_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")
set(RDK_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(RDK_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib")
# Also place the python extension where the source tree would expect them
set(RDK_PYTHON_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rdkit")

#-------
# Config variables:
set(RDKit_Year "2018")
set(RDKit_Month "03")
set(RDKit_Revision "1.dev1")
set(RDKit_ABI "1")

set(RDKit_CodeDir "${CMAKE_CURRENT_SOURCE_DIR}/Code")
set(RDKit_ExternalDir "${CMAKE_CURRENT_SOURCE_DIR}/External")

if(RDK_INSTALL_INTREE)
  set(RDKit_BinDir "${CMAKE_SOURCE_DIR}/bin")
  set(RDKit_LibDir "${CMAKE_SOURCE_DIR}/lib")
  set(RDKit_HdrDir "Code") # used in rdkit-config.cmake, path prefix not needed.
else(RDK_INSTALL_INTREE)
  set(RDKit_BinDir "bin")
  set(RDKit_LibDir "lib${LIB_SUFFIX}")
  set(RDKit_HdrDir "include/rdkit")
  set(RDKit_ShareDir "share/RDKit")
endif(RDK_INSTALL_INTREE)

# defines macros: rdkit_python_extension, rdkit_test
include(RDKitUtils)
install(EXPORT ${RDKit_EXPORTED_TARGETS} DESTINATION ${RDKit_LibDir})
install(TARGETS rdkit_base EXPORT ${RDKit_EXPORTED_TARGETS}
        COMPONENT dev )

# create and install package configuration and version files
configure_file (
    ${RDKit_SOURCE_DIR}/rdkit-config.cmake.in
    ${RDKit_BINARY_DIR}/rdkit-config.cmake @ONLY)

configure_file (
    ${RDKit_SOURCE_DIR}/rdkit-config-version.cmake.in
    ${RDKit_BINARY_DIR}/rdkit-config-version.cmake @ONLY)

install(FILES
    ${RDKit_BINARY_DIR}/rdkit-config.cmake
    ${RDKit_BINARY_DIR}/rdkit-config-version.cmake
    DESTINATION ${RDKit_LibDir})

if(RDK_BUILD_PYTHON_WRAPPERS)
  #-------
  # pull in python:
  find_package(PythonInterp)
  if (PYTHONINTERP_FOUND AND NOT Python_ADDITIONAL_VERSIONS)
    set(Python_ADDITIONAL_VERSIONS "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
  endif (PYTHONINTERP_FOUND AND NOT Python_ADDITIONAL_VERSIONS)
  find_package(PythonLibs)
  if(CMAKE_MAJOR_VERSION EQUAL 2 AND CMAKE_MINOR_VERSION EQUAL 6)
    target_include_directories(rdkit_base INTERFACE ${PYTHON_INCLUDE_PATH})
  else(CMAKE_MAJOR_VERSION EQUAL 2 AND CMAKE_MINOR_VERSION EQUAL 6)
    target_include_directories(rdkit_base INTERFACE ${PYTHON_INCLUDE_DIR})
  endif(CMAKE_MAJOR_VERSION EQUAL 2 AND CMAKE_MINOR_VERSION EQUAL 6)
  find_package(NumPy REQUIRED)
  target_include_directories(rdkit_base INTERFACE ${PYTHON_NUMPY_INCLUDE_PATH})

  if(PYTHON_VERSION_MAJOR EQUAL 3)
    # Find boost-python3 using name specified as command line option then fall back to commonly used names
    set(RDK_BOOST_PYTHON3_NAME "python3" CACHE STRING "Name of the boost python3 library. If installed as libboost_python-xxx.so, use python-xxx.")
    foreach(Boost_Python_Lib "${RDK_BOOST_PYTHON3_NAME}" "python-py3${PYTHON_VERSION_MINOR}" "python3")
      find_package(Boost 1.56.0 COMPONENTS "${Boost_Python_Lib}" QUIET)
      if(Boost_FOUND)
        list(APPEND Boost_IMPORTED_LIBRARIES "Boost::${Boost_Python_Lib}")
        break()
      endif()
    endforeach()
    # If boost-python3 not found, just find boost-python and hope that it is compatible with python3
    if(NOT Boost_FOUND)
      find_package(Boost 1.56.0 COMPONENTS python REQUIRED)
      list(APPEND Boost_IMPORTED_LIBRARIES "Boost::python")
    endif()
  else(PYTHON_VERSION_MAJOR EQUAL 3)
     find_package(Boost 1.56.0 COMPONENTS python REQUIRED)
     list(APPEND Boost_IMPORTED_LIBRARIES "Boost::python")
  endif(PYTHON_VERSION_MAJOR EQUAL 3)
    if (NOT PYTHON_INSTDIR)
      # Determine correct installation directory for Python bindings
      # From http://plplot.svn.sourceforge.net/viewvc/plplot/trunk/cmake/modules/python.cmake?revision=11014
      execute_process(
        COMMAND
        ${PYTHON_EXECUTABLE} -c "from __future__ import print_function; from distutils import sysconfig; print(sysconfig.get_python_lib(1,0,prefix='${CMAKE_INSTALL_PREFIX}'))"
        OUTPUT_VARIABLE PYTHON_INSTDIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    endif (NOT PYTHON_INSTDIR)
    message("Python Install directory ${PYTHON_INSTDIR}")
    install(DIRECTORY rdkit DESTINATION ${PYTHON_INSTDIR}
      COMPONENT python
      PATTERN "CMake*" EXCLUDE
      )
    set(RDKit_PythonDir "${PYTHON_INSTDIR}/rdkit")
endif()

# set the boost include directories
target_link_libraries(rdkit_base INTERFACE Boost::boost)

target_include_directories(rdkit_base INTERFACE
                           $<BUILD_INTERFACE:${RDKit_CodeDir}>
                           $<INSTALL_INTERFACE:${RDKit_HdrDir}>
                           )


# Detect clang, which masquerades as gcc.  CMake 2.6 doesn't know how to
# detect it.
string(REGEX MATCH "clang" CMAKE_COMPILER_IS_CLANG "${CMAKE_C_COMPILER}")

 if(CMAKE_COMPILER_IS_GNUCXX)
   # We don't on C_FLAGS warnings to keep Avalon compiling quiet
   SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-deprecated -Wno-unused-function -fno-strict-aliasing")
   SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated -Wno-unused-function -fno-strict-aliasing -Wall -Wextra")
  if (NOT CYGWIN)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  endif()
 endif()
 if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
   # We don't on C_FLAGS warnings to keep Avalon compiling quiet
   SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-array-bounds -fPIC")
   SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wno-deprecated -Wno-unused-function -fno-strict-aliasing -fPIC")
 endif()

add_subdirectory(Code)

if(RDK_BUILD_PYTHON_WRAPPERS)
  add_subdirectory(rdkit)
endif(RDK_BUILD_PYTHON_WRAPPERS)

