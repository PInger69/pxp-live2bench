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
    _context = [PxpPlayerContext context];
    
    _gridView = [[PxpPlayerGridView alloc] init];
    _companionView = [[PxpPlayerPipCompanionView alloc] init];
    
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _companionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _gridView.delegate = self;

    _companionView.tapToAdvanceEnabled = NO;
    
    _companionView.hidden = YES;
    
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

- (void)dealloc {
    
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gridView.frame = self.bounds;
    self.companionView.frame = self.bounds;
}

#pragma mark - Getters / Setters

- (void)setContext:(nonnull PxpPlayerContext *)context {
    _context = context;
    
    self.gridView.context = context;
    self.gridView.hidden = YES;
    
    self.companionView.context = context;
    self.companionView.hidden = NO;
}

- (void)setPlayer:(PxpPlayer *)player {
    if (self.context != player.context) {
        self.context = player.context;
    }
    
    self.companionView.player = player;
    self.companionView.hidden = NO;
    
    self.gridView.hidden = YES;
    [self.context.mainPlayer sync];
}

- (nullable PxpPlayer *)player {
    return self.companionView.player;
}

#pragma mark - PxpPlayerGridViewDelegate

- (void)playerView:(nonnull PxpPlayerView *)playerView didLoadInGridView:(nonnull PxpPlayerGridView *)gridView {
    [playerView addGestureRecognizer:[self createFocusGestureRecognizer]];
}

- (void)playerView:(nonnull PxpPlayerView *)playerView didUnloadInGridView:(nonnull PxpPlayerGridView *)gridView {
    
}

#pragma mark - Gesture Recognizers

- (void)focusGestureRecognized:(UIGestureRecognizer *)recognizer {
    if ([recognizer.view isKindOfClass:[PxpPlayerView class]]) {
        PxpPlayerView *playerView = (PxpPlayerView *)recognizer.view;
        
        if (playerView == self.companionView && self.companionView.player && self.context.players.count > 1) {
            self.gridView.hidden = NO;
            
            self.companionView.hidden = YES;
            self.companionView.player = nil;
            
            [self.context.mainPlayer sync];
        } else if (playerView.player && !self.companionView.player) {
            self.companionView.player = playerView.player;
            self.companionView.hidden = NO;
            
            self.gridView.hidden = YES;
            [self.context.mainPlayer sync];
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
