//
//  VideoControlBar.h
//  QuickTest
//
//  Created by dev on 6/24/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeekButton.h"
#import "Slomo.h"
@interface VideoControlBar : UIView


@property (strong,nonatomic) SeekButton     * seekForward;
@property (strong,nonatomic) SeekButton     * seekBackward;
@property (strong,nonatomic) Slomo          * slomo;
@property (strong,nonatomic) UILabel        * tagEventName;


-(void)setHiddenControls:(BOOL)val;


@end
