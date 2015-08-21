//
//  PXPTIFIdentifier.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIFIdentifier_c
#define PXPTIFIdentifier_c

#include <inttypes.h>
#include <stdbool.h>

typedef uint8_t PXPTIFIdentifier[8];

/// the valid identifier for PXPTIF.
const extern PXPTIFIdentifier kPXPTIFIdentifierValid;

/// checks to see if an identifer is valid.
bool PXPTIFIdentifierValid(PXPTIFIdentifier identifier);

#endif /* PXPTIFIdentifier_c */
