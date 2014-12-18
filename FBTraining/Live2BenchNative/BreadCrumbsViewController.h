//
//  BreadCrumbsViewController.h
//  Live2BenchNative
//
//  Created by dev on 7/31/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BreadCrumbsViewController : UIViewController

-(id)initWithPoint:(CGPoint)pt;

-(void)inputList:(NSArray *)list;

-(void)clear;


@end
