//
//  PxpVideoBar.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PxpPlayerViewController.h"
#import "SeekButton.h"
#import "Slomo.h"
#import "PxpFullscreenButton.h"
#import "Event.h"
#import "PxpRangeModifierButton.h"
#import "RicoPlayerViewController.h"

IB_DESIGNABLE
@interface RicoL2BVideoBar : UIView

//@property (weak, nonatomic, nullable) PxpPlayerViewController *playerViewController;
@property (weak, nonatomic, nullable) RicoPlayerViewController *playerViewController;
@property (weak, nonatomic, nullable) Event *event;

@property (strong, nonatomic, nullable) Tag *selectedTag;
-(CGFloat)getSeekSpeed:(nonnull NSString *)direction;

@property (readonly, strong, nonatomic, nonnull) SeekButton *backwardSeekButton;
@property (readonly, strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *tagExtendStartButton;
@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *tagExtendEndButton;

@property (readonly, strong, nonatomic, nonnull) Slomo *slomoButton;
@property (readonly, strong, nonatomic, nonnull) PxpFullscreenButton *fullscreenButton;

@property (readonly, strong, nonatomic, nonnull) UIButton *frameForward;
@property (readonly, strong, nonatomic, nonnull) UIButton *frameBackward;


@property (assign, nonatomic) BOOL enabled;

- (void)showExtendButton; // show extend start/end buttons
-(void)clear;
@end
