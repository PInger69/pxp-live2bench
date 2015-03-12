//
//  HeaderBar.h
//  QuickTest
//
//  Created by dev on 6/25/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#define ASCEND          1<<1
#define DESCEND         1<<2

#define NAME_FIELD      1<<3
#define DATE_FIELD      1<<4
#define TIME_FIELD      1<<5
#define OTHER_FIELD     1<<6




#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    HBSortNone                  = 0,
    HBSortNameAscending		    = NAME_FIELD | ASCEND,
    HBSortNameDescending		= NAME_FIELD | DESCEND,
    HBSortDateAscending		    = DATE_FIELD | ASCEND,
    HBSortDateDescending		= DATE_FIELD | DESCEND,
    HBSortTimeAscending		    = TIME_FIELD | ASCEND,
    HBSortTimeDescending		= TIME_FIELD | DESCEND
} HBSortType;

@interface HeaderBar : UIView
{
    HBSortType headerBarSortType;
}

@property (assign,nonatomic) HBSortType headerBarSortType;
-(id)initWithFrame:(CGRect)frame defaultSort:(HBSortType)sortType;

-(void)onTapPerformSelector:(SEL)sel addTarget:(id)target;
-(void)setHeaderBarSortType:(HBSortType)newHeaderBarSortType;

@end
