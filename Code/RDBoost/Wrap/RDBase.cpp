//
// Copyright (c) 2018 Greg Landrum
//
//
#include <boost/python.hpp>
#include <boost/python/scope.hpp>
#include <boost/python.hpp>

namespace python = boost::python;

namespace {
  int stupid_fun(int a1) {return 1;};
  int stupid_fun2(float a1, int a2) {return 1;};
  struct stupid_wrapper {
  static void wrap() {
    //python::def("stupid_fun",&stupid_fun,(python::arg("a1") = float(0)), "docs"); // this one works
    python::def("stupid_fun",&stupid_fun,(python::arg("a1") = int(0)), "docs"); // this one seg faults
    //python::def("stupid_fun2",&stupid_fun2,(python::arg("a1") = float(0),python::arg("a2") = int(0)), "docs"); // seg faults
  }
};

}

BOOST_PYTHON_MODULE(rdBase) {
  stupid_wrapper::wrap();
}
