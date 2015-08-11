//
//  PxpFullscreenButton.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpGlowButton.h"
#import "PxpFullscreenResponder.h"

IB_DESIGNABLE
@interface PxpFullscreenButton : UIButton<PxpFullscreenResponder>

@property (assign, nonatomic) IBInspectable BOOL isFullscreen;

@end
