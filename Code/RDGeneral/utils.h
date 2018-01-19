//
//  Copyright (C) 2002-2008 Greg Landrum and Rational Discovery LLC
//
//  @@ All Rights Reserved @@
//  This file is part of the RDKit.
//  The contents are covered by the terms of the BSD license
//  which is included in the file license.txt, found at the root
//  of the RDKit source tree.
//
//
#ifndef __RD_UTILS_H__
#define __RD_UTILS_H__

namespace RDKit {
//! floating point comparison with a tolerance
bool feq(double v1, double v2, double tol = 1e-4);

#endif
