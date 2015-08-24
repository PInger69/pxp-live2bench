//
//  PXPTIFColor.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIFColor_c
#define PXPTIFColor_c

#include <inttypes.h>
#include <stdbool.h>

/// Data structure used to represent color in a PXPTIF.
typedef struct PXPTIFColor {
    uint8_t r, g, b, a;
} PXPTIFColor;

/// Makes a PXPTIFColor data structure.
PXPTIFColor PXPTIFColorMake(uint8_t r, uint8_t g, uint8_t b, uint8_t a);

/// Returns true if two colors are equal.
bool PXPTIFColorEqual(PXPTIFColor a, PXPTIFColor b);

#endif /* PXPTIFColor_c */
