//
//  PXPTIFByteBlock.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFByteBlock.h"

#include <stdlib.h>
#include <string.h>

struct PXPTIFByteBlock
{
    uint32_t size;
    void *bytes;
};

PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCreateWithBytes(const void *__nonnull bytes, uint32_t size)
{
    PXPTIFByteBlockRef byteBlock = malloc(sizeof(struct PXPTIFByteBlock));
    byteBlock->size = size;
    if (size) {
        byteBlock->bytes = malloc(size);
        memcpy(byteBlock->bytes, bytes, size);
    } else {
        byteBlock->bytes = NULL;
    }
    return byteBlock;
}

void PXPTIFByteBlockDestroy(PXPTIFByteBlockRef __nonnull byteBlock)
{
    byteBlock->size = 0;
    free(byteBlock);
}

uint32_t PXPTIFByteBlockGetSize(PXPTIFByteBlockRef __nonnull byteBlock)
{
    return byteBlock->size;
}

const void *__nonnull PXPTIFByteBlockGetBytes(PXPTIFByteBlockRef __nonnull byteBlock)
{
    return byteBlock->bytes;
}

PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCreateWithUTF8String(const char *__nonnull string)
{
    return PXPTIFByteBlockCreateWithBytes(string, (uint32_t)(strlen(string) + 1) * sizeof(char));
}

const char *__nonnull PXPTIFByteBlockGetUTF8String(PXPTIFByteBlockRef __nonnull byteBlock)
{
    return byteBlock->bytes;
}

void PXPTIFByteBlockWriteToBuffer(PXPTIFByteBlockRef __nonnull byteBlock, PXPTIFByteBufferRef __nonnull buffer)
{
    PXPTIFByteBufferWriteBytes(buffer, &byteBlock->size, sizeof(uint32_t));
    PXPTIFByteBufferWriteBytes(buffer, byteBlock->bytes, byteBlock->size);
}

PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCopyFromBuffer(PXPTIFByteBufferRef __nonnull buffer)
{
    PXPTIFByteBlockRef byteBlock = malloc(sizeof(struct PXPTIFByteBlock));
    byteBlock->size = 0;
    
    // get the size.
    PXPTIFByteBufferReadBytes(buffer, &byteBlock->size, sizeof(uint32_t));
    
    // get the bytes.
    if (byteBlock->size) {
        byteBlock->bytes = malloc(byteBlock->size);
        PXPTIFByteBufferReadBytes(buffer, byteBlock->bytes, byteBlock->size);
    } else {
        byteBlock->bytes = NULL;
    }
    
    return byteBlock;
}
