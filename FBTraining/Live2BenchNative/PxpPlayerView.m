//
//  PxpPlayerView.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayerView.h"

@implementation PxpPlayerView

#pragma mark - Getters / Setters

- (nullable PxpPlayerContext *)context {
    return _player.context;
}

- (void)setPlayer:(nullable PxpPlayer *)player {
    if (_player.context != player.context) {
        [self willChangeValueForKey:@"context"];
        _player = player;
        [self didChangeValueForKey:@"context"];
    } else {
        _player = player;
    }
}

- (BOOL)fullView {
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
