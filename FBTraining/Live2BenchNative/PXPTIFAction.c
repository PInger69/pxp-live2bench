//
//  PXPTIFAction.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFAction.h"

#include <stdlib.h>
#include <string.h>

struct PXPTIFAction {
    uint32_t type;
    PXPTIFColor color;
    float width;
    uint32_t n_points;
    PXPTIFPoint points[];
};

PXPTIFActionRef __nonnull PXPTIFActionCreate(uint32_t type, PXPTIFColor color, float width, PXPTIFPoint *__nullable points, uint32_t n_points) {
    struct PXPTIFAction *action = malloc(sizeof(struct PXPTIFAction) + n_points * sizeof(struct PXPTIFPoint));
    
    action->type = type;
    action->color = color;
    action->width = width;
    action->n_points = n_points;
    
    if (n_points && points) {
        memcpy(&action->points[0], points, n_points * sizeof(struct PXPTIFPoint));
    }
    
    return action;
}

void PXPTIFActionDestroy(PXPTIFActionRef __nonnull action)
{
    free(action);
}

PXPTIFActionRef __nonnull PXPTIFActionCopy(PXPTIFActionRef __nonnull action)
{
    PXPTIFActionRef copy = malloc(PXPTIFActionGetSize(action));
    memcpy(copy, action, PXPTIFActionGetSize(action));
    return copy;
};

uint32_t PXPTIFActionGetType(PXPTIFActionRef __nonnull action)
{
    return action->type;
}

PXPTIFColor PXPTIFActionGetColor(PXPTIFActionRef __nonnull action)
{
    return action->color;
}

float PXPTIFActionGetWidth(PXPTIFActionRef __nonnull action)
{
    return action->width;
}

uint32_t PXPTIFActionGetPointCount(PXPTIFActionRef __nonnull action)
{
    return action->n_points;
}

const PXPTIFPoint *__nullable PXPTIFActionGetPoints(PXPTIFActionRef __nonnull action)
{
    return action->points;
}

uint32_t PXPTIFActionGetSize(PXPTIFActionRef __nonnull action)
{
    return sizeof(struct PXPTIFAction) + action->n_points * sizeof(struct PXPTIFPoint);
}
