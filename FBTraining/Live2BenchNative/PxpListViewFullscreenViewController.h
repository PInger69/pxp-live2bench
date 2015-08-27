//
//  PxpListViewFullscreenViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenViewController.h"
#import "PxpRangeModifierButton.h"
#import "PxpBorderLabel.h"
#import "PxpBorderButton.h"
#import "Tag.h"

@interface PxpListViewFullscreenViewController : PxpFullscreenViewController

@property (strong, nonatomic, nullable) Tag *selectedTag;

@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *startRangeModifierButton;
@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *endRangeModifierButton;

@property (readonly, strong, nonatomic, nonnull) PxpBorderLabel *currentTagLabel;

@property (readonly, strong, nonatomic, nonnull) PxpBorderButton *previousTagButton;
@property (readonly, strong, nonatomic, nonnull) PxpBorderButton *nextTagButton;

@end
