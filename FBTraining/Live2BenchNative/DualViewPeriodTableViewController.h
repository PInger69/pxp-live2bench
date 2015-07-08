//
//  DualViewPeriodTableViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "DualViewClipTableViewController.h"

@class DualViewPeriodTableViewController;

@protocol DualViewTagControllerDelegate <DualViewClipControllerDelegate>

- (void)tagController:(nonnull DualViewPeriodTableViewController *)tagController didSelectTagNamed:(nonnull NSString *)tagName;

@end

@interface DualViewPeriodTableViewController : UIViewController

@property (weak, nonatomic, nullable) id<DualViewTagControllerDelegate> delegate;

@property (nonatomic) CGFloat tableWidth;

@property (strong, nonatomic, nonnull) NSArray *tagNames;
@property (strong, nonatomic, nonnull) NSArray *tags;
@property (strong, nonatomic, nullable) UIImage *tabImage;
@property (assign, nonatomic) BOOL hidden;

- (void)addTag:(nonnull Tag *)tag;
- (void)removeTag:(nonnull Tag *)tag;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end
