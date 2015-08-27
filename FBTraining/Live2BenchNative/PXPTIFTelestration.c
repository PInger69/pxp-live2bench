//
//  PXPTIFTelestration.c
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#include "PXPTIFTelestration.h"

#include <stdlib.h>
#include <string.h>

#include "PXPTIFIdentifier.h"
#include "PXPTIFByteBuffer.h"
#include "PXPTIFByteBlock.h"

// THIS IS VERSION 1.0
// If you change how the data is written you MUST change the version.
// You must update code to support NEW and OLD versions.

struct PXPTIFTelestration {
    PXPTIFVersion version;
    PXPTIFByteBlockRef __nonnull sourceName;
    uint16_t width, height;
    uint32_t still;
    uint32_t n_actions;
    PXPTIFActionRef __nonnull *__nullable actions;
};

#pragma mark - Initialization

PXPTIFTelestrationRef __nonnull PXPTIFTelestrationCreate(const char *__nonnull sourceName, uint16_t width, uint16_t height, bool still, const PXPTIFActionRef __nonnull *__nullable actions, uint32_t n_actions)
{
    struct PXPTIFTelestration *telestration = malloc(sizeof(struct PXPTIFTelestration));
    
    telestration->version = PXPTIF_VERSION;
    telestration->sourceName = PXPTIFByteBlockCreateWithUTF8String(sourceName);
    telestration->width = width, telestration->height = height;
    telestration->still = still;
    
    if (actions && n_actions) {
        telestration->n_actions = n_actions;
        telestration->actions = malloc(n_actions * sizeof(PXPTIFActionRef));
        
        for (uint32_t i = 0; i < n_actions; i++) {
            telestration->actions[i] = PXPTIFActionCopy(actions[i]);
        }
        
    } else {
        telestration->n_actions = 0;
        telestration->actions = NULL;
    }
    
    return telestration;
}

#pragma mark - Deinitialization

void PXPTIFTelestrationDestroy(PXPTIFTelestrationRef __nonnull telestration)
{
    PXPTIFByteBlockDestroy(telestration->sourceName);
    for (uint32_t i = 0; i < telestration->n_actions; i++) {
        PXPTIFActionDestroy(telestration->actions[i]);
    }
    free(telestration->actions);
    free(telestration);
}

#pragma mark - Getters

const char *__nonnull PXPTIFTelestrationGetSourceName(PXPTIFTelestrationRef __nonnull telestration)
{
    return PXPTIFByteBlockGetUTF8String(telestration->sourceName);
}

uint16_t PXPTIFTelestrationGetWidth(PXPTIFTelestrationRef __nonnull telestration)
{
    return telestration->width;
}

uint16_t PXPTIFTelestrationGetHeight(PXPTIFTelestrationRef __nonnull telestration)
{
    return telestration->height;
}

bool PXPTIFTelestrationIsStill(PXPTIFTelestrationRef __nonnull telestration)
{
    return telestration->still;
}

const PXPTIFActionRef __nonnull *__nullable PXPTIFTelestrationGetActions(PXPTIFTelestrationRef __nonnull telestration)
{
    return telestration->actions;
}

uint32_t PXPTIFTelestrationGetActionCount(PXPTIFTelestrationRef __nonnull telestration)
{
    return telestration->n_actions;
}

#pragma mark - Serialization

