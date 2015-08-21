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
    uint64_t n_points;
    PXPTIFPoint points[];
};

PXPTIFActionRef __nonnull PXPTIFActionCreate(uint32_t type, PXPTIFColor color, float width, PXPTIFPoint *__nullable points, uint64_t n_points) {
    struct PXPTIFAction *action = malloc(sizeof(struct PXPTIFAction) + n_points * sizeof(struct PXPTIFPoint));
    
    action->type = type;
    action->color = color;
    action->width = width;
    action->n_points = n_points;
    
    if (n_points && points) {
        memcpy(action->points, points, n_points * sizeof(struct PXPTIFPoint));
    }
    
    return action;
}

void PXPTIFActionDestroy(PXPTIFActionRef __nonnull action)
{
    free(action);
}

PXPTIFActionRef __nonnull PXPTIFActionCopy(PXPTIFActionRef __nonnull action)
{
    PXPTIFActionRef copy = malloc(sizeof(struct PXPTIFAction) + action->n_points * sizeof(struct PXPTIFPoint));
    copy->type = action->type;
    copy->color = action->color;
    copy->width = action->width;
    copy->n_points = action->n_points;
    
    if (action->points) {
        memcpy(copy->points, action->points, action->n_points);
    }
    
    return copy;
};

uint64_t PXPTIFActionGetSize(PXPTIFActionRef __nonnull action)
{
    return sizeof(struct PXPTIFAction) + action->n_points * sizeof(struct PXPTIFPoint);
}
