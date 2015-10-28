//
//  PxpPlayerRebooter.h
//  Live2BenchNative
//
//  Created by dev on 2015-10-27.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PxpPlayer.h"
#import "PxpPlayerContext.h"

@interface PxpPlayerRebooter : NSObject
@property (assign, nonatomic) CMTime timeOfFail;

-(instancetype)initWithPlayer:(PxpPlayer*)player;


@end
