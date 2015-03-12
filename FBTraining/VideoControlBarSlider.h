//
//  VideoControlBar.h
//  Live2BenchNative
//
//  Created by dev on 9/16/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSlider.h"
@interface VideoControlBarSlider : UIToolbar


@property (strong,nonatomic)    UIBarButtonItem * timeSliderItem;
@property (strong,nonatomic)    OBSlider        * timeSlider;
@property (strong,nonatomic)    UIButton        * playButton;
@property (strong,nonatomic)    UILabel         * leftTimeLabel;
@property (strong,nonatomic)    UILabel         * rightTimeLabel;
@property (assign,nonatomic)    BOOL            enable;



-(void)setupPlay:(SEL)onPlaySel Pause:(SEL)onPauseSel target:(id)target;


@end
