//
//  ToastObserver.h
//  ToastView
//
//  Created by dev on 2015-01-21.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"





// The main view controller MUST have a strong reference property
// to the Toast Observer
@interface ToastObserver : NSObject

// The easeTime is the time it takes the Toast View to
// ease onto the screen
@property (nonatomic, assign) double easeTime;

// The delayTime is how long the Toast View should pause on
// screen for
@property (nonatomic, assign) double delayTime;

// This boolean value determines whether or not the Toast Observer should
// function, this property could be controlled perhaps as a setting of the
// application
@property (nonatomic, assign) BOOL enabled;

//This is the view where the toastobservers should pop up
@property (weak, nonatomic) UIView *parentView;

// the allowAbleToast Types, check Common.h
@property (assign, nonatomic) toastType toastType;


+(void)allowedTypes:(NSInteger)type;



@end
