//
//  BookmarkViewCell.h
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//
#import "DeletableTableViewCell.h"
#import <UIKit/UIKit.h>

@interface BookmarkViewCell : DeletableTableViewCell

@property (strong, nonatomic) UILabel *tagName;
@property (strong, nonatomic) UILabel *tagTime;
@property (strong, nonatomic) UILabel *eventDate;
@property (strong, nonatomic) UILabel *indexNum;
@property (strong, nonatomic) UIImageView *ratingImage;
@property (assign, nonatomic) NSInteger rating;
@property (strong, nonatomic) UIView  *translucentEditingView;

@property (strong, nonatomic) UIDocumentInteractionController *interactionController;

//-(void)updateIndexWith:(int)newIndex;

@end
