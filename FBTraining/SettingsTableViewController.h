//
//  SettingsTableViewController.h
//  Setting
//
//  Created by dev on 2015-01-05.
//  Copyright (c) 2015 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeableTableViewCell.h"


@protocol SettingsTableViewControllerSelectDelegate <NSObject>

-(void)selectedSettingDefinition:(NSDictionary*)definition;

@end




@class DetailViewController;

@interface SettingsTableViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, weak) UINavigationController *navigationController;

@property (nonatomic, weak) id<SettingsTableViewControllerSelectDelegate> selectDelegate;

- (instancetype)initWithSettingDefinitions:(NSArray *)definitions settings:(NSMutableDictionary *)settings;

- (void) buttonOneActionForItemText:(NSString *)itemText;
- (void) buttonTwoActionForItemText:(NSString *)itemText;
- (void) switchStateSignal:(BOOL)onOrOff fromCell: (id) theCell;

- (void) selectCellAtIndexPath: (NSIndexPath *) indexPath;

@end

