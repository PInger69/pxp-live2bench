//
//  PXPTIFIdentifier.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFIdentifier.h"
#include <string.h>

// DO NOT CHANGE THIS (".PXPTIF")
const PXPTIFIdentifier kPXPTIFIdentifierValid = { '.', 'P', 'X', 'P', 'T', 'I', 'F', '\0' };

bool PXPTIFIdentifierValid(PXPTIFIdentifier identifier)
{
    return memcmp(identifier, kPXPTIFIdentifierValid, 8 * sizeof(uint8_t)) == 0;
}