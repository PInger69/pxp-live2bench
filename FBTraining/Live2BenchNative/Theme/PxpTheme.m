//
//  PxpTheme.m
//  Live2BenchNative
//
//  Created by BC Holmes on 2017-01-04.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "PxpTheme.h"

@implementation PxpTheme

-(void) activate {
    [self activateToggleButtons];
}

-(void) activateToggleButtons {
    UISwitch* proxy = [UISwitch appearance];
    proxy.onTintColor = PRIMARY_APP_COLOR;
    proxy.tintColor = PRIMARY_APP_COLOR;
}

@end
