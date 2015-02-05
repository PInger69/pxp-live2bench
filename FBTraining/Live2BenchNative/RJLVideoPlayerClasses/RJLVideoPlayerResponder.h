//
//  RJLVideoPlayerResponder.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-04.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJLVideoPlayer.h"
@interface RJLVideoPlayerResponder : NSObject

- (instancetype)initWithPlayer:(RJLVideoPlayer*)aPlayer;
-(void)processCommand:(NSDictionary* )dict;
@end
