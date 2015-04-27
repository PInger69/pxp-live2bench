//
//  RatingAndCommentingField.h
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/3/20.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingInput.h"
#import "CommentingField.h"

@interface RatingAndCommentingField : UIViewController

@property (strong, nonatomic) RatingInput *ratingScale;
@property (strong, nonatomic) CommentingField *commentingField;
@property (strong, nonatomic) UIPopoverController *commentingPop;
@property (strong, nonatomic) UIButton *commentingButton;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) UITextView *commentingArea;
@property (nonatomic, copy) void(^tagUpdate)(NSMutableDictionary *tag);


- (instancetype)initWithFrame:(CGRect)frame andData:(NSMutableDictionary *)data;
@end
