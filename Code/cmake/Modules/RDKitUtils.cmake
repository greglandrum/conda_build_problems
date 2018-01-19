include(BoostUtils)
IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
# Mac OS X specific code
  set(RDKit_VERSION "${RDKit_Year}.${RDKit_Month}")
ELSE(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(RDKit_VERSION "${RDKit_ABI}.${RDKit_Year}.${RDKit_Month}")
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
set(RDKit_RELEASENAME "${RDKit_Year}.${RDKit_Month}")
if (RDKit_Revision)
  set(RDKit_RELEASENAME "${RDKit_RELEASENAME}.${RDKit_Revision}")
  set(RDKit_VERSION "${RDKit_VERSION}.${RDKit_Revision}")
else(RDKit_Revision)
  set(RDKit_VERSION "${RDKit_VERSION}.0")
endif(RDKit_Revision)

set(compilerID "${CMAKE_CXX_COMPILER_ID}")
set(systemAttribute "")
if(MINGW)
  set(systemAttribute "MINGW")
endif(MINGW)
if(UNIX)
  set(systemAttribute "UNIX")
endif(UNIX)
if(CMAKE_SIZEOF_VOID_P MATCHES 4)
  set(bit3264 "32-bit")
else()
  set(bit3264 "64-bit")
endif()
set(RDKit_BUILDNAME "${CMAKE_SYSTEM_NAME}|${CMAKE_SYSTEM_VERSION}|${systemAttribute}|${compilerID}|${bit3264}")
set(RDKit_EXPORTED_TARGETS rdkit-targets)

macro(rdkit_library)
  PARSE_ARGUMENTS(RDKLIB
    "LINK_LIBRARIES;DEST"
    "SHARED"
    ${ARGN})
  CAR(RDKLIB_NAME ${RDKLIB_DEFAULT_ARGS})
  CDR(RDKLIB_SOURCES ${RDKLIB_DEFAULT_ARGS})
    # we're going to always build in shared mode since we
    # need exceptions to be (correctly) catchable across
    # boundaries. As of now (June 2010), this doesn't work
    # with g++ unless libraries are shared.
      add_library(${RDKLIB_NAME} SHARED ${RDKLIB_SOURCES})
      target_link_libraries(${RDKLIB_NAME} PUBLIC rdkit_base)
      INSTALL(TARGETS ${RDKLIB_NAME} EXPORT ${RDKit_EXPORTED_TARGETS}
              DESTINATION ${RDKit_LibDir}/${RDKLIB_DEST}
              COMPONENT runtime )
      if(RDK_INSTALL_STATIC_LIBS)
        add_library(${RDKLIB_NAME}_static ${RDKLIB_SOURCES})

        foreach(linkLib ${RDKLIB_LINK_LIBRARIES})
          if(${linkLib} MATCHES "^(Boost)|(Thread)")
            set(rdk_static_link_libraries "${rdk_static_link_libraries}${linkLib};")
          else()
            set(rdk_static_link_libraries "${rdk_static_link_libraries}${linkLib}_static;")
          endif()
        endforeach()
        target_link_libraries(${RDKLIB_NAME}_static PUBLIC ${rdk_static_link_libraries})
        target_link_libraries(${RDKLIB_NAME}_static PUBLIC rdkit_base)
        INSTALL(TARGETS ${RDKLIB_NAME}_static EXPORT ${RDKit_EXPORTED_TARGETS}
                DESTINATION ${RDKit_LibDir}/${RDKLIB_DEST}
                COMPONENT dev )
        set_target_properties(${RDKLIB_NAME}_static PROPERTIES
                              OUTPUT_NAME "RDKit${RDKLIB_NAME}_static")

      endif(RDK_INSTALL_STATIC_LIBS)
  IF(RDKLIB_LINK_LIBRARIES)
    target_link_libraries(${RDKLIB_NAME} PUBLIC ${RDKLIB_LINK_LIBRARIES})
  ENDIF(RDKLIB_LINK_LIBRARIES)
    set_target_properties(${RDKLIB_NAME} PROPERTIES
                          OUTPUT_NAME "RDKit${RDKLIB_NAME}"
                          VERSION ${RDKit_VERSION}
                          SOVERSION ${RDKit_ABI} )
  set_target_properties(${RDKLIB_NAME} PROPERTIES
                        ARCHIVE_OUTPUT_DIRECTORY ${RDK_ARCHIVE_OUTPUT_DIRECTORY}
                        RUNTIME_OUTPUT_DIRECTORY ${RDK_RUNTIME_OUTPUT_DIRECTORY}
                        LIBRARY_OUTPUT_DIRECTORY ${RDK_LIBRARY_OUTPUT_DIRECTORY})
endmacro(rdkit_library)

