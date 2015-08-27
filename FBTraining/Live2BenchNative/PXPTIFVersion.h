//
//  PXPTIFVersion.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIFVersion_c
#define PXPTIFVersion_c

#include <inttypes.h>
#include <stdbool.h>

// CHANGE THIS ONLY IF YOU CHANGE THE WAY DATA IS STORED IN THE PXPTIF!
#define PXPTIF_VERSION PXPTIFVersionMake(1, 0)

/// A data structure representing the version of data stored in a PXPTIF.
typedef struct PXPTIFVersion // DO NOT MODIFY DATA STRUCTURE, MUST BE CONSISTENT!
{
    uint16_t major;
    uint16_t minor;
}
PXPTIFVersion;

/// Makes a PXPTIF Version data structure.
PXPTIFVersion PXPTIFVersionMake(uint16_t major, uint16_t minor);

/// Compares two PXPTIF versions. Returns a negative integer if 'a' is less than 'b', a positive integer if 'a' is greater than 'b', and 0 if 'a' and 'b' are equal.
int PXPTIFVersionCompare(PXPTIFVersion a, PXPTIFVersion b);

/// Returns true if two PXPTIF versions are equal.
bool PXPTIFVersionEqual(PXPTIFVersion a, PXPTIFVersion b);

#endif /* PXPTIFVersion_c */
