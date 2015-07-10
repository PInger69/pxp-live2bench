//
//  ARCalendarTableViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-26.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeletableTableViewController.h"
#import "EncoderManager.h"
#import "Event.h"


@interface ARCalendarTableViewController : DeletableTableViewController <EventDelegate>

@property (strong, nonatomic) NSMutableArray *arrayOfAllData;
@property (strong, nonatomic) NSString       *localPath;

@property (strong, nonatomic) NSMutableArray *arrayOfSelectedEvent;

@property (strong, nonatomic) EncoderManager *encoderManager;

-(void)showAllData;

@end
