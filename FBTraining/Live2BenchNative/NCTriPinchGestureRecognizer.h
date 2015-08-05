//
//  NCTriPinchGestureRecognizer.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCTriPinchGestureRecognizer : UIGestureRecognizer

@property (readonly, assign, nonatomic) CGFloat scale;
@property (readonly, assign, nonatomic) CGFloat velocity;

@end
