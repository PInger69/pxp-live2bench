//
//  PXPTIFByteBuffer.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFByteBuffer.h"

#include <stdlib.h>
#include <string.h>

#define INITIAL_BUFFER_CAPACITY 1024

struct PXPTIFByteBuffer
{
    size_t size;
    size_t position;
    size_t capacity;
    void *buffer;
};

PXPTIFByteBufferRef __nonnull PXPTIFByteBufferCreate(void)
{
    struct PXPTIFByteBuffer *byteBuffer = malloc(sizeof(struct PXPTIFByteBuffer));
    byteBuffer->size = 0;
    byteBuffer->position = 0;
    byteBuffer->capacity = INITIAL_BUFFER_CAPACITY;
    byteBuffer->buffer = malloc(byteBuffer->capacity);
    return byteBuffer;
}

void PXPTIFByteBufferDestroy(PXPTIFByteBufferRef __nonnull byteBuffer)
{
    byteBuffer->size = 0;
    byteBuffer->position = 0;
    byteBuffer->capacity = 0;
    if (byteBuffer->buffer) {
        free(byteBuffer->buffer);
        byteBuffer->buffer = NULL;
    }
    free(byteBuffer);
}

size_t PXPTIFByteBufferGetSize(PXPTIFByteBufferRef __nonnull byteBuffer)
{
    return byteBuffer->size;
}

const void *__nullable PXPTIFByteBufferGetBuffer(PXPTIFByteBufferRef __nonnull byteBuffer)
{
    return byteBuffer->buffer;
}

size_t PXPTIFByteBufferGetPosition(PXPTIFByteBufferRef __nonnull byteBuffer)
{
    return byteBuffer->position;
}

size_t PXPTIFByteBufferSetPosition(PXPTIFByteBufferRef __nonnull byteBuffer, size_t position)
{
    return byteBuffer->position = position < byteBuffer->size ? position : byteBuffer->size;
}

void PXPTIFByteBufferWriteBytes(PXPTIFByteBufferRef __nonnull byteBuffer, const void *__nullable bytes, size_t size)
{
    
    if (size > 0) {
        // reallocate if needed.
        if (byteBuffer->position + size > byteBuffer->capacity) {
            while (byteBuffer->position + size > byteBuffer->capacity) byteBuffer->capacity *= 2;
            byteBuffer->buffer = realloc(byteBuffer->buffer, byteBuffer->capacity);
        }
        
        // copy the data.
        if (bytes) {
            memcpy(byteBuffer->buffer + byteBuffer->position, bytes, size);
        }
        byteBuffer->position += size;
        
        // adjust the total size.
        if (byteBuffer->position > byteBuffer->size) {
            byteBuffer->size = byteBuffer->position;
        }
    }
    
}

void PXPTIFByteBufferReadBytes(PXPTIFByteBufferRef __nonnull byteBuffer, void *__nullable bytes, size_t size)
{
    if (size > 0 && bytes) {
        memcpy(bytes, byteBuffer->buffer + byteBuffer->position, size);
    }
    byteBuffer->position += size;
}
