//
//  SettingsTableViewController.h
//  Setting
//
//  Created by dev on 2015-01-05.
//  Copyright (c) 2015 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeableTableViewCell.h"

//@protocol SettingsTableDelegate <NSObject>
//
//// This protocol is used to send messages back to the MainViewController
//- (void)settingChanged: (NSDictionary *) settingChangeDictionary fromCell: (id) swipeableTableCell;
//
//@end

@class DetailViewController;

@interface SettingsTableViewController : UITableViewController

//@property (nonatomic, weak) id <SettingsTableDelegate> signalReciever;
@property (strong, nonatomic) DetailViewController *detailViewController;
//@property (strong, nonatomic) NSMutableArray *arrayWithSettingOptionChosen;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, weak) UINavigationController *navigationController;

- (instancetype)initWithSettingDefinitions:(NSArray *)definitions settings:(NSMutableDictionary *)settings;

- (void) settingChangedInDetailViewController: (DetailViewController *)detailView withSignal: (NSDictionary *) settingDictionary;
//- (void) choseCellWithString: (NSString*)optionLabel;
//- (void) specificSettingChosen: (NSString *) theSetting fromCell: (SwipeableTableViewCell *)theCell;
- (void) buttonOneActionForItemText:(NSString *)itemText;
- (void) buttonTwoActionForItemText:(NSString *)itemText;
- (void) switchStateSignal:(BOOL)onOrOff fromCell: (id) theCell;
//- (void) specificSettingChosen: (NSString *) theSetting;
//- (void) inputDictionary: (NSDictionary *) inputDict;
//- (NSDictionary *) outputDictionary;
- (void) selectCellAtIndexPath: (NSIndexPath *) indexPath;

@end

