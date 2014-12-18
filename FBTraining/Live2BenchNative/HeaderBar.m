//
//  HeaderBar.m
//  QuickTest
//
//  Created by dev on 6/25/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "HeaderBar.h"
#import "SortArrow.h"

#define LABEL_WIDTH                 100
#define LABEL_HEIGHT                 40
/**
 *  This is the top bar used on the My Clip View and also the List View
 */
@implementation HeaderBar
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupGraphics];
        self.headerBarSortType = HBSortNone;
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame defaultSort:(HBSortType)sortType{
    

    self = [super initWithFrame:frame];
    if (self) {
       
        [self setupGraphics];
         self.headerBarSortType = sortType;
    }
    return self;



}

-(void)onTapPerformSelector:(SEL)sel addTarget:(id)target
{
    onTapSelector   = sel;
    theTarget       = target;
}

-(void)setupGraphics
{
    self.backgroundColor = [UIColor lightGrayColor];
    
    [self addSubview:[self makeLabel:@"Comment"  xPosition:5]];
    [self addSubview:[self makeLabel:@"Date"     xPosition:555]];
    [self addSubview:[self makeLabel:@"Tag Time" xPosition:690]];
    [self addSubview:[self makeLabel:@"Name"     xPosition:795]];
    
    float sbh       = 18.0f;
    float sbhSize   = 12.0f;
    
    dateArrow = [[SortArrow alloc]initWithFrame:CGRectMake(550+40,sbh,sbhSize,sbhSize)];
    timeArrow = [[SortArrow alloc]initWithFrame:CGRectMake(690+72,sbh,sbhSize,sbhSize)];
    nameArrow = [[SortArrow alloc]initWithFrame:CGRectMake(795+50,sbh,sbhSize,sbhSize)];



    [self addSubview:dateArrow];
    [self addSubview:nameArrow];
    [self addSubview:timeArrow];



    
    dateTapArea = [[UIButton alloc]initWithFrame:CGRectMake(550, 0, 105, 40)];
    dateTapArea.tag = DATE_FIELD;
    [dateTapArea addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:dateTapArea];
    
    timeTapArea = [[UIButton alloc]initWithFrame:CGRectMake(690, 0, 90, 40)];
    timeTapArea.tag = TIME_FIELD;
    [timeTapArea addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:timeTapArea];
    
    nameTapArea = [[UIButton alloc]initWithFrame:CGRectMake(795, 0, 200, 40)];
    nameTapArea.tag = NAME_FIELD;
    [nameTapArea addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nameTapArea];
    
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


-(UILabel *)makeLabel:(NSString*)text xPosition:(float)x
{
    UILabel *myLabel        = [[UILabel alloc]initWithFrame:CGRectMake(x, 5, LABEL_WIDTH, LABEL_HEIGHT)];
    myLabel.text            = text;
    myLabel.textColor       = [UIColor whiteColor];
    myLabel.backgroundColor = [UIColor clearColor];
    return myLabel;
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




@end
