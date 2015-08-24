//
//  PxpPlayerMultiView.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-29.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerMultiView.h"

@interface PxpPlayerMultiView () <PxpPlayerGridViewDelegate>

@end

@implementation PxpPlayerMultiView

- (void)initMultiView {
    
    _gridView = [[PxpPlayerGridView alloc] init];
    _companionView = [[PxpPlayerPipCompanionView alloc] init];
    
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _companionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _gridView.delegate = self;
    _companionView.delegate = self;
    
    _gridView.hidden = YES;
    
    _companionView.tapToAdvanceEnabled = NO;
    _companionView.hidden = NO;
    
    [_companionView addGestureRecognizer:[self createFocusGestureRecognizer]];
    
    [self addSubview:_gridView];
    [self addSubview:_companionView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initMultiView];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initMultiView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gridView.frame = self.bounds;
    self.companionView.frame = self.bounds;
}

#pragma mark - Getters / Setters

- (void)setPlayer:(PxpPlayer *)player {
    [super setPlayer:player];
    
    self.companionView.player = player;
    self.companionView.hidden = NO;
    
    self.gridView.hidden = YES;
    self.gridView.player = nil;
    [self.context.mainPlayer sync];
    
    [self.delegate playerView:self changedFullViewStatus:self.fullView];
}

- (nonnull NSString *)activePlayerName {
    return self.companionView.player ? self.companionView.player.name : [super activePlayerName];
}

- (BOOL)fullView {
    return [super fullView] && (_gridView.hidden ? _companionView.fullView : _gridView.fullView);
}

- (void)setLockFullView:(BOOL)lockFullView {
    [super setLockFullView:lockFullView];
    [_companionView setLockFullView:lockFullView];
    [_gridView setLockFullView:lockFullView];
    
    if (lockFullView && !_companionView.player) {
        _companionView.player = self.context.mainPlayer;
        _companionView.hidden = NO;
        
        _gridView.hidden = YES;
        _gridView.player = nil;
        [self.context.mainPlayer sync];
        
        [self.delegate playerView:self changedFullViewStatus:self.fullView];
        
       [_companionView.player reload];
    }
}

#pragma mark - PxpPlayerGridViewDelegate

- (void)playerView:(nonnull PxpPlayerSingleView *)playerView didLoadInGridView:(nonnull PxpPlayerGridView *)gridView {
    [playerView addGestureRecognizer:[self createFocusGestureRecognizer]];
}

- (void)playerView:(nonnull PxpPlayerSingleView *)playerView didUnloadInGridView:(nonnull PxpPlayerGridView *)gridView {
    
}

- (void)playerView:(nonnull PxpPlayerView *)playerView changedFullViewStatus:(BOOL)fullView {
    [self.delegate playerView:self changedFullViewStatus:self.fullView];
}

#pragma mark - Gesture Recognizers

- (void)focusGestureRecognized:(UIGestureRecognizer *)recognizer {
    if ([recognizer.view isKindOfClass:[PxpPlayerSingleView class]] && !self.lockFullView) {
        PxpPlayerSingleView *playerView = (PxpPlayerSingleView *)recognizer.view;
        
        
        if (playerView == self.companionView && self.companionView.player /* && self.context.players.count > 1 */) {
            
            PxpPlayer *player = self.companionView.player;
            
            self.companionView.hidden = YES;
            self.companionView.player = nil;
            
            self.gridView.hidden = NO;
            self.gridView.player = player;
            
            [self.delegate playerView:self changedFullViewStatus:self.fullView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                for (PxpPlayer *p in self.context.players) {
                    if (p != player) {
                        [p reload];
                    }
                }
            });
            
        } else if (playerView.player && !self.companionView.player) {
            
            PxpPlayer *player = playerView.player;
            
            self.gridView.player = nil;
            self.gridView.hidden = YES;
            
            self.companionView.player = player;
            self.companionView.hidden = NO;
            
            
            [self.context.mainPlayer sync];
            
            
            [self.delegate playerView:self changedFullViewStatus:self.fullView];
            [player reload];
        }
        
    }
    
}

#pragma mark - Private Methods

- (nonnull UIGestureRecognizer *)createFocusGestureRecognizer {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGestureRecognized:)];
    recognizer.numberOfTouchesRequired = 1;
    recognizer.numberOfTapsRequired = 2;
    
    return recognizer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
