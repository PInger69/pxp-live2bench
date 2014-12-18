//
//  OverlayViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-23.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "BorderButton.h"

@interface OverlayViewController : UIViewController{
    NSString *swipeSide;
    NSMutableDictionary *swipeControlDict;
}


- (id)initWithSide:(NSString*)side;
@end
