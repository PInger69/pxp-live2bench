//
//  FilterTab.h
//  Live2BenchNative
//
//  Created by dev on 7/23/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterTab : UIView
{
    BOOL        clearOnLeaveTab;
    UIButton    * tabLabel;
}

@property (strong,nonatomic) NSArray     * componentList;
@property (strong,nonatomic) UIButton    * tabLabel;
@property (strong,nonatomic) NSString    * name;
@property (assign,nonatomic) BOOL       clearOnLeaveTab;

-(id)initWithName:(NSString*)tabName;
-(void)setIsSelected:(BOOL)isSelect;
-(void)setTabXposition:(float)x;
-(NSInteger)countOfFiltededTags;
-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target;
-(void)linkComponents:(NSArray *)cmpList;
-(NSArray*)processedList;
-(NSArray*)invokedComponentNames;

-(void)drawLine:(CGPoint)from to:(CGPoint)to lineWidth:(float) lineWidth strokeColor:(UIColor*)strokeColor;


@end
