//
//  LiveButton.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-03.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CustomButton.h"

@interface LiveButton : CustomButton


@property (nonatomic,assign) BOOL enabled;

-(id)initWithFrame:(CGRect)frame;
-(void)isActive:(BOOL)enabled;
@end
