//
//  PxpMyClipViewFullscreenViewController.h
//  Live2BenchNative
//
//  Created by andrei on 2015-09-01.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenViewController.h"
#import "PxpRangeModifierButton.h"
#import "PxpBorderLabel.h"
#import "PxpBorderButton.h"
#import "Tag.h"

@interface PxpMyClipViewFullscreenViewController : PxpFullscreenViewController

@property (strong, nonatomic, nullable) Tag *selectedTag;

@property (readonly, strong, nonatomic, nonnull) PxpBorderLabel *currentTagLabel;

@property (readonly, strong, nonatomic, nonnull) PxpBorderButton *previousTagButton;
@property (readonly, strong, nonatomic, nonnull) PxpBorderButton *nextTagButton;

@end
