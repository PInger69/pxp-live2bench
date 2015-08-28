//
//  PXPTIFVersion.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFVersion.h"

PXPTIFVersion PXPTIFVersionMake(uint16_t major, uint16_t minor)
{
    PXPTIFVersion version;
    version.major = major;
    version.minor = minor;
    return version;
}

int PXPTIFVersionCompare(PXPTIFVersion a, PXPTIFVersion b) {
    return a.major != b.major ? a.major - b.major : a.minor - b.minor;
}

bool PXPTIFVersionEqual(PXPTIFVersion a, PXPTIFVersion b) {
    return a.major == b.major && a.minor == b.minor;
}