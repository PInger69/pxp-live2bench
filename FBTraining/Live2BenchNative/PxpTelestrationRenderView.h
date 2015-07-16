//
//  PxpTelestrationRenderView.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpTelestrationRenderer.h"

@interface PxpTelestrationRenderView : UIView

@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;
@property (strong, nonatomic, nullable) PxpTelestration *telestration;

@end
