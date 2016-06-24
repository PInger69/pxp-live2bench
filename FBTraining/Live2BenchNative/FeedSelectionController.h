//
//  FeedSelectionTableViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-22.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@class FeedSelectionController;

@protocol FeedSelectionControllerDelegate

- (void)feedSelectionController:(nonnull FeedSelectionController *)feedSelectionController didSelectFeed:(nonnull Feed *)feed;

@end

@interface FeedSelectionController : UIViewController

@property (weak, nonatomic, nullable) id<FeedSelectionControllerDelegate> delegate;
@property (strong, nonatomic, nonnull) NSArray *feeds;

- (nonnull instancetype)initWithFeeds:(nonnull NSArray *)feeds;

-(void)highLightFeed:(nonnull Feed *)feed;

- (void)present:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

@end
