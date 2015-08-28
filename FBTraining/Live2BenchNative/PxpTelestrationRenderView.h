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

/// The render view's time provider.
@property (weak, nonatomic, nullable) id<PxpTimeProvider> timeProvider;

/// The telestration rendered in the render view.
@property (strong, nonatomic, nullable) PxpTelestration *telestration;

@end
