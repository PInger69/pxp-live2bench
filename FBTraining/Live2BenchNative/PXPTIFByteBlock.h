//
//  PXPTIFByteBlock.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#ifndef PXPTIFByteBlock_c
#define PXPTIFByteBlock_c

#include <inttypes.h>
#include "PXPTIFByteBuffer.h"

/// Utility data structure used to represent a block of data within a PXPTIF.
typedef struct PXPTIFByteBlock *PXPTIFByteBlockRef;

/// Creates a ByteBlock storing a copy of 'bytes' of 'size'.
PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCreateWithBytes(const void *__nonnull bytes, uint64_t size);

/// Destroys a ByteBlock.
void PXPTIFByteBlockDestroy(PXPTIFByteBlockRef __nonnull byteBlock);

/// Gets the size of bytes contained by the ByteBuffer.
uint64_t PXPTIFByteBlockGetSize(PXPTIFByteBlockRef __nonnull byteBlock);

/// Gets the bytes contained by the ByteBuffer.
const void *__nonnull PXPTIFByteBlockGetBytes(PXPTIFByteBlockRef __nonnull byteBlock);

/// Creates a ByteBlock from a UTF8 formatted C String.
PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCreateWithUTF8String(const char *__nonnull string);

/// Returns the contents of a ByteBlock as UTF8 formatted C String.
const char *__nonnull PXPTIFByteBlockGetUTF8String(PXPTIFByteBlockRef __nonnull byteBlock);

/// Writes a ByteBlock to a ByteBuffer
void PXPTIFByteBlockWriteToBuffer(PXPTIFByteBlockRef __nonnull byteBlock, PXPTIFByteBufferRef __nonnull buffer);

/// Reads a copy of a ByteBlock from a ByteBuffer
PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCopyFromBuffer(PXPTIFByteBufferRef __nonnull buffer);

#endif /* PXPTIFByteBlock_c */
