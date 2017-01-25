//
//  TagListViewController.h
//  Live2Bench
//
//  Created by BC Holmes on 2017-01-17.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CustomTabViewController.h"
#import "PxpFilter.h"
#import "Event.h"

@interface TagListViewController : CustomTabViewController

@property (nonatomic,strong) NSMutableArray* tagsToDisplay; 
@property (nonatomic,weak)  PxpFilter* pxpFilter;

-(void) sortAndDisplayUniqueTags:(NSArray*) tags;
-(void) configurePxpFilter:(Event*) currentEvent;

-(void) showDeletePermissionError;

@end
