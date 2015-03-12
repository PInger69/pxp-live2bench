//
//  TeleView.h
//  Live2BenchNative
//
//  Created by dev on 2014-05-23.
//  Copyright (c) 2014 DEV. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TeleViewController.h"

@class TeleViewController;

@interface TeleView : UIView

@property (nonatomic) BOOL isBlank;
@property (nonatomic) BOOL isStraight;
@property (nonatomic) BOOL isArrow;
@property (nonatomic) BOOL isFocus;
@property (nonatomic, strong) UIImage *teleImage;
@property (nonatomic, strong) TeleViewController *tvController;

- (BOOL)hasUndoState;
- (BOOL)isEmptyCanvas;
- (void)setColourWithRed:(float)redt green:(float)greent blue:(float)bluet;
- (void)clearTelestration;
- (BOOL)saveTelestration;
- (void)undoStroke;

@end
