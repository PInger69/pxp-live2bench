//
//  ClipControlBarSlider.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSlider.h"

@interface ClipControlBarSlider : UIToolbar


@property (strong,nonatomic)    UIBarButtonItem * timeSliderItem;
@property (strong,nonatomic)    OBSlider        * timeSlider;
@property (strong,nonatomic)    UIButton        * playButton;
@property (strong,nonatomic)    UILabel         * leftClipTimeLabel;
@property (strong,nonatomic)    UILabel         * rightClipTimeLabel;
@property (strong,nonatomic)    UILabel         * leftVideoTimeLabel;
@property (strong,nonatomic)    UILabel         * rightVideoTimeLabel;
@property (assign,nonatomic)    BOOL            enable;
@property (assign, nonatomic) double value;
//@property (assign, nonatomic) double maximumClipTime;
//@property (assign, nonatomic) double minimumClipTime;

-(void)setupPlay:(SEL)onPlaySel Pause:(SEL)onPauseSel onCancelClip: (SEL)cancelClipSel target:(id)target;

@end
