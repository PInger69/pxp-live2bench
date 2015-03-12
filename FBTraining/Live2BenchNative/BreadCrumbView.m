//
//  BreadCrumbView.m
//  Live2BenchNative
//
//  Created by dev on 7/31/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "BreadCrumbView.h"
#import "UIFont+Default.h"

@implementation BreadCrumbView
{
    UIImageView * crumbBG;
    UILabel     * crumbName;
    CGRect      myFrame;
    CGRect      mySize;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        myFrame = frame;
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame label:(NSString*)label
{
    self = [super initWithFrame:frame];
    if (self) {
        myFrame = frame;
        mySize  = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self setup:label];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame label:(NSString*)label colour:(NSString*)col
{
    self = [super initWithFrame:frame];
    if (self) {
        
        myFrame = frame;
        [self setup:label];
    }
    return self;
}

-(void)setup:(NSString*)label
{

    crumbBG = [[UIImageView alloc] initWithFrame:mySize];
    
    [crumbBG setImage:[UIImage imageNamed:@"chevbothpoints"]];
    [self addSubview:crumbBG];
    
    crumbName = [[UILabel alloc] initWithFrame:CGRectMake(0, -3, mySize.size.width, mySize.size.height)];
    [crumbName setBackgroundColor:[UIColor clearColor]];
    [crumbName setTextColor:[UIColor darkGrayColor]];
    [crumbName setTextAlignment:NSTextAlignmentCenter];
    [crumbName setFont:[UIFont defaultFontOfSize:13]];
    [crumbName setText:label];
    [self addSubview:crumbName];


}


-(float)getWidth
{
    return 123;
}

-(void)setFirst
{
    [crumbBG setImage:[UIImage imageNamed:@"chevrect"]];
    [crumbName setFrame:CGRectMake(-8, -3, mySize.size.width, mySize.size.height)];
}


@end
