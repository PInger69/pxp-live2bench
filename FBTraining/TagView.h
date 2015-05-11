//
//  TagView.h
//  TagRenderer
//
//  Created by Nico Cvitak on 2015-05-08.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Tag.h"

@class TagView;

@protocol TagViewDataSource

- (NSTimeInterval)durationInTagView:(nonnull TagView *)tagView;
- (nonnull NSArray *)tagsInTagView:(nonnull TagView *)tagView;

@end

@interface TagView : UIView

@property (weak, nonatomic, nullable) id<TagViewDataSource> dataSource;
@property (assign, nonatomic) CGFloat tagAlpha;
@property (assign, nonatomic) CGFloat tagWidth;

@end
