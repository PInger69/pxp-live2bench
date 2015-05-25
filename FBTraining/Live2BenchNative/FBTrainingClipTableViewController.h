//
//  FBTrainingClipTableViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBTrainingClipTableViewController : UIViewController

@property (strong, nonatomic, nonnull) UITableView *tableView;
@property (readonly, nonatomic) BOOL presented;
@property (strong, nonatomic, nonnull) NSArray *tags;

- (nonnull instancetype)initWithTags:(nonnull NSArray *)tags;

- (void)present:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

@end
