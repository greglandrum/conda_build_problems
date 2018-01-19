
PYTHON_ADD_MODULE(rdBase RDBase.cpp)
set_target_properties(rdBase PROPERTIES PREFIX "")
set_target_properties(rdBase PROPERTIES
                     LIBRARY_OUTPUT_DIRECTORY
                     ${RDK_PYTHON_OUTPUT_DIRECTORY})

target_link_libraries(rdBase rdkit_base
                     ${PYTHON_LIBRARIES} ${Boost_IMPORTED_LIBRARIES} )
		     
INSTALL(TARGETS rdBase
       LIBRARY DESTINATION ${RDKit_PythonDir} COMPONENT python)


