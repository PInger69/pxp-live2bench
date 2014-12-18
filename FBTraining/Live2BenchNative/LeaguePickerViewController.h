//
//  LeaguePickerViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-04-22.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "AutoScrollLabel.h"
#import "UIFont+Default.h"

@protocol LeaguePickerViewDelegate
- (void)dismissLeaguePicker;
@end

@interface LeaguePickerViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    Globals *globals;
    NSMutableDictionary *sortedLeagueDictionary;
    NSMutableArray *sortedLeagueNames;
}

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,weak) id<LeaguePickerViewDelegate> delegate;
@end
