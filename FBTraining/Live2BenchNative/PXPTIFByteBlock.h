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

typedef struct PXPTIFByteBlock *PXPTIFByteBlockRef;

PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCreateWithBytes(const void *__nonnull bytes, uint64_t size);
void PXPTIFByteBlockDestroy(PXPTIFByteBlockRef __nonnull byteBlock);

uint64_t PXPTIFByteBlockGetSize(PXPTIFByteBlockRef __nonnull byteBlock);
const void *__nonnull PXPTIFByteBlockGetBytes(PXPTIFByteBlockRef __nonnull byteBlock);

PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCreateWithUTF8String(const char *__nonnull string);
const char *__nonnull PXPTIFByteBlockGetUTF8String(PXPTIFByteBlockRef __nonnull byteBlock);

void PXPTIFByteBlockWriteToBuffer(PXPTIFByteBlockRef __nonnull byteBlock, PXPTIFByteBufferRef __nonnull buffer);
PXPTIFByteBlockRef __nonnull PXPTIFByteBlockCopyFromBuffer(PXPTIFByteBufferRef __nonnull buffer);

#endif /* PXPTIFByteBlock_c */
