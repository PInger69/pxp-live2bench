//
//  RJLVideoPlayerPlaybackView.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-28.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;
@interface RJLVideoPlayerPlaybackView : UIView


@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
