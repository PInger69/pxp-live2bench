//
//  Pip.h
//  Live2BenchNative
//
//  Created by dev on 10/10/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>
#import "Feed.h"
#import "RJLFreezeCounter.h"

typedef NS_OPTIONS (NSInteger,PipStatus){
    PIP_Offline      = 0,
    PIP_Live         = 1<<0,
    PIP_Play         = 1<<1,
    PIP_Stop         = 1<<2,
    PIP_Paused       = 1<<3,
    PIP_Seeking      = 1<<4,
    PIP_Scrubbing    = 1<<5,
    PIP_Slomo        = 1<<6,
    PIP_Error        = 1<<7,
    PIP_Mute         = 1<<8,
    PIP_Looping      = 1<<9,
    PIP_Selected     = 1<<10
};

@interface Pip : UIView  //So it can be used as a key in a Dict


@property (nonatomic, strong)           AVPlayer           * avPlayer;
@property (nonatomic, strong)           AVPlayerLayer      * avPlayerLayer;
@property (nonatomic, strong)           AVPlayerItem       * avPlayerItem;
@property (assign, nonatomic)           BOOL               isDragAble;
@property (assign, nonatomic)           CGRect             dragBounds;
@property (nonatomic, assign)           BOOL               muted;
@property (nonatomic,assign)            BOOL               showFeedLabel;
@property (nonatomic,assign,readonly)   BOOL               hasHighQuality;
@property (nonatomic,assign,readonly)   BOOL               hasLowQuality;
@property (nonatomic,assign)            BOOL               selected;
@property (nonatomic,assign)            int                quality;
@property (nonatomic,strong)            Feed               * feed;
@property (nonatomic,assign)            BOOL                looping;

@property (nonatomic,assign)            PipStatus           status;
@property (nonatomic,strong)            RJLFreezeCounter    * freezeCounter;

+(void)swapPip:(Pip*)thisPip with:(Pip*)thatPip;

-(void)playerURL:(NSURL *)url;
-(void)playWithFeed:(Feed*)aFeed;
-(void)playWithFeed:(Feed*)feed withRange:(CMTimeRange)range;
-(void)prepareWithFeed:(Feed*)aFeed;
-(void)clear;
-(void)play;
-(void)pause;
-(void)seekTo:(CMTime)time;
-(void)live;
-(void)playRate:(float)rate;
-(CMTime)currentTimePosition;
-(void)seekToTime:(CMTime)time completionHandler:(void(^)(BOOL finished) )block;
@end
