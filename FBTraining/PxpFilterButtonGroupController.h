//
//  PxpFilterButtonGroupController.h
//  Live2BenchNative
//
//  Created by dev on 2015-08-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpFilter.h"
#import "PxpFilterModuleDelegate.h"
@class PxpFilterButton;


@interface PxpFilterButtonGroupController : UIView <PxpFilterModuleProtocol,PxpFilterModuleDelegate>


#pragma mark - PxpFilterModuleProtocol Methods

@property (nonatomic,weak) PxpFilter * parentFilter;
@property (nonatomic,assign) BOOL displayAllTagIfAllFilterOn;

-(void)filterTags:(NSMutableArray *)tagsToFilter;
-(void)reset;


#pragma mark - PxpFilterModuleDelegate Methods

-(void)addButtonToGroup:(PxpFilterButton*)button;
-(void)onUserInput:(id)inputObject;



@end
