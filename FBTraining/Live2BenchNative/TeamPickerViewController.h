//
//  TeamPickerViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-04-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "AutoScrollLabel.h"
#import "UIFont+Default.h"

@protocol TeamPickerViewDelegate
- (void)dismissTeamPicker;
@end

@interface TeamPickerViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    Globals *globals;
    NSMutableArray *sortedTeamNames;
    NSMutableDictionary *sortedTeamDictionary;
}

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,weak) id<TeamPickerViewDelegate> delegate;
@end
