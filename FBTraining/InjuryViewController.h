//
//  InjuryViewController.h
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/4/2.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "CustomTabViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "PxpVideoPlayerProtocol.h"
#import "Slomo.h"
#import "CustomButton.h"


@interface InjuryViewController : CustomTabViewController

@property (nonatomic,strong)    UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
@property (nonatomic,strong)    NSString                                     * currentEventName;

@end