PXPTIFTelestrationRef __nullable PXPTIFTelestrationCreateWithData(const void *__nullable bytes, size_t size)
{
    // the telestration to return.
    struct PXPTIFTelestration *telestration = NULL;
    
    // create a byte buffer from the data.
    PXPTIFByteBufferRef buffer = PXPTIFByteBufferCreate();
    
    // load the bytes to the buffer.
    PXPTIFByteBufferWriteBytes(buffer, bytes, size);
    
    // reset the position to zero.
    PXPTIFByteBufferSetPosition(buffer, 0);
    
    // CHECK IDENTIFIER
    PXPTIFIdentifier identifier;
    PXPTIFByteBufferReadBytes(buffer, &identifier, sizeof(PXPTIFIdentifier));
    
    
    
    if (PXPTIFIdentifierValid(identifier)) {
        // allocate telestration.
        telestration = malloc(sizeof(struct PXPTIFTelestration));
        
        // VERSION FIRST!
        PXPTIFByteBufferReadBytes(buffer, &telestration->version, sizeof(struct PXPTIFVersion));
        
        // VERSION 1.0
        if (PXPTIFVersionEqual(telestration->version, PXPTIFVersionMake(1, 0))) {
            
            // 1) read sourceName.
            telestration->sourceName = PXPTIFByteBlockCopyFromBuffer(buffer);
            
            // 2) read width, height.
            PXPTIFByteBufferReadBytes(buffer, &telestration->width, sizeof(uint16_t));
            PXPTIFByteBufferReadBytes(buffer, &telestration->height, sizeof(uint16_t));
            
            // 3) read still.
            PXPTIFByteBufferReadBytes(buffer, &telestration->still, sizeof(uint32_t));
            
            // 4) read number of actions.
            PXPTIFByteBufferReadBytes(buffer, &telestration->n_actions, sizeof(uint32_t));
            
            // 5) read actions.
            telestration->actions = telestration->n_actions ? malloc(telestration->n_actions * sizeof(PXPTIFActionRef)) : NULL;
            for (uint32_t i = 0; i < telestration->n_actions; i++) {
                // get action block from buffer.
                PXPTIFByteBlockRef actionBlock = PXPTIFByteBlockCopyFromBuffer(buffer);
                
                // copy the data.
                uint32_t size = PXPTIFByteBlockGetSize(actionBlock);
                telestration->actions[i] = malloc(size);
                memcpy(telestration->actions[i], PXPTIFByteBlockGetBytes(actionBlock), size);
                
                // destroy the block.
                PXPTIFByteBlockDestroy(actionBlock);
            }
        }
    }
    
    // destroy the buffer.
    PXPTIFByteBufferDestroy(buffer);
    
    return telestration;
}

void *__nonnull PXPTIFTelestrationGenerateDataRepresentation(PXPTIFTelestrationRef __nonnull telestration, size_t *__nonnull size)
{
    
    // create a byte buffer.
    PXPTIFByteBufferRef buffer = PXPTIFByteBufferCreate();
    
    // WRITE THE INDENTIFIER
    PXPTIFByteBufferWriteBytes(buffer, &kPXPTIFIdentifierValid, sizeof(PXPTIFIdentifier));
    
    // WRITE THE VERSION FIRST!
    PXPTIFByteBufferWriteBytes(buffer, &telestration->version, sizeof(PXPTIFVersion));
    
    // VERSION 1.0
    if (PXPTIFVersionEqual(telestration->version, PXPTIFVersionMake(1, 0))) {
        // write the data for version 1.0
        
        // 1) write sourceName.
        PXPTIFByteBlockWriteToBuffer(telestration->sourceName, buffer);
        
        // 2) write width, height.
        PXPTIFByteBufferWriteBytes(buffer, &telestration->width, sizeof(uint16_t));
        PXPTIFByteBufferWriteBytes(buffer, &telestration->height, sizeof(uint16_t));
        
        // 3) write still.
        PXPTIFByteBufferWriteBytes(buffer, &telestration->still, sizeof(uint32_t));
        
        // 4) write number of actions.
        PXPTIFByteBufferWriteBytes(buffer, &telestration->n_actions, sizeof(uint32_t));
        
        // 5) write actions as byte blocks.
        for (uint32_t i = 0; i < telestration->n_actions; i++) {
            // create a byte block for the action.
            PXPTIFByteBlockRef actionBlock = PXPTIFByteBlockCreateWithBytes(telestration->actions[i], PXPTIFActionGetSize(telestration->actions[i]));
            // write to the buffer.
            PXPTIFByteBlockWriteToBuffer(actionBlock, buffer);
            
            // destroy the action's byte block.
            PXPTIFByteBlockDestroy(actionBlock);
        }
    }
    
    // pass the data.
    *size = PXPTIFByteBufferGetSize(buffer);
    void *bytes = malloc(*size);
    memcpy(bytes, PXPTIFByteBufferGetBuffer(buffer), *size);
    
    // destroy the buffer.
    PXPTIFByteBufferDestroy(buffer);
    
    return bytes;
}