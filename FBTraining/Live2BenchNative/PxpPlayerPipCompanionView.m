//
//  PxpPlayerPipCompanionView.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-26.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerPipCompanionView.h"

#import "PxpPlayerPipView.h"

@interface PxpPlayerPipCompanionView ()

@property (strong, nonatomic, nonnull) PxpPlayerPipView *pipView;

@end

@implementation PxpPlayerPipCompanionView

- (void)initPipCompanionView {
    _pipView = [[PxpPlayerPipView alloc] init];
    _pipView.hidden = YES;
    
    [self addSubview:_pipView];
    
    UIGestureRecognizer *pipGestureRecognizer = [self createPipGestureRecognizer];
    UIGestureRecognizer *subPipGestureRecognizer = [self createPipGestureRecognizer];
    
    UIGestureRecognizer *swapGestureRecognizer = [self createSwapGestureRecognizer];
    UIGestureRecognizer *subSwapGestureRecognizer = [self createSwapGestureRecognizer];
    
    [swapGestureRecognizer requireGestureRecognizerToFail:pipGestureRecognizer];
    [subSwapGestureRecognizer requireGestureRecognizerToFail:subPipGestureRecognizer];
    
    [self addGestureRecognizer:pipGestureRecognizer];
    [_pipView addGestureRecognizer:subPipGestureRecognizer];
    
    [self addGestureRecognizer:swapGestureRecognizer];
    [_pipView addGestureRecognizer:subPipGestureRecognizer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initPipCompanionView];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPipCompanionView];
    }
    return self;
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.pipView.frame = CGRectMake(self.pipView.frame.origin.x, self.pipView.frame.origin.y, self.bounds.size.width / 3.0, self.bounds.size.height / 3.0);
}

- (void)setPlayer:(nullable PxpPlayer *)player {
    [super setPlayer:player];
    
    [player.context muteAllButPlayer:player];
}

#pragma mark - Gesture Recognizers

- (void)pipGestureRecognized:(UITapGestureRecognizer *)recognizer {
    if ([recognizer.view isKindOfClass:[PxpPlayerView class]]) {
        PxpPlayerView *playerView = (PxpPlayerView *)recognizer.view;
        
        if (playerView == self && playerView.player && !self.pipView.player) {
            self.pipView.player = playerView.player;
            self.pipView.hidden = NO;
        } else if (playerView == self || playerView == self.pipView) {
            self.pipView.hidden = YES;
            self.pipView.player = nil;
        }
    }
    
    [self setNeedsDisplay];
    [self.pipView setNeedsDisplay];
}

- (void)swapGestureRecognized:(UIGestureRecognizer *)recognizer {
    if ([recognizer.view isKindOfClass:[PxpPlayerView class]]) {
        PxpPlayerView *playerView = (PxpPlayerView *)recognizer.view;
        
        if ((playerView == self || playerView == self.pipView) && self.player && self.pipView.player) {
            PxpPlayer *temp = self.player;
            self.player = self.pipView.player;
            self.pipView.player = temp;
        }
    }
    
    [self setNeedsDisplay];
    [self.pipView setNeedsDisplay];
}

#pragma mark - Private Methods

- (nonnull UIGestureRecognizer *)createPipGestureRecognizer {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pipGestureRecognized:)];
    recognizer.numberOfTouchesRequired = 2;
    recognizer.numberOfTapsRequired = 2;
    
    return recognizer;
}

- (nonnull UIGestureRecognizer *)createSwapGestureRecognizer {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapGestureRecognized:)];
    recognizer.numberOfTouchesRequired = 2;
    recognizer.numberOfTapsRequired = 1;
    
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
