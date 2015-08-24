//
//  PXPTIFIdentifier.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFIdentifier.h"

// DO NOT CHANGE THIS (".PXPTIF")
const PXPTIFIdentifier kPXPTIFIdentifierValid = { '.', 'P', 'X', 'P', 'T', 'I', 'F', '\0' };

bool PXPTIFIdentifierValid(PXPTIFIdentifier identifier)
{
    return *(uint64_t *)identifier == *(uint64_t *)kPXPTIFIdentifierValid;
}