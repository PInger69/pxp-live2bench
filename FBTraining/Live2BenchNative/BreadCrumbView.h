//
//  BreadCrumbView.h
//  Live2BenchNative
//
//  Created by dev on 7/31/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BreadCrumbView : UIView

- (id)initWithFrame:(CGRect)frame label:(NSString*)label;
- (id)initWithFrame:(CGRect)frame label:(NSString*)label colour:(NSString*)col;


-(float)getWidth;
-(void)setFirst;

@end
