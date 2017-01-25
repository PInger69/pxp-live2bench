//
//  TagListViewController.m
//  Live2Bench
//
//  Created by BC Holmes on 2017-01-17.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "TagListViewController.h"

#import <TSMessages/TSMessage.h>

#import "Tag.h"
#import "CustomAlertControllerQueue.h"

@implementation TagListViewController


-(void) deleteTag:(Tag*) tag {
    
}

-(BOOL) promptUserToDeleteTag:(Tag*) tag {
    BOOL isYourTag  = [tag.user isEqualToString:[UserCenter getInstance].userHID];
    if (!isYourTag) {
        [self showDeletePermissionError];
        return NO;
    } else {
        // Build Alert
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                       message:@"Are you sure you want to delete this tag?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * action) {
                                                    [self deleteTag:tag];
                                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                 }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction* action) {
                                                     [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                 }]];
        
        return [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    }
}

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
