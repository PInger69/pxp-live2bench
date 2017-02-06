//
//  Live2BenchViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomTabViewController.h"
#import "Event.h"


@interface RicoLive2BenchViewController : CustomTabViewController
{

}

@property (nonatomic,strong)    Event  * currentEvent;
@property (nonatomic,strong)    UILabel  * gameTimeLabel;
@property (nonatomic,strong)    UIButton  * gameStart;


-(void)updateOnPlayerTick;

@end
