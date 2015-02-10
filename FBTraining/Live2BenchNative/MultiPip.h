//
//  MultiPip.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayerItem.h>
#import "Feed.h"

@interface MultiPip : UIView

@property (strong,nonatomic) NSString * context;


-(void)makePips:(NSArray*)listOfFeeds;



-(void)seekTo:(CMTime) time;
-(void)pause;
-(void)live;
-(void)fullScreen;
-(void)normalScreen;




@end
