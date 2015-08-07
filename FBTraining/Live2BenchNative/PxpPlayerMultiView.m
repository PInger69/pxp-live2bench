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
{
    void *_fullViewObserver;
}

@synthesize fullView = _fullView;

- (void)initMultiView {
    
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
    
    _fullViewObserver = &_fullViewObserver;
    
    [self addObserver:_companionView forKeyPath:@"fullView" options:0 context:_fullViewObserver];
}

- (void)dealloc {
    [self removeObserver:_companionView forKeyPath:@"fullView" context:_fullViewObserver];
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

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _fullViewObserver) {
        if (!_companionView.hidden) {
            [self willChangeValueForKey:@"fullView"];
            _fullView = _companionView.fullView;
            [self didChangeValueForKey:@"fullView"];
        }
    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getters / Setters

- (void)setPlayer:(PxpPlayer *)player {
    [super setPlayer:player];
    
    self.companionView.player = player;
    self.companionView.hidden = NO;
    
    self.gridView.hidden = YES;
    [self.context.mainPlayer sync];
    
    [self willChangeValueForKey:@"fullView"];
    _fullView = _companionView.fullView;
    [self didChangeValueForKey:@"fullView"];
}

#pragma mark - PxpPlayerGridViewDelegate

- (void)playerView:(nonnull PxpPlayerSingleView *)playerView didLoadInGridView:(nonnull PxpPlayerGridView *)gridView {
    [playerView addGestureRecognizer:[self createFocusGestureRecognizer]];
}

- (void)playerView:(nonnull PxpPlayerSingleView *)playerView didUnloadInGridView:(nonnull PxpPlayerGridView *)gridView {
    
}

#pragma mark - Gesture Recognizers

- (void)focusGestureRecognized:(UIGestureRecognizer *)recognizer {
    if ([recognizer.view isKindOfClass:[PxpPlayerSingleView class]]) {
        PxpPlayerSingleView *playerView = (PxpPlayerSingleView *)recognizer.view;
        
        if (playerView == self.companionView && self.companionView.player && self.context.players.count > 1) {
            self.gridView.hidden = NO;
            
            self.companionView.hidden = YES;
            self.companionView.player = nil;
            
            [self.context.mainPlayer sync];
            
            [self willChangeValueForKey:@"fullView"];
            _fullView = _gridView.fullView;
            [self didChangeValueForKey:@"fullView"];
            
        } else if (playerView.player && !self.companionView.player) {
            self.companionView.player = playerView.player;
            self.companionView.hidden = NO;
            
            self.gridView.hidden = YES;
            [self.context.mainPlayer sync];
            
            [self willChangeValueForKey:@"fullView"];
            _fullView = _companionView.fullView;
            [self didChangeValueForKey:@"fullView"];
            
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
