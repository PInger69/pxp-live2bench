//
//  PXPTIFAction.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIFAction_c
#define PXPTIFAction_c

#include <inttypes.h>
#include "PXPTIFColor.h"

typedef struct PXPTIFPoint {
    double time;
    struct {
        uint32_t x, y;
    } position;
} PXPTIFPoint;

typedef struct PXPTIFAction *PXPTIFActionRef;

PXPTIFActionRef __nonnull PXPTIFActionCreate(uint32_t type, PXPTIFColor color, float width, PXPTIFPoint *__nullable points, uint64_t n_points);
void PXPTIFActionDestroy(PXPTIFActionRef __nonnull action);

PXPTIFActionRef __nonnull PXPTIFActionCopy(PXPTIFActionRef __nonnull action);

uint32_t PXPTIFActionGetType(PXPTIFActionRef __nonnull action);
PXPTIFColor PXPTIFActionGetColor(PXPTIFActionRef __nonnull action);
float PXPTIFActionGetWidth(PXPTIFActionRef __nonnull action);
uint64_t PXPTIFActionGetPointCount(PXPTIFActionRef __nonnull action);
const PXPTIFPoint *__nullable PXPTIFActionGetPoints(PXPTIFActionRef __nonnull action);

uint64_t PXPTIFActionGetSize(PXPTIFActionRef __nonnull action);

#endif /* PXPTIFAction_c */
