cmake_minimum_required(VERSION 3.1)

project (RDKit)

add_library(rdkit_base INTERFACE)

option(RDK_BUILD_PYTHON_WRAPPERS "build the standard python wrappers" ON )
option(RDK_INSTALL_INTREE "install the rdkit in the source tree (former behavior)" OFF )

# Also place the python extension where the source tree would expect them
set(RDK_PYTHON_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/rdkit")

if(RDK_BUILD_PYTHON_WRAPPERS)
  #-------
  # pull in python:
  find_package(PythonInterp)
  if (PYTHONINTERP_FOUND AND NOT Python_ADDITIONAL_VERSIONS)
    set(Python_ADDITIONAL_VERSIONS "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
  endif (PYTHONINTERP_FOUND AND NOT Python_ADDITIONAL_VERSIONS)
  find_package(PythonLibs)
  target_include_directories(rdkit_base INTERFACE ${PYTHON_INCLUDE_DIR})

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

add_subdirectory(Code)

if(RDK_BUILD_PYTHON_WRAPPERS)
  add_subdirectory(rdkit)
endif(RDK_BUILD_PYTHON_WRAPPERS)

