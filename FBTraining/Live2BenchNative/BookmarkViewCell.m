//
//  BookmarkViewCell.m
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BookmarkViewCell.h"


@implementation BookmarkViewCell
{
    UILabel *indexNum;
}
@synthesize tagName,tagTime,eventDate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.eventDate = [[UILabel alloc] initWithFrame:CGRectMake(18.0f, 0.0f, 130.0f, self.frame.size.height)];
        [self.eventDate setBackgroundColor:[UIColor clearColor]];
        [self.eventDate setText:@"date"];
        [self addSubview:self.eventDate];
        self.tagTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.eventDate.frame) + 10.0f, self.eventDate.frame.origin.y, 100.0f, self.eventDate.frame.size.height)];
        [self.tagTime setBackgroundColor:[UIColor clearColor]];
        [self.tagTime setText:@"time"];
        [self addSubview:self.tagTime];
        self.tagName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.tagTime.frame) +5.0f, self.tagTime.frame.origin.y, self.frame.size.width - CGRectGetMaxX(self.tagTime.frame) - 42.0f, self.tagTime.frame.size.height)];
        [self.tagName setBackgroundColor:[UIColor clearColor]];
        [self.tagName setText:@"name"];
        [self.tagName setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:self.tagName];
        
        
       
        indexNum  = [[UILabel alloc] initWithFrame:CGRectMake(3, 12, 20, 20) ];
        [indexNum setFont:[UIFont systemFontOfSize:12.0f]];
        [indexNum setTextColor:[UIColor lightGrayColor]];
        UITableView* table          = (UITableView *)[self superview];
        NSIndexPath* pathOfTheCell  = [table indexPathForCell:self];
//        NSInteger sectionOfTheCell  = [pathOfTheCell section];
        NSInteger rowOfTheCell      = [pathOfTheCell row];
        [indexNum setText: [NSString stringWithFormat:@"%i",rowOfTheCell]];
        [self addSubview:indexNum];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateIndexWith:(int)newIndex
{
    [indexNum setText: [NSString stringWithFormat:@"%i",newIndex]];
}



@end
