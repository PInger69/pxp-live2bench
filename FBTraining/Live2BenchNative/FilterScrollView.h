//
//  FilterScrollView.h
//  QuickTest
//
//  Created by dev on 7/11/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterProcessor.h"
#import "FilterComponent.h"

typedef enum {FilterScrollSortAlpha, FilterScrollSortNumarical} SortType;




/**
 *  This is meant to be a bunch of filter components connected with a linked list structure
 */
@interface FilterScrollView : UIView<UIScrollViewDelegate, FilterComponent>
{

    UILabel                 * label;
    UIScrollView            * scrollView;
    NSString                * accessLable;
    CGSize                  buttonSize;
    CGSize                  buttonMargin;
    FilterProcessor         * filterP;
    NSString                * (^filterBlock)(NSDictionary*tag);
    NSMutableSet            * selectedTags;
    NSMutableArray          * buttonList;
    int                     rowCount;
    BOOL                    invoked;
}


@property (strong,nonatomic) UILabel                    * label;
//@property (strong,nonatomic) UIScrollView               * scrollView;
@property (assign,nonatomic) CGSize                     buttonSize; // used only during populate method

@property (assign,nonatomic) CGSize                     buttonMargin; // used only during populate method
@property (strong,nonatomic) id <FilterComponent>       previous;
@property (strong,nonatomic) id <FilterComponent>       next;
@property (strong,nonatomic) FilterProcessor            * filterP;

@property (assign,nonatomic) int rowCount;

@property (assign,nonatomic) SortType                        sortType;
@property (strong,nonatomic) NSMutableSet               * selectedTags;

-(id)initWithFrame:(CGRect)frame Name:(NSString*)name AccessLable:(NSString*)aLabel;

-(void)populate:(NSArray *)list;

-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target;
-(void)deselectAll;
-(void)update;
-(void)setFilterBlock:(NSString* (^)(NSDictionary*))madeKey;


-(void)inputArray:(NSArray*)list;
-(NSArray*)refinedList;

-(void)nextComponent:(id <FilterComponent>)nxt;
-(void)previousComponent:(id <FilterComponent>)prev;

-(BOOL)isInvoked;
@end
