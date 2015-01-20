//
//  CheckWiFiAction.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "CheckWiFiAction.h"


@implementation CheckWiFiAction
{

    EncoderManager * encoderMangager;
}
@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;

-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager
{
    self = [super init];
    if (self) {
        encoderMangager = aEncoderManager;
    }
    return self;
}

-(void)start {
    self.isSuccess = encoderMangager.hasWiFi;
    self.isFinished = YES;
}

@end
