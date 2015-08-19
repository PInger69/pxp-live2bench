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
{
    void * _pipPlayerObserverContext;
}

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
    
    _pipPlayerObserverContext = &_pipPlayerObserverContext;
    
    [_pipView addObserver:self forKeyPath:@"player" options:0 context:_pipPlayerObserverContext];
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

- (void)dealloc {
    [_pipView removeObserver:self forKeyPath:@"player" context:_pipPlayerObserverContext];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _pipPlayerObserverContext) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.player reload];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Overrides

- (void)setFrame:(CGRect)frame {
    if (self.frame.size.width && self.frame.size.height) {
        self.pipView.frame = CGRectMake((frame.size.width / self.frame.size.width) * self.pipView.frame.origin.x, (frame.size.height / self.frame.size.height) * self.pipView.frame.origin.y, frame.size.width / 3.0, frame.size.height / 3.0);
    } else {
        self.pipView.frame = CGRectMake(self.pipView.frame.origin.x, self.pipView.frame.origin.y, frame.size.width / 3.0, frame.size.height / 3.0);
    }
    
    [super setFrame:frame];
}

- (void)setPlayer:(nullable PxpPlayer *)player {
    [super setPlayer:player];
    
    [player.context muteAllButPlayer:player];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        self.pipView.hidden = YES;
        self.pipView.player = nil;
    }
}

#pragma mark - Gesture Recognizers

- (void)pipGestureRecognized:(UITapGestureRecognizer *)recognizer {
    if ([recognizer.view isKindOfClass:[PxpPlayerView class]]) {
        PxpPlayerView *playerView = (PxpPlayerView *)recognizer.view;
        
        if (playerView == self && playerView.player && !self.pipView.player) {
            self.pipView.hidden = NO;
            self.pipView.player = playerView.player;
        } else if (playerView == self || playerView == self.pipView) {
            self.pipView.hidden = YES;
            self.pipView.player = nil;
            
            [self setNeedsDisplay];
            [self.pipView setNeedsDisplay];
        }
    }
    
}

- (void)swapGestureRecognized:(UIGestureRecognizer *)recognizer {
    if ([recognizer.view isKindOfClass:[PxpPlayerView class]]) {
        PxpPlayerView *playerView = (PxpPlayerView *)recognizer.view;
        
        if ((playerView == self || playerView == self.pipView) && self.player && self.pipView.player) {
            PxpPlayer *temp = self.player;
            self.player = self.pipView.player;
            self.pipView.player = temp;
            
            [self setNeedsDisplay];
            [self.pipView setNeedsDisplay];
        }
    }
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
