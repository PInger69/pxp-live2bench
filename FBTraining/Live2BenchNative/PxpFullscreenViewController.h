//
//  PxpFullscreenViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpPlayerMultiViewController.h"
#import "SeekButton.h"
#import "Slomo.h"
#import "PxpFullscreenButton.h"

@interface PxpFullscreenViewController : UIViewController

@property (readonly, strong, nonatomic, nonnull) PxpPlayerMultiViewController *playerViewController;
@property (readonly, strong, nonatomic, nonnull) UIView *topBar;
@property (readonly, strong, nonatomic, nonnull) UIView *bottomBar;
@property (readonly, strong, nonatomic, nonnull) UIView *contentView;

@property (readonly, strong, nonatomic, nonnull) SeekButton *backwardSeekButton;
@property (readonly, strong, nonatomic, nonnull) SeekButton *forwardSeekButton;

@property (readonly, strong, nonatomic, nonnull) Slomo *slomoButton;
@property (readonly, strong, nonatomic, nonnull) PxpFullscreenButton *fullscreenButton;

@property (assign, nonatomic) BOOL hidden;

@property (assign, nonatomic) CGRect targetFrame;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;


@end
