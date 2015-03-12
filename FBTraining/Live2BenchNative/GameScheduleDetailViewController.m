//
//  GameScheduleDetailViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "GameScheduleDetailViewController.h"
#import "GameSchedule.h"

@implementation GameScheduleDetailViewController

- (id)initWithGameSchedule:(GameSchedule *)aGameSchedule
{
    if ((self = [super init])) {
        
        gameSchedule = aGameSchedule;
    }
    return self;
}

- (void)loadView
{
//    UILabel *label = [[UILabel alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
//    label.text = [NSString stringWithFormat:@"%@ - %@", gameSchedule.time, gameSchedule.teamName];
//    self.view = label;
}



@end
