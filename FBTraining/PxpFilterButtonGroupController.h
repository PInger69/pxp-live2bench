//
//  PxpFilterButtonGroupController.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpFilter.h"
#import "PxpFilterButtonGroupControllerDelegate.h"



@interface PxpFilterButtonGroupController : NSObject <PxpFilterModuleProtocol,PxpFilterButtonGroupControllerDelegate>


#pragma mark - PxpFilterModuleProtocol Methods

@property (nonatomic,weak) PxpFilter * parentFilter;

-(void)filterTags:(NSMutableArray *)tagsToFilter;
-(void)reset;


#pragma mark - PxpFilterButtonGroupControllerDelegate Methods

-(void)addButtonToGroup:(PxpFilterButton*)button;

@property


@end
