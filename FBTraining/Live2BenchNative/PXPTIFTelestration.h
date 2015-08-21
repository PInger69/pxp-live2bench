//
//  PXPTIF.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIF_c
#define PXPTIF_c

#include <stdio.h>
#include <inttypes.h>

#include "PXPTIFVersion.h"
#include "PXPTIFAction.h"

#endif /* PXPTIF_c */

/// A reference to a data structure describing data in the Telestration.
typedef struct PXPTIFTelestration *PXPTIFTelestrationRef;

PXPTIFTelestrationRef __nonnull PXPTIFTelestrationCreate(const char *__nonnull sourceName, uint16_t width, uint16_t height, bool still, const PXPTIFActionRef __nonnull *__nullable actions, uint64_t n_actions);
void PXPTIFTelestrationDestroy(PXPTIFTelestrationRef __nonnull telestration);

const char *__nonnull PXPTIFTelestrationGetSourceName(PXPTIFTelestrationRef __nonnull telestration);
uint16_t PXPTIFTelestrationGetWidth(PXPTIFTelestrationRef __nonnull telestration);
uint16_t PXPTIFTelestrationGetHeight(PXPTIFTelestrationRef __nonnull telestration);
bool PXPTIFTelestrationIsStill(PXPTIFTelestrationRef __nonnull telestration);
const PXPTIFActionRef __nonnull *__nullable PXPTIFTelestrationGetActions(PXPTIFTelestrationRef __nonnull telestration);
uint64_t PXPTIFTelestrationGetActionCount(PXPTIFTelestrationRef __nonnull telestration);


PXPTIFTelestrationRef __nullable PXPTIFTelestrationCreateWithData(const void *__nullable bytes, uint64_t size);
void PXPTIFTelestrationGenerateDataRepresentation(PXPTIFTelestrationRef __nonnull telestration, void *__nonnull bytes, uint64_t *__nonnull size);