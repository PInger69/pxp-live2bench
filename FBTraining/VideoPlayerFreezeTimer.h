//
//  VideoPlayerFreezeTimer.h
//  Live2BenchNative
//
//  Created by dev on 10/2/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoPlayer;

@interface VideoPlayerFreezeTimer : NSObject

@property (assign,nonatomic) BOOL enable;

-(id)initWithVideoPlayer:(VideoPlayer*)player;

@end
