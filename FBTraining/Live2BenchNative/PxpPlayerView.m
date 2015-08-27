//
//  PxpPlayerView.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayerView.h"

#define DEFAULT_PLAYER_VIEW_IDENTIFIER [[NSUUID UUID] UUIDString]

@implementation PxpPlayerView

#pragma mark - Getters / Setters

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _identifier = DEFAULT_PLAYER_VIEW_IDENTIFIER;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlayerHandler:) name:NOTIF_PXP_PLAYER_VIEW_SET_PLAYER object:nil];
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _identifier = [identifier isKindOfClass:[NSString class]] ? identifier : DEFAULT_PLAYER_VIEW_IDENTIFIER;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlayerHandler:) name:NOTIF_PXP_PLAYER_VIEW_SET_PLAYER object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (nullable PxpPlayerContext *)context {
    return _player.context;
}

- (void)setContext:(nullable PxpPlayerContext *)context {
    self.player = context.mainPlayer;
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
    return YES;
}

- (nonnull NSString *)activePlayerName {
    return self.player.name;
}

- (void)switchToContextPlayerNamed:(nonnull NSString *)name {
    self.player = [self.context playerForName:name];
}

- (void)setPlayerHandler:(NSNotification *)notification {
    NSString *identifier = notification.userInfo[@"identifier"];
    PxpPlayer *player = notification.userInfo[@"player"];
    
    if ([identifier isKindOfClass:[NSString class]] && [identifier isEqualToString:self.identifier] && (player == nil || [player isKindOfClass:[PxpPlayer class]])) {
        self.player = player;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
