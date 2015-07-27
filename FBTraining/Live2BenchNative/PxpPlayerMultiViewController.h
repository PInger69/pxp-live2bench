//
//  PxpPlayerMultiViewController.h
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-07-02.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpPlayerMultiView.h"
#import "PxpTelestrationViewController.h"

@interface PxpPlayerMultiViewController : UIViewController

@property (strong, nonatomic, nullable) PxpPlayerMultiView *multiView;

@property (readonly, strong, nonatomic, nonnull) PxpTelestrationViewController *telestrationViewController;

@end
