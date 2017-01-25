//
//  PxpReadyPlayerItemOperation.h
//  Live2BenchNative
//
//  Created by dev on 2015-11-19.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class PxpReadyPlayerItemOperation;

@protocol RicoPlayerItemOperationDelegate <NSObject>

-(void)onPlayerOperationItemFail:(PxpReadyPlayerItemOperation*) operation;
-(void)onPlayerOperationItemReady:(PxpReadyPlayerItemOperation*) operation;

@end



@interface PxpReadyPlayerItemOperation : NSOperation

@property (nonatomic,weak) AVPlayerItem * observedItem;
@property (nonatomic,weak) id <RicoPlayerItemOperationDelegate> delegate;
@property (nonatomic,assign) BOOL success;

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem;

@end
