//
//  FilterButtonBlockView.h
//  Live2BenchNative
//
//  Created by dev on 8/5/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

enum Orientation{
    FilterButtonBlockVertical = 1,
    FilterButtonBlockHorzontal
};

#import "FilterComponentAbstract.h"
#import "FilterProcessor.h"

@interface FilterButtonBlockView : FilterComponentAbstract
{
        UILabel                 * label;
        NSString                * accessLable;
        NSString                * (^filterBlock)(NSDictionary*tag);
        NSMutableArray          * buttonList;
}


@property (strong, nonatomic)     NSArray * fixedFilter;

@property (strong,nonatomic) UILabel                    * label;
//@property (strong,nonatomic) FilterProcessor            * filterP;
@property (assign,nonatomic) CGSize                     buttonSize; // used only during populate method
@property (assign,nonatomic) CGSize                     buttonMargin; // used only during populate
@property (assign,nonatomic) int                        orientation;
@property (assign,nonatomic) int                        groupLength;



- (id)initWithFrame:(CGRect)frame Name:(NSString*)nme AccessLable:(NSString*)aLabel;
-(void)populate:(NSArray *)list;
-(void)deselectAll;
-(void)setFilterBlock:(NSString* (^)(NSDictionary*))madeKey;
-(void)inputArray:(NSArray*)list;
-(NSArray*)refinedList;





@end
