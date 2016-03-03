//
//  UIDrawer.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-29.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIDrawer;
typedef NS_ENUM (NSInteger, UIDrawerOpenStyle){
    UIDrawerTop,
    UIDrawerRight,
    UIDrawerLeft,
    UIDrawerBottom
    
};

@protocol UIDrawerDelegate <NSObject>

@optional
-(void)willOpen:(UIDrawer*)drawer;
-(void)willClose:(UIDrawer*)drawer;
-(void)didOpen:(UIDrawer*)drawer;
-(void)didClose:(UIDrawer*)drawer;

@end

@interface UIDrawer : UIView
@property (nonatomic,weak)      id <UIDrawerDelegate>   delegate;
@property (nonatomic,assign)    UIDrawerOpenStyle       openStyle;
@property (nonatomic, assign)   NSTimeInterval          animationTime;
@property (nonatomic, strong)   UIView                  * contentArea;
@property (nonatomic,assign)    BOOL                    isOpen;


// these are for minor adjustments if you didn't init it correctly
@property (nonatomic,assign)    CGPoint                 openCenterPoint;
@property (nonatomic,assign)    CGPoint                 closeCenterPoint;

-(void)open:(BOOL)animated;
-(void)close:(BOOL)animated;

@end
