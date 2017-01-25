//
//  TagListViewController.m
//  Live2Bench
//
//  Created by BC Holmes on 2017-01-17.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "TagListViewController.h"

#import <TSMessages/TSMessage.h>

@implementation TagListViewController


-(void) configurePxpFilter:(Event*) currentEvent {
    [self.pxpFilter removeAllPredicates];
    
    
    Profession* profession = [ProfessionMap getProfession:currentEvent.eventType];// should be the events sport //
    if (currentEvent) {
        if (![self.pxpFilter.ghostPredicates containsObject:profession.invisiblePredicate] && profession.invisiblePredicate){
            [self.pxpFilter.ghostPredicates addObject:profession.invisiblePredicate];
        }
        
        
        
        
        
        NSMutableArray * filters = [NSMutableArray new];
        
        
        [filters addObjectsFromArray:@[
                                       [NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeNormal]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeCloseDuration]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeCloseDurationOLD]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeFootballDownTags]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStop]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeTele ]
                                       ]];
        
        if (profession && profession.filterPredicate )[filters addObject:profession.filterPredicate];
        
        
        NSPredicate *allowThese = [NSCompoundPredicate orPredicateWithSubpredicates:filters];
        
        [self.pxpFilter addPredicates:@[allowThese]];
        
    }
}


-(void) sortAndDisplayUniqueTags:(NSArray*) tags {
    NSMutableSet * uniqueList = [NSMutableSet new];
    [uniqueList addObjectsFromArray:tags];
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayTime" ascending:NO selector:@selector(compare:)];
    [self.tagsToDisplay removeAllObjects];
    [self.tagsToDisplay addObjectsFromArray:
        [NSMutableArray arrayWithArray:[[uniqueList allObjects] sortedArrayUsingDescriptors:@[sorter]]]];
}

-(void) showDeletePermissionError {
    [TSMessage showNotificationWithTitle:@"myplayXplay"
                                subtitle:@"You can't delete someone else's tag"
                                    type:TSMessageNotificationTypeError];
}




@end
