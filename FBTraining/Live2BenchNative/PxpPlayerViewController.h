//
//  PxpPlayerViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpPlayerView.h"
#import "PxpTelestrationViewController.h"

@interface PxpPlayerViewController : UIViewController

@property (readonly, strong, nonatomic, nonnull) PxpPlayerView *playerView;
@property (readonly, strong, nonatomic, nonnull) PxpTelestrationViewController *telestrationViewController;

- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass;

@end
