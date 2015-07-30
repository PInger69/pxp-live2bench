//
//  PxpFilterTabController.h
//  CWPopupDemo
//
//  Created by colin on 7/30/15.
//  Copyright (c) 2015 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpFilterTabController : UIViewController

@property (nonatomic, retain) NSMutableArray *modules;

@property (weak, nonatomic) PxpFilter *pxpFilter;

@end
