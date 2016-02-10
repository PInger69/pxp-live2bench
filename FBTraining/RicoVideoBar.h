//
//  RicoVideoBar.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-02.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PxpPlayerViewController.h"
#import "SeekButton.h"
#import "Slomo.h"
#import "PxpFullscreenButton.h"
#import "Event.h"
#import "PxpRangeModifierButton.h"

IB_DESIGNABLE
@interface RicoVideoBar : UIView

@property (weak, nonatomic, nullable) PxpPlayerViewController *playerViewController;
@property (weak, nonatomic, nullable) Event *event;

@property (strong, nonatomic, nullable) Tag *selectedTag;
-(CGFloat)getSeekSpeed:(nonnull NSString *)direction;

@property (readonly, strong, nonatomic, nonnull) SeekButton *backwardSeekButton;
@property (readonly, strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *tagExtendStartButton;
@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *tagExtendEndButton;

@property (readonly, strong, nonatomic, nonnull) Slomo *slomoButton;
@property (readonly, strong, nonatomic, nonnull) PxpFullscreenButton *fullscreenButton;

@property (assign, nonatomic) BOOL enabled;

- (void)showExtendButton; // show extend start/end buttons
-(void)clear;
@end
