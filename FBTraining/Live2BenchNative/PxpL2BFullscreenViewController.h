//
//  PxpL2BFullscreenViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenViewController.h"
#import "PxpRangeModifierButton.h"
#import "PxpBorderLabel.h"
#import "LiveButton.h"
#import "Tag.h"

@interface PxpL2BFullscreenViewController : PxpFullscreenViewController

@property (readonly, strong, nonatomic, nonnull) LiveButton *liveButton;
@property (readonly, weak, nonatomic) Tag * selectedTag;

@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *startRangeModifierButton;
@property (readonly, strong, nonatomic, nonnull) PxpRangeModifierButton *endRangeModifierButton;

@property (readonly, strong, nonatomic, nonnull) PxpBorderLabel *currentTagLabel;

-(void)usingTag:(Tag*)aTag;
@end
