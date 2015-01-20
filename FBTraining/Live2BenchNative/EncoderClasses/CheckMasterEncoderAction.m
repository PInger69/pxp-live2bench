//
//  CheckMasterEncoderAction.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "CheckMasterEncoderAction.h"

@implementation CheckMasterEncoderAction
{
    EncoderManager * encoderManager;

}
@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;



-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager
{
    self = [super init];
    if (self) {
        encoderManager = aEncoderManager;
    }

    return self;

}

-(void)start
{
    if (encoderManager.masterEncoder) {
        self.isFinished = YES;
    } else {
    
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(found) name:NOTIF_EM_FOUND_MASTER object:nil];
    }
}


-(void)found
{
    self.isSuccess = YES;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_FOUND_MASTER object:nil];
    self.isFinished = YES;
}

-(void)dealloc
{

    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_FOUND_MASTER object:nil];
}

@end
