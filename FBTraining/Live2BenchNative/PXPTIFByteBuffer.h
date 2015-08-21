//
//  PXPTIFByteBuffer.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIFByteBuffer_c
#define PXPTIFByteBuffer_c

#include <inttypes.h>

typedef struct PXPTIFByteBuffer *PXPTIFByteBufferRef;

PXPTIFByteBufferRef __nonnull PXPTIFByteBufferCreate(void);
void PXPTIFByteBufferDestroy(PXPTIFByteBufferRef __nonnull byteBuffer);

uint64_t PXPTIFByteBufferGetSize(PXPTIFByteBufferRef __nonnull byteBuffer);
const void *__nullable PXPTIFByteBufferGetBuffer(PXPTIFByteBufferRef __nonnull byteBuffer);

uint64_t PXPTIFByteBufferGetPosition(PXPTIFByteBufferRef __nonnull byteBuffer);
uint64_t PXPTIFByteBufferSetPosition(PXPTIFByteBufferRef __nonnull byteBuffer, uint64_t position);

void PXPTIFByteBufferWriteBytes(PXPTIFByteBufferRef __nonnull byteBuffer, const void *__nullable bytes, uint64_t size);
void PXPTIFByteBufferReadBytes(PXPTIFByteBufferRef __nonnull byteBuffer, void *__nullable bytes, uint64_t size);



#endif /* PXPTIFByteBuffer_c */
