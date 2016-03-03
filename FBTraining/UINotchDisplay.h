//
//  UINotchDisplay.h
//  Live2BenchNative
//
//  Created by dev on 2016-03-02.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UINotchDisplay;


// anything that is a notch will impliment this
@protocol UINotchProtocol
-(double)notchTime;
-(nonnull NSString*)notchColor;
@end

// this is where we get a list of notches and what one is highlighted
@protocol UINotchDataSource <NSObject>
- (nonnull NSArray *)notchesToDisplay:(nonnull UINotchDisplay *)notchDisplayBar;
- (nonnull id<UINotchProtocol>)selectedNotch:(nonnull UINotchDisplay *)notchDisplayBar;
@end

// what is providing the duration time
@protocol UINotchTimeProvider <NSObject>
- (NSTimeInterval)durationTime:(nonnull UINotchDisplay *)notchDisplayBar;
@end

@interface UINotchDisplay : UIView

@property (weak, nonatomic, nullable) id <UINotchDataSource>    dataSource;
@property (weak, nonatomic, nullable) id <UINotchTimeProvider>  timeProvider;
@property (assign, nonatomic) CGFloat tagAlpha;
@property (assign, nonatomic) CGFloat tagWidth;
@property (assign, nonatomic) CGFloat selectionStrokeWidth;

@end
