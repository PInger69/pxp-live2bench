//
//  SortArrow.h
//  QuickTest
//
//  Created by dev on 8/18/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#define ASCEND          1<<1
#define DESCEND         1<<2

//#define NAME_FIELD      1<<3
//#define DATE_FIELD      1<<4
//#define TIME_FIELD      1<<5
//#define OTHER_FIELD     1<<6




#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    None                    = 0,
    Ascend                  = ASCEND,
    Descend                 = DESCEND

} State;


@interface SortArrow : UIView
{
    
    State state;
    State nextState;
}
@property (assign, nonatomic)    State state;
@property (assign, nonatomic)    State nextState;



@end
