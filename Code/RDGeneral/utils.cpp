// $Id$
//
//  Copyright (C) 2002-2006 Greg Landrum and Rational Discovery LLC
//
//  @@ All Rights Reserved @@
//  This file is part of the RDKit.
//  The contents are covered by the terms of the BSD license
//  which is included in the file license.txt, found at the root
//  of the RDKit source tree.
//
#include <cmath>

namespace RDKit {

bool feq(double v1, double v2, double tol) { return fabs(v1 - v2) <= tol; }

}
