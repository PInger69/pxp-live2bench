//
//  FilterCell.m
//  Live2BenchNative
//
//  Created by DEV on 2013-02-11.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

@synthesize filterTitle = _filterTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.filterTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 95.0f, 30.0f)];
        [self.filterTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:self.filterTitle];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
