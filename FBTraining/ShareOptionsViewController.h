//
//  ShareOptionsViewController.h
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/3/17.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareOptionsViewController : UIViewController

- (instancetype)initWithArray:(NSArray *)Options andIcons:(NSArray *)optionIcons andSelectedIcons: (NSArray *)selectedIcons;
- (void)setOnSelectTarget: (id)target andSelector: (SEL) selector;

@end
