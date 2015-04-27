//
//  ScreenController.h
//  Live2BenchNative
//
//  Created by dev on 9/9/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>
#import "PxpVideoPlayerProtocol.h"

#define SCREEN_CONNECTED ([UIScreen screens].count > 1)

@interface ScreenController : NSObject



@property (strong, nonatomic) UIViewController    * viewController;
@property (assign, nonatomic) BOOL      enableDisplay;
@property (assign, nonatomic) BOOL      screenDetected;
@property (assign, nonatomic) BOOL      doesScreenMirroring;

-(id)init;
-(void)moveVideoToExternalDisplay:(UIViewController <PxpVideoPlayerProtocol> *) video;
-(void)returnVideoToPreviousViewFromExternal;
@end
