//
//  PxpTagDisplayBar.h
//  TagRenderer
//
//  Created by Nico Cvitak on 2015-05-08.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Tag.h"

@class PxpTagDisplayBar;

@protocol PxpTagDisplayBarDataSource

- (NSTimeInterval)durationInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar;
- (nonnull NSArray *)tagsInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar;
- (NSTimeInterval)selectedTimeInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar;
- (BOOL)shouldDisplaySelectedTimeInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar;

@end

@interface PxpTagDisplayBar : UIView

@property (weak, nonatomic, nullable) id<PxpTagDisplayBarDataSource> dataSource;
@property (assign, nonatomic) CGFloat tagAlpha;
@property (assign, nonatomic) CGFloat tagWidth;
@property (assign, nonatomic) CGFloat selectionStrokeWidth;

@end
