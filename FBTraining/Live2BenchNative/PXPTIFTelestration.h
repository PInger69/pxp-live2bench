//
//  PXPTIF.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIF_c
#define PXPTIF_c

#include <inttypes.h>
#include <stddef.h>
#include <stdbool.h>

#include "PXPTIFVersion.h"
#include "PXPTIFAction.h"

#endif /* PXPTIF_c */

/// A reference to a data structure describing data in the Telestration.
typedef struct PXPTIFTelestration *PXPTIFTelestrationRef;

/// Creates a telestration data structure.
PXPTIFTelestrationRef __nonnull PXPTIFTelestrationCreate(const char *__nonnull sourceName, uint16_t width, uint16_t height, bool still, const PXPTIFActionRef __nonnull *__nullable actions, uint32_t n_actions);

/// Destroys a telestration data structure.
void PXPTIFTelestrationDestroy(PXPTIFTelestrationRef __nonnull telestration);

/// Gets the source name of a telestration.
const char *__nonnull PXPTIFTelestrationGetSourceName(PXPTIFTelestrationRef __nonnull telestration);

/// Gets the width of a telestration.
uint16_t PXPTIFTelestrationGetWidth(PXPTIFTelestrationRef __nonnull telestration);

/// Gets the height of a telestration.
uint16_t PXPTIFTelestrationGetHeight(PXPTIFTelestrationRef __nonnull telestration);

/// Returns true if the telestration is still.
bool PXPTIFTelestrationIsStill(PXPTIFTelestrationRef __nonnull telestration);

/// Gets the actions contained within a telestration.
const PXPTIFActionRef __nonnull *__nullable PXPTIFTelestrationGetActions(PXPTIFTelestrationRef __nonnull telestration);

/// Gets the number of actions contained within a telestration.
uint32_t PXPTIFTelestrationGetActionCount(PXPTIFTelestrationRef __nonnull telestration);

/// Attemptes to create a telestration from PXPTIF data.
PXPTIFTelestrationRef __nullable PXPTIFTelestrationCreateWithData(const void *__nullable bytes, size_t size);

/// Generates PXPTIF data from the telestration.
void *__nonnull PXPTIFTelestrationCreateDataRepresentation(PXPTIFTelestrationRef __nonnull telestration, size_t *__nonnull size);