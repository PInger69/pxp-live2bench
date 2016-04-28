//
//  VKAVDecodeManager.m
//  VideoKit
//
//  Created by Murat Sudan
//  Copyright (c) 2014 iOS VideoKit. All rights reserved.
//  Elma DIGITAL
//

#import "VKAVDecodeManager.h"

@implementation VKAVDecodeManager

- (id)init {
    return nil;
}

- (id)initWithUsername:(NSString *)username secret:(NSString *)secret {
#ifdef TRIAL
    _trialBuild = YES;
#else
    _trialBuild = NO;
#endif
    
#ifdef DEBUG
    _debugBuild = YES;
#else
    _debugBuild = NO;
#endif
    
    self = [super initWithUsername:username secret:secret];
    if (self) {
    }
    return self;
}

#ifdef TRIAL
//nothing to do
#else
- (void)startTrialTimer {
}

- (void)stopTrialTimer {
}

- (void)onTimerTrialFired:(NSTimer *)timer {
}
#endif

@end

void show_help_default(const char *opt, const char *arg) {
    
}
