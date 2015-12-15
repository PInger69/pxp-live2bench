//
//  PxpReadyPlayerItemOperation.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-19.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpReadyPlayerItemOperation.h"


@implementation PxpReadyPlayerItemOperation
{
    BOOL _finshed;

}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem
{
    self = [super init];
    if (self) {
        self.observedItem = playerItem;
        _finshed = NO;
    }
    return self;
}

-(void)main
{
    if (self.observedItem.status == AVPlayerItemStatusReadyToPlay) {
        [self setFinished:YES];
        self.observedItem = nil;
        return;
    } else {
        [self.observedItem addObserver:self forKeyPath:@"status" options:0 context:NULL];
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem * item = object;
    switch (item.status) {
        case AVPlayerItemStatusReadyToPlay:
            self.success = YES;
            [self.observedItem removeObserver:self forKeyPath:@"status"];
            self.observedItem = nil;
            [self setFinished:YES];
            if (self.delegate) [self.delegate onPlayerOperationItemReady:self];
            break;
        case AVPlayerItemStatusFailed:
            self.success = NO;
            [self.observedItem removeObserver:self forKeyPath:@"status"];
            self.observedItem = nil;
            [self setFinished:YES];
            if (self.delegate) [self.delegate onPlayerOperationItemFail:self];
            break;
        default:
            break;
    }
}

- (void)setFinished:(BOOL)isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    _finshed = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

-(BOOL)finished
{
    return _finshed;
}

-(void)cancel
{
    [self setFinished:YES];
    [super cancel];
}

-(void)dealloc
{
    if (self.observedItem) {
        [self.observedItem removeObserver:self forKeyPath:@"status"];
    }
}

@end
