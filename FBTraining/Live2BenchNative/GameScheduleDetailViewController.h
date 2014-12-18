//
//  GameScheduleDetailViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameSchedule;

@interface GameScheduleDetailViewController : UIViewController{
    
    GameSchedule *gameSchedule;
}

- (id)initWithGameSchedule:(GameSchedule *)gameSchedule;

@end
