//
//  LBCloudPlayerView.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/25/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LBCloudPlayerView : UIView


@property (nonatomic, strong) AVPlayer* player;




- (void)setVideoFillMode:(NSString *)fillMode;


@end
