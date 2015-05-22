//
//  FBTrainingPeriodTableViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"

@interface FBTrainingPeriodTableViewController : UIViewController

@property (nonatomic) CGFloat tableWidth;

@property (strong, nonatomic, nonnull) NSArray *tagNames;
@property (strong, nonatomic, nonnull) NSArray *tags;
@property (strong, nonatomic, nullable) UIImage *tabImage;

- (void)addTag:(nonnull Tag *)tag;
- (void)removeTag:(nonnull Tag *)tag;

@end
