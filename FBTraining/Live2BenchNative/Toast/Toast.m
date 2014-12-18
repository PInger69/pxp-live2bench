//
//  Toast.m
//  Live2BenchNative
//
//  Created by DEV on 2013-04-03.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "Toast.h"

@implementation Toast

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)init
{
    self =[super init];
    
    //add the colour stripe to distinguish users by colours
    colourStripe = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 0)];
    [self addSubview:colourStripe];
    
    //title of event
    eventTitle=[[UILabel alloc]initWithFrame:CGRectMake(35, 5, self.frame.size.width, 40)];
    [eventTitle setTextColor:[UIColor blackColor]];
    [eventTitle setBackgroundColor:[UIColor clearColor]];
    [self addSubview:eventTitle];
    self.layer.borderColor = [UIColor orangeColor].CGColor;
    self.layer.borderWidth = 1;
    uController=[[UtilitiesController alloc] init];
    return self;
}

-(void)setEventForColour:(NSString*)event colour:(NSString*)hexColour
{
    if(colourStripe.frame.size.height != self.frame.size.height)
    {
        [colourStripe setFrame:CGRectMake(0, 0, 30, self.frame.size.height)];
    }
    
    if(eventTitle.frame.size.width != self.frame.size.width)
    {
        [eventTitle setFrame:CGRectMake(35, 5, self.frame.size.width, 40)];
    }
        
    [eventTitle setText:event];
    [colourStripe setBackgroundColor:[uController colorWithHexString:hexColour]];
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
