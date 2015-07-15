//
//  PxpTelestrationViewController.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpTelestrationRenderer.h"

@interface PxpTelestrationViewController : UIViewController

@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;

@property (assign, nonatomic) BOOL showsTelestrationControls;

@property (strong, nonatomic, nullable) PxpTelestration *telestration;

@end
