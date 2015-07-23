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

@property (strong, nonatomic, nonnull) CADisplayLink *displayLink;
@property (strong, nonatomic, nullable) PxpTelestrationRenderer *renderer;

@end

@implementation PxpTelestrationRenderView

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
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
    
    self.renderer = telestration ? [[PxpTelestrationRenderer alloc] initWithTelestration:telestration] : nil;
    self.renderer.timeProvider = self;
}

- (NSTimeInterval)currentTimeInSeconds {
    return self.timeProvider.currentTimeInSeconds;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.renderer renderInContext:UIGraphicsGetCurrentContext() size:self.bounds.size atTime:self.timeProvider ? self.timeProvider.currentTimeInSeconds : INFINITY];
}

- (void)displayLinkAction:(CADisplayLink *)displayLink {
    [self setNeedsDisplay];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    return NO;
}

@end
