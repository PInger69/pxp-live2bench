//
//  PxpTelestrationRenderView.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationRenderView.h"

#import "PxpTelestrationRenderer.h"

@interface PxpTelestrationRenderView () <PxpTimeProvider>

@end

@implementation PxpTelestrationRenderView
{
    __nonnull PxpTelestrationRenderer *_renderer;
    __nonnull CADisplayLink *_displayLink;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _renderer = [[PxpTelestrationRenderer alloc] initWithTelestration:nil];
        _renderer.timeProvider = self;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        _displayLink.frameInterval = 2;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _renderer = [[PxpTelestrationRenderer alloc] initWithTelestration:nil];
        _renderer.timeProvider = self;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        _displayLink.frameInterval = 2;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)dealloc {
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)setTelestration:(nullable PxpTelestration *)telestration {
    _telestration = telestration;
    
    _renderer.telestration = telestration;
    [self setNeedsDisplay];
}

- (NSTimeInterval)currentTimeInSeconds {
    return _timeProvider.currentTimeInSeconds;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [_renderer renderInContext:UIGraphicsGetCurrentContext() size:self.bounds.size atTime:_timeProvider ? _timeProvider.currentTimeInSeconds : INFINITY];
}

- (void)displayLinkAction:(CADisplayLink *)displayLink {
    if (_telestration) {
        [self setNeedsDisplay];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    return NO;
}

@end
