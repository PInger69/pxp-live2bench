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

/// Data structure used to represent a point in a PXPTIF.
typedef struct PXPTIFPoint {
    double time;
    struct {
        uint32_t x, y;
    } position;
} PXPTIFPoint;

/// A reference to data structure used to represent an action in a PXPTIF.
typedef struct PXPTIFAction *PXPTIFActionRef;

/// Creates an action.
PXPTIFActionRef __nonnull PXPTIFActionCreate(uint32_t type, PXPTIFColor color, float width, PXPTIFPoint *__nullable points, uint64_t n_points);

/// Destroys an action.
void PXPTIFActionDestroy(PXPTIFActionRef __nonnull action);

/// Creates a copy of an action.
PXPTIFActionRef __nonnull PXPTIFActionCopy(PXPTIFActionRef __nonnull action);

/// Gets the type of an action.
uint32_t PXPTIFActionGetType(PXPTIFActionRef __nonnull action);

/// Gets the color of an action.
PXPTIFColor PXPTIFActionGetColor(PXPTIFActionRef __nonnull action);

/// Gets the stroke width of an action.
float PXPTIFActionGetWidth(PXPTIFActionRef __nonnull action);

/// Gets the number of points contained within an action.
uint64_t PXPTIFActionGetPointCount(PXPTIFActionRef __nonnull action);

/// Gets the points contained within an action.
const PXPTIFPoint *__nullable PXPTIFActionGetPoints(PXPTIFActionRef __nonnull action);

/// Sets the size in bytes of the entire action data structure.
uint64_t PXPTIFActionGetSize(PXPTIFActionRef __nonnull action);

#endif /* PXPTIFAction_c */
