//
//  PXPTIFColor.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFColor.h"

PXPTIFColor PXPTIFColorMake(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
    PXPTIFColor color;
    color.r = r;
    color.g = g;
    color.b = b;
    color.a = a;
    return color;
}

bool PXPTIFColorEqual(PXPTIFColor a, PXPTIFColor b)
{
    return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}
