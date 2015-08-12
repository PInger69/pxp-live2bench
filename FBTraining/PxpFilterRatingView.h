//
//  PxpFilterRatingView.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpFilterRatingView : UIView <PxpFilterModuleProtocol>


@property (nonatomic, weak) PxpFilter *parentFilter;


-(void)buildButtons;


@end
