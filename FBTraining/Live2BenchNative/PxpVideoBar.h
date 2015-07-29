//
//  PxpVideoBar.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SeekButton.h"
#import "Slomo.h"

@interface PxpVideoBar : UIView

@property (readonly, strong, nonatomic, nonnull) SeekButton *backwardSeekButton;
@property (readonly, strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

@property (readonly, strong, nonatomic, nonnull) Slomo *slomoButton;

@end
