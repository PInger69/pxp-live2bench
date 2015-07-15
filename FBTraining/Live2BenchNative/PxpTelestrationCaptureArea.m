//
//  PxpTelestrationCaptureArea.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestrationCaptureArea.h"

@interface PxpTelestrationCaptureArea ()

@property (strong, nonatomic, nullable) PxpTelestration *telestration;
@property (readonly, strong, nonatomic, nullable) PxpTelestrationAction *action;

@end

@implementation PxpTelestrationCaptureArea

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _telestration = nil;
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _telestration = nil;
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

#pragma mark - Touch Events

- (void)touchesBegan:(nonnull NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self pushAction];
    [self reportTouch:touches.anyObject];
}

- (void)touchesMoved:(nonnull NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self reportTouch:touches.anyObject];
}

- (void)touchesEnded:(nonnull NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self reportTouch:touches.anyObject];
}

- (void)touchesCancelled:(nullable NSSet *)touches withEvent:(nullable UIEvent *)event {
    [self reportTouch:touches.anyObject];
}

#pragma mark - Getters / Setters

- (nullable PxpTelestrationAction *)action {
    return self.telestration.actionStack.lastObject;
}

- (void)setCaptureEnabled:(BOOL)captureEnabled {
    self.userInteractionEnabled = captureEnabled;
}

- (BOOL)captureEnabled {
    return self.userInteractionEnabled;
}

#pragma mark - Public Methods

- (void)bindTelestration:(nullable PxpTelestration *)telestration {
    self.telestration = telestration;
}

- (void)pushAction {
    PxpTelestrationAction *action = [[PxpTelestrationAction alloc] init];
    action.strokeColor = self.delegate ? [self.delegate strokeColorInCaptureArea:self] : [UIColor colorWithHue:1.0 saturation:1.0 brightness:1.0 alpha:1.0];
    action.strokeWidth = self.delegate ? [self.delegate strokeWidthInCaptureArea:self] : 5.0;
    action.type = self.delegate ? [self.delegate actionTypeInCaptureArea:self] : 0;
    [self.telestration pushAction: action];
}

- (void)popAction {
    [self.telestration popAction];
}

#pragma mark - Private Methods

- (void)reportTouch:(nullable UITouch *)touch {
    if (self.telestration && touch) {
        // get the touch's location in the cature area.
        CGPoint location = [touch locationInView:self];
        
        // get capture time.
        NSTimeInterval time = self.timeProvider ? self.timeProvider.currentTime : 0.0;
        
        // add the point to the action.
        [self.action addPoint:[[PxpTelestrationPoint alloc] initWithPosition:location displayTime:time]];
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
