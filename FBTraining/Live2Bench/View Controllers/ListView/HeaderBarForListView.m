//
//  HeaderBarForListView.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/2/19.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "HeaderBarForListView.h"
#import "SortArrow.h"

#define LABEL_WIDTH                 100
#define LABEL_HEIGHT                 40

@implementation HeaderBarForListView
{
    SortArrow * dateArrow;
    SortArrow * nameArrow;
    SortArrow * timeArrow;
    UIButton  * dateTapArea;
    UIButton  * nameTapArea;
    UIButton  * timeTapArea;
    
    SEL onTapSelector;
    id theTarget;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setupGraphics
{
    self.backgroundColor = [UIColor lightGrayColor];
    
    //[self addSubview:[self makeLabel:@"Comment"  xPosition:5]];
    [self addSubview:[self makeLabel:NSLocalizedString(@"Date", nil)     xPosition:55]];
    [self addSubview:[self makeLabel:NSLocalizedString(@"Tag Time", nil) xPosition:190]];
    [self addSubview:[self makeLabel:NSLocalizedString(@"Name", nil)     xPosition:295]];
    
    float sbh       = 18.0f;
    float sbhSize   = 12.0f;
    
    dateArrow = [[SortArrow alloc]initWithFrame:CGRectMake(55+40,sbh,sbhSize,sbhSize)];
    timeArrow = [[SortArrow alloc]initWithFrame:CGRectMake(190+72,sbh,sbhSize,sbhSize)];
    nameArrow = [[SortArrow alloc]initWithFrame:CGRectMake(295+50,sbh,sbhSize,sbhSize)];
    
    
    
    [self addSubview:dateArrow];
    [self addSubview:nameArrow];
    [self addSubview:timeArrow];
    
    
    
    
    dateTapArea = [[UIButton alloc]initWithFrame:CGRectMake(55, 0, 105, 40)];
    dateTapArea.tag = DATE_FIELD;
    [dateTapArea addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:dateTapArea];
    
    timeTapArea = [[UIButton alloc]initWithFrame:CGRectMake(190, 0, 90, 40)];
    timeTapArea.tag = TIME_FIELD;
    [timeTapArea addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:timeTapArea];
    
    nameTapArea = [[UIButton alloc]initWithFrame:CGRectMake(295, 0, 200, 40)];
    nameTapArea.tag = NAME_FIELD;
    [nameTapArea addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nameTapArea];
    
}

-(UILabel *)makeLabel:(NSString*)text xPosition:(float)x
{
    UILabel *myLabel        = [[UILabel alloc]initWithFrame:CGRectMake(x, 5, LABEL_WIDTH, LABEL_HEIGHT)];
    myLabel.text            = text;
    myLabel.textColor       = [UIColor whiteColor];
    myLabel.backgroundColor = [UIColor clearColor];
    return myLabel;
}


-(void)buttonPressed:(id)sender{
    UIButton    * button        = (UIButton*)sender;
    SortArrow   * arrowGraphic;
    switch (button.tag) {
        case DATE_FIELD:
            arrowGraphic = dateArrow;
            break;
        case TIME_FIELD:
            arrowGraphic = timeArrow;
            break;
        case NAME_FIELD:
            arrowGraphic = nameArrow;
            break;
    }
    
    self.headerBarSortType = button.tag|arrowGraphic.nextState;
    
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (onTapSelector) [theTarget performSelector:onTapSelector withObject:self];
}

-(HBSortType)headerBarSortType
{
    return headerBarSortType;
}

-(void)setHeaderBarSortType:(HBSortType)newHeaderBarSortType
{
    headerBarSortType = newHeaderBarSortType;
    
    dateArrow.state = 0;
    nameArrow.state = 0;
    timeArrow.state = 0;
    
    if (newHeaderBarSortType & NAME_FIELD)  nameArrow.state = newHeaderBarSortType;
    if (newHeaderBarSortType & DATE_FIELD)  dateArrow.state = newHeaderBarSortType;
    if (newHeaderBarSortType & TIME_FIELD)  timeArrow.state = newHeaderBarSortType;
    
    
}

-(void)onTapPerformSelector:(SEL)sel addTarget:(id)target
{
    onTapSelector   = sel;
    theTarget       = target;
}


@end
