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

@property (nonatomic, copy) void(^tagUpdate)(NSMutableDictionary *tag);
@property (nonatomic,assign) BOOL   enable;
- (instancetype)initWithFrame:(CGRect)frame andData:(NSMutableDictionary *)data;

@end
