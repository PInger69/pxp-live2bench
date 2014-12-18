//
//  CalendarViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameSchedule.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "CustomTabViewController.h"
#import "EncoderManager.h"

@class GameScheduleJSONDataSource;

@interface CalendarViewController : CustomTabViewController<UITableViewDelegate, UITextViewDelegate>{
    
    GameScheduleJSONDataSource *gameScheduleJSONDataSource;
    GameSchedule *currentSelectedGame;
    NSString *selectedMonthYear;
    NSString *selectedMonthDate;

}

@property (nonatomic,strong) GameScheduleJSONDataSource *gameScheduleJSONDataSource;

@end
