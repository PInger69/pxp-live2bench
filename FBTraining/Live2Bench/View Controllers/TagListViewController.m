//
//  TagListViewController.m
//  Live2Bench
//
//  Created by BC Holmes on 2017-01-17.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "TagListViewController.h"

#import <TSMessages/TSMessage.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "CustomAlertControllerQueue.h"
#import "EncoderManager.h"
#import "EncoderProtocol.h"
#import "Tag.h"

@interface TagListViewController()
    
@end

@implementation TagListViewController


-(instancetype) initWithAppDelegate:(AppDelegate *)appDel {
    if (self = [super initWithAppDelegate:appDel]) {
        self.allTagsArray   = [NSMutableArray array];
        self.tagsToDisplay  = [NSMutableArray array];
        self.deleteTagIds = [NSMutableSet new];
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"TagListViewController viewWillAppear");
    self.pxpFilter = _appDel.sharedFilter;
    NSLog(@"pxpFilter is %@", self.pxpFilter == nil ? @"nil" : @"not nil");
    [self connectToEncoder];

    [self assignCurrentEvent:_appDel.encoderManager.primaryEncoder.event];
}

-(void) assignCurrentEvent:(Event*) event {
    self.currentEvent = event;
}

-(void) connectToEncoder {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];

}

-(void) loadAndDisplayTags {
    self.allTagsArray = [NSMutableArray arrayWithArray:[self.currentEvent.tags copy]];
    [self.pxpFilter filterTags:self.allTagsArray];
    [self sortAndDisplayUniqueTags:self.pxpFilter.filteredTags];
}


-(void) addEventObserver:(NSNotification*) notification {
    
}

-(BOOL) promptUserToDeleteTag:(Tag*) tag {
    if (![self isDeletableTag:tag]) {
        [self showDeletePermissionError];
        return NO;
    } else {
        // Build Alert
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                       message:@"Are you sure you want to delete this tag?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * action) {
                                                    [self deleteTag:tag];
                                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                 }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
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
    NSLog(@"number of items in the unique list %lu", (unsigned long) uniqueList.count);
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayTime" ascending:NO selector:@selector(compare:)];
    [self.tagsToDisplay removeAllObjects];
    [self.tagsToDisplay addObjectsFromArray:
        [NSMutableArray arrayWithArray:[[uniqueList allObjects] sortedArrayUsingDescriptors:@[sorter]]]];
}

#pragma mark - Delete tags

-(BOOL) isDeletableTag:(Tag*) tag {
    return YES;
}

-(void) deleteAllSelectedTags {
    
    NSMutableArray* tagsToDelete = [NSMutableArray new];
    for (Tag* tag in [self.allTagsArray copy]) {
        if ([self isDeletableTag:tag] && [self.deleteTagIds containsObject:tag.ID]) {
            [tagsToDelete addObject:tag];
        }
    }
    
    if (tagsToDelete.count == 0) {
        [TSMessage showNotificationInViewController: self.parentViewController
                                              title:@"Can't delete other users' tags"
                                           subtitle:@"None of these tags can be deleted because you don't own them"
                                               type:TSMessageNotificationTypeWarning
                                           duration:3];
    } else {
        [self promptUserToDeleteMultipleTags:^() {
            [self deleteTagList:tagsToDelete];
        }];
        if (tagsToDelete.count < self.deleteTagIds.count) {
            [TSMessage showNotificationInViewController: self.parentViewController
                                                  title:@"Can't delete other users' tags"
                                               subtitle:@"Some tags can't be deleted because you don't own them"
                                                   type:TSMessageNotificationTypeWarning
                                               duration:3];
        }
    }
}

-(void) deleteTagList:(NSArray*) tags {
    [self.allTagsArray removeObjectsInArray:tags];
    [self.tagsToDisplay removeObjectsInArray:tags];    
    for (Tag* tag in tags) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
    }
}


-(void) promptUserToDeleteMultipleTags:(void(^)()) deleteAction {
    // Build Alert
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                    message:@"Are you sure you want to delete all these tags?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * action) {
         deleteAction();
         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
     }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
     }]];
    
    BOOL isIndecisive = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    
    if (!isIndecisive) {
        [self showOrHideDeleteAllButton];
    }
    
}

-(void) deleteTag:(Tag*) tag {
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
}


-(void) showDeletePermissionError {
    [TSMessage showNotificationInViewController: self.parentViewController
                                          title:@"myplayXplay"
                                       subtitle:@"You can't delete someone else's tag"
                                           type:TSMessageNotificationTypeWarning
                                       duration:3];
}


-(void) showOrHideDeleteAllButton {
    if (self.deleteTagIds.count < 2){
        [self hideDeleteAllButton];
    } else {
        [self showDeleteAllButton];
    }
}

-(void) showDeleteAllButton {
    
}

-(void) hideDeleteAllButton {
    
}

#pragma mark - PxpFilter-related methods

-(void) pressFilterButton {
    //    [_tableViewController collaspOpenCell];
    
    //    [self.pxpFilter filterTags:[self.allTags copy]];
    TabView *popupTabBar = [TabView sharedFilterTabBar];
    Profession * profession = [ProfessionMap getProfession:self.currentEvent.eventType];
    [TabView sharedDefaultFilterTab].telestrationLabel.text = profession.telestrationTagName;
    
    
    // setFilter to this view. This is the default filtering for ListView
    // what ever is added to these predicates will be ignored in the filters raw tags
    self.pxpFilter.delegate = self;
    
    if (popupTabBar.isViewLoaded)
    {
        popupTabBar.view.frame =  CGRectMake(0, 0, popupTabBar.preferredContentSize.width,popupTabBar.preferredContentSize.height);
    }
    
    popupTabBar.modalPresentationStyle  = UIModalPresentationPopover; // Might have to make it custom if we want the fade darker
    popupTabBar.preferredContentSize    = popupTabBar.view.bounds.size;
    
    
    UIPopoverPresentationController *presentationController = [popupTabBar popoverPresentationController];
    presentationController.sourceRect               = [[UIScreen mainScreen] bounds];
    presentationController.sourceView               = self.view;
    presentationController.permittedArrowDirections = 0;
    
    [self presentViewController:popupTabBar animated:YES completion:nil];
    
    
    [self.pxpFilter filterTags:[self.allTagsArray copy]];
    
    // BCH: what does this do?
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DISABLE_TELE_FILTER object:self];
    
}

-(void)onFilterComplete:(PxpFilter*)filter
{
    if (!filter || !filter.filteredTags ) {
        return ;
    }
    [self sortAndDisplayUniqueTags:filter.filteredTags];
}

-(void)onFilterChange:(PxpFilter *)filter
{
    [self.pxpFilter filterTags:self.allTagsArray];
    [self sortAndDisplayUniqueTags:filter.filteredTags];
}

@end
