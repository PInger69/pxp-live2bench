//
//  BottomViewController.h
//  MultipleButtonsWithPopovers
//
//  Created by dev on 2015-01-28.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ButtonViewManager.h"
#import "SegmentedView.h"


@interface ReusableBottomViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *arrayOfAllComponents;
@property (strong, nonatomic) NSMutableArray *arrayOfAllObservers;


-(void) addComponent: (id <AbstractComponentClassProtocol>) component;
//-(void) dealloc;
-(void) compileInformation;


@end
