//
//  TwoButton&Toggo.h
//  Setting
//
//  Created by dev on 2015-01-06.
//  Copyright (c) 2015 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderlessButton.h"


@protocol SwipeableCellDelegate <NSObject>
// This protocol is used to send messages
- (void)buttonOneActionForItemText:(NSString *)itemText;
- (void)buttonTwoActionForItemText:(NSString *)itemText;
- (void)functionalButtonFromCell: (UITableViewCell *) cell;
- (void)switchStateSignal:(BOOL)onOrOff fromCell: (id) theCell;
- (void)specificSettingChosen: (NSString *) theSetting;
- (void)choseCellWithString: (NSString*)optionLabel;


@end

@interface SwipeableTableViewCell : UITableViewCell

//@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) UIButton *button1;
@property (nonatomic, weak) UIButton *button2;
@property (nonatomic, strong) BorderlessButton *functionalButton;
@property (nonatomic, weak) UISwitch *toggoButton;
@property (nonatomic, weak) UIView *myContentView;
@property (nonatomic, weak) UILabel *myTextLabel;
@property (nonatomic, weak) NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *contentViewLeftConstraint;


-(instancetype) initForSettingsTableViewController;
-(instancetype) initForDetailController;
- (NSDictionary *) cellInfoDictionary;

@end
