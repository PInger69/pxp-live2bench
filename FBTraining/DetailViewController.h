//
//  DetailViewController.h
//  Setting
//
//  Created by dev on 2015-01-05.
//  Copyright (c) 2015 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsTableViewController.h"
#import "SwipeableTableViewCell.h"
#import "SettingsViewControllerProtocol.h"

@interface DetailViewController : UITableViewController <SettingsViewControllerProtocol>

//@property (strong, nonatomic) id detailItem;
//@property (weak, nonatomic) SettingsTableViewController *settingsTableViewController;
//@property (nonatomic) int index;
@property (nonatomic, weak) SwipeableTableViewCell *swipeableTableViewCell;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) NSMutableDictionary *dataDictionary;
//@property (strong, nonatomic) NSArray *arrayOfOptions;
//@property (strong, nonatomic) NSMutableArray *arrayOfToggleOptions;

-(instancetype)initViewController;

@end

