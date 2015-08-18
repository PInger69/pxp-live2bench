//
//  PxpFilterButton.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilterModuleDelegate.h"

@interface PxpFilterButton : UIButton
@property (strong,nonatomic,nullable)NSPredicate *ownPredicate;
@property (weak,nonatomic)id<PxpFilterModuleDelegate> ownDelegate;

@end
