//
//  PxpFilterTabController.h
//  Test12
//
//  Created by colin on 7/30/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpFilterTabController : UIViewController

@property (strong, nonatomic, nonnull)  NSMutableArray *modules;

@property (weak, nonatomic) PxpFilter *pxpFilter;

@property (readonly, strong, nonatomic, nullable) UIImage *tabImage;

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil tabImage:(nullable UIImage *)tabImage;

- (void)show;
- (void)hide;


@end
