//
//  PxpFilterToggleButton.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-11.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterToggleButton.h"
#import "Tag.h"

@implementation PxpFilterToggleButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
       [self addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)encodeWithCoder:(nonnull NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


-(void)buttonSelected:(id)sender
{
    self.selected = !self.selected;
    [_parentFilter refresh];
}



-(void)deselect
{
    self.selected = NO;
}



// Protocol methods
-(void)filterTags:(NSMutableArray *)tagsToFilter
{
    

    if (self.selected && _predicateToUse){
        [tagsToFilter filterUsingPredicate:_predicateToUse];
    } else if (self.selected){
        [tagsToFilter filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",_filterPropertyKey, [NSNumber numberWithBool:[_filterPropertyValue boolValue]] ]];
    }
}

-(void)reset{
    [self deselect];
}


@end
