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

/// Utility data structure used to format PXPTIF data in memory.
typedef struct PXPTIFByteBuffer *PXPTIFByteBufferRef;

/// Creates an empty ByteBuffer.
PXPTIFByteBufferRef __nonnull PXPTIFByteBufferCreate(void);

/// Destroys a ByteBuffer.
void PXPTIFByteBufferDestroy(PXPTIFByteBufferRef __nonnull byteBuffer);

/// Gets the size of the ByteBuffer's internal buffer.
uint64_t PXPTIFByteBufferGetSize(PXPTIFByteBufferRef __nonnull byteBuffer);

/// Gets the ByteBuffer's internal buffer.
const void *__nullable PXPTIFByteBufferGetBuffer(PXPTIFByteBufferRef __nonnull byteBuffer);

/// Gets the current read/write position in the ByteBuffer.
uint64_t PXPTIFByteBufferGetPosition(PXPTIFByteBufferRef __nonnull byteBuffer);

/// Attempts to set the ByteBuffer's read/write position, and returns the position it went to.
uint64_t PXPTIFByteBufferSetPosition(PXPTIFByteBufferRef __nonnull byteBuffer, uint64_t position);

/// Writes 'size' many 'bytes' to the ByteBuffer at the current position, and moves the position forward by 'size'.
void PXPTIFByteBufferWriteBytes(PXPTIFByteBufferRef __nonnull byteBuffer, const void *__nullable bytes, uint64_t size);

/// Read's 'size' many 'bytes' from the ByteBuffer at the current position, and move the position forward by 'size'
void PXPTIFByteBufferReadBytes(PXPTIFByteBufferRef __nonnull byteBuffer, void *__nullable bytes, uint64_t size);



#endif /* PXPTIFByteBuffer_c */
