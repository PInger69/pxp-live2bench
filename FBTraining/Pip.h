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

@interface Pip : UIView <NSCopying> //So it can be used as a key in a Dict


@property (nonatomic, strong)           AVPlayer           * avPlayer;
@property (nonatomic, strong)           AVPlayerLayer      * avPlayerLayer;
@property (nonatomic, strong)           AVPlayerItem       * avPlayerItem;
@property (assign, nonatomic)           BOOL               isDragAble;
@property (assign, nonatomic)           CGRect             dragBounds;
@property (nonatomic, getter=isMuted)   BOOL               muted;
@property (nonatomic,assign)            BOOL               showFeedLabel;
@property (nonatomic,assign,readonly)   BOOL               hasHighQuality;
@property (nonatomic,assign,readonly)   BOOL               hasLowQuality;
@property (nonatomic,assign)            BOOL               selected;
@property (nonatomic,assign)            int                quality;
@property (nonatomic,strong)            Feed               * feed;



+(void)swapPip:(Pip*)thisPip with:(Pip*)thatPip;

-(void)playerURL:(NSURL *)url;
//-(void)playQualityURL:(NSDictionary *)urls;
-(void)playPlayerItem:(AVPlayerItem *) avpi;
-(void)playWithFeed:(Feed*)aFeed;
-(void)prepareWithFeed:(Feed*)aFeed;

-(void)play;
-(void)pause;
-(void)seekTo:(CMTime)time;
-(void)playRate:(float)rate;
-(CMTime)currentTimePosition;
//- (id)copyWithZone:(NSZone *)zone;
@end
