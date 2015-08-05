//
//  PxpVideoBar.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PxpTimeProvider.h"
#import "SeekButton.h"
#import "Slomo.h"
#import "Event.h"

IB_DESIGNABLE
@interface PxpVideoBar : UIView

@property (weak, nonatomic, nullable) AVPlayer *player;
@property (weak, nonatomic, nullable) Event *event;

@property (strong, nonatomic, nullable) Tag *selectedTag;
-(CGFloat)getSeekSpeed:(nonnull NSString *)direction;

@end
