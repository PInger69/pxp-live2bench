//
//  ToggleButton.h
//  Live2BenchNative
//
//  Created by dev on 8/27/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterComponentAbstract.h"

@interface ToggleButton : FilterComponentAbstract

- (id)initWithFrame:(CGRect)frame Name:(NSString*)nme AccessLable:(NSString*)aLabel;

-(void)setFilterBlock:(NSString* (^)(NSDictionary*))blk;
@end
