// $Id$
//
// Copyright (c) 2004-2011 greg Landrum and Rational Discovery LLC
//
//   @@ All Rights Reserved @@
//  This file is part of the RDKit.
//  The contents are covered by the terms of the BSD license
//  which is included in the file license.txt, found at the root
//  of the RDKit source tree.
//
#include "../python.h"
#include <boost/python.hpp>

namespace python = boost::python;

#include "../python_streambuf.h"
namespace RDKit {
const char * rdkitVersion = "2018.03.1.dev1";

// The Boost version as detected at build time.
// CMake's Boost_LIB_VERSION is defined by the FindBoost.cmake module
// to be the same as the value from <boost/version.hpp>
const char * boostVersion = "1_65_1";

// The system/compiler on which RDKit was built as detected at build time.
const char * rdkitBuild = "Darwin|17.3.0|UNIX|AppleClang|64-bit";
}

namespace {
struct python_streambuf_wrapper {
  typedef boost_adaptbx::python::streambuf wt;

  static void wrap() {
    using namespace boost::python;
    class_<wt, boost::noncopyable>("streambuf", no_init)
        .def(init<object&, std::size_t>(
            (arg("python_file_obj"), arg("buffer_size") = 0),
            "documentation")[with_custodian_and_ward_postcall<0, 2>()]);
  }
};

}

BOOST_PYTHON_MODULE(rdBase) {
  python::scope().attr("__doc__") =
      "Module containing basic definitions for wrapped C++ code\n"
      "\n";

  python::scope().attr("rdkitVersion") = RDKit::rdkitVersion;
  python::scope().attr("boostVersion") = RDKit::boostVersion;
  python::scope().attr("rdkitBuild") = RDKit::rdkitBuild;

  python_streambuf_wrapper::wrap();
}
