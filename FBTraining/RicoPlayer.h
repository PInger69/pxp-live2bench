//
//  RicoPlayer.h
//  Live2BenchNative
//
//  Created by dev on 2015-11-25.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>
#import "Feed.h"
#import "PxpReadyPlayerItemOperation.h"
#import "RicoPreRollOperation.h"
#import "RicoOperations.h"

#define RICO_PLAYER_ITEM_ERROR @"playerItemFail"

// Notifications
@class RicoPlayer;

@protocol RicoPlayerObserverDelegate <NSObject>

-(void)tick:(RicoPlayer*)player;

@end



@interface RicoPlayer : UIView <RicoPlayerItemOperationDelegate>

extern NSString * const RicoPlayerWillWaitForSynchronizationNotification;
extern NSString * const RicoPlayerDidPlayerItemFailNotification;


@property (weak, nonatomic) id <RicoPlayerObserverDelegate>  delegate;

@property (nonatomic, strong) NSOperationQueue * operationQueue;
@property (nonatomic, strong) Feed  * feed;
@property (nonatomic, strong) RicoReadyPlayerItemOperation  * isReadyOperation;
@property (nonatomic, strong)           NSString            * name;
@property (nonatomic, strong)           NSString            * instanceName;
@property (nonatomic, strong)           AVPlayer            * avPlayer;
@property (nonatomic, strong)           AVPlayerLayer       * avPlayerLayer;
@property (nonatomic, strong)           UITextView          * debugOutput;
@property (nonatomic, strong)           NSMutableDictionary * debugValues;
@property (nonatomic, assign)            BOOL                looping;

@property (nonatomic, assign)            BOOL                syncronized; /// This will dispatch notifications with an operation
@property (nonatomic, assign)            BOOL                waitingForSynchronization;



-(instancetype)initWithFrame:(CGRect)frame;

-(NSOperation*)play;
-(NSOperation*)pause;

-(NSOperation*)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(nullable void (^)(BOOL finished))completionHandler;

-(CMTime)duration;
-(CMTime)currentTime;

-(void)destroy;

-(void)reset;



@end
