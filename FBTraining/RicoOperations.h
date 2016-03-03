//
//  RicoOperationsPack.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-01.
//  Copyright © 2015 DEV. All rights reserved.
//
// This class is a abstract base and will hold all other operation


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class RicoPlayer;




@interface RicoOperations : NSOperation

@end




@interface RicoSyncOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
}

-(void)syncComplete;


@end



@interface RicoReadyPlayerItemOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
}
@property (nonatomic,strong) AVPlayerItem * observedItem;
//@property (nonatomic,weak) id <RicoPlayerItemOperationDelegate> delegate;
@property (nonatomic,assign) BOOL * success;

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem;
@end



@interface RicoSeekOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
}

@property (nonatomic,weak) AVPlayer* player;
@property (nonatomic,assign) CMTime  seekToTime;
@property (nonatomic,assign) CMTime  toleranceBefore;
@property (nonatomic,assign) CMTime  toleranceAfter;

@property (nonatomic,assign) BOOL * success;
@property (copy, nonatomic) void(^completionHandler)(BOOL);
- (instancetype)initWithAVPlayer:(AVPlayer*)aPlayer seekToTime:(CMTime)seekTo toleranceBefore:(CMTime)tBefore toleranceAfter:(CMTime)tAfter;


@end


@interface RicoPlayOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
}
@property (nonatomic,assign) BOOL * success;
@property (nonatomic,weak)  RicoPlayer * player;

- (instancetype)initWithRicoPlayer:(RicoPlayer*)player;


@end


