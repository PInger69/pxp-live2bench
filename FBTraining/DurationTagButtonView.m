//
//  DurationTagButtonView.m
//  Live2BenchNative
//
//  Created by dev on 2016-05-31.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DurationTagButtonView.h"

@interface DurationTagButtonView ()



@end


@implementation DurationTagButtonView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0,0,90,30)];
    if (self) {
 		[self commonInit];
    }
    return self;
}



-(void)commonInit
{
    self.hasPostedWarning = NO;
    [self setBackgroundColor:PRIMARY_APP_COLOR];
    self.startTime = 0;
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,4,self.bounds.size.width-10,10)];
    self.nameLabel.font = [UIFont systemFontOfSize:12];
    [self.nameLabel setTextAlignment:NSTextAlignmentLeft]; //NSTextAlignmentRight
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.text = @"Name";
    
    [self addSubview:self.nameLabel];
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,17,self.bounds.size.width-10,10)];
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    [self.timeLabel setTextAlignment:NSTextAlignmentLeft]; //NSTextAlignmentRight
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.text = @"0:00";
    [self addSubview:self.timeLabel];
    self.userInteractionEnabled = NO;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.nameLabel setFrame: CGRectMake(5,4,self.bounds.size.width-10,10)];
    [self.timeLabel setFrame: CGRectMake(5,17,self.bounds.size.width-10,10)];

}
-(void)setHidden:(BOOL)hidden
{
    if (!hidden) self.hasPostedWarning = NO;
    [super setHidden:hidden];
}


@end
