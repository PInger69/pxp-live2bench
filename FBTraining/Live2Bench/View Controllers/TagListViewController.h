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

@interface TagListViewController : CustomTabViewController<PxpFilterDelegate>

@property (nonatomic, strong) NSMutableArray* tagsToDisplay;
@property (nonatomic, weak) PxpFilter* pxpFilter;
@property (nonatomic, strong) Event* currentEvent;
@property (nonatomic,strong) NSMutableArray* allTagsArray;
@property (strong, nonatomic) NSMutableSet* deleteTagIds;

-(void) sortAndDisplayUniqueTags:(NSArray*) tags;
-(void) configurePxpFilter:(Event*) currentEvent;

-(void) showDeletePermissionError;
-(BOOL) promptUserToDeleteTag:(Tag*) tag;
-(void) deleteTag:(Tag*) tag;
-(void) loadAndDisplayTags;

-(void) pressFilterButton;

// delete functionality
-(void) showDeleteAllButton;
-(void) hideDeleteAllButton;
-(void) showOrHideDeleteAllButton;
-(void) deleteAllSelectedTags;
-(void) deleteTagList:(NSArray*) tags;
@end
