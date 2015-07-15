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
        self.clearsContextBeforeDrawing = NO;
        self.backgroundColor = nil;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = NO;
        self.clearsContextBeforeDrawing = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
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

- (NSTimeInterval)currentTime {
    return self.timeProvider.currentTime;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.renderer renderInContext:UIGraphicsGetCurrentContext() size:self.bounds.size atTime:self.timeProvider ? self.timeProvider.currentTime : INFINITY];
}

- (void)displayLinkAction:(CADisplayLink *)displayLink {
    [self.layer setNeedsDisplay];
}

@end
