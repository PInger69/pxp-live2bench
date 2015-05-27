//
//  FBTrainingPeriodTableViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "FBTrainingClipTableViewController.h"

@class FBTrainingPeriodTableViewController;

@protocol FBTrainingTagControllerDelegate <FBTrainingClipControllerDelegate>

- (void)tagController:(nonnull FBTrainingPeriodTableViewController *)tagController didSelectTagNamed:(nonnull NSString *)tagName;

@end

@interface FBTrainingPeriodTableViewController : UIViewController

@property (weak, nonatomic, nullable) id<FBTrainingTagControllerDelegate> delegate;

@property (nonatomic) CGFloat tableWidth;

@property (strong, nonatomic, nonnull) NSArray *tagNames;
@property (strong, nonatomic, nonnull) NSArray *tags;
@property (strong, nonatomic, nullable) UIImage *tabImage;

- (void)addTag:(nonnull Tag *)tag;
- (void)removeTag:(nonnull Tag *)tag;

@end
