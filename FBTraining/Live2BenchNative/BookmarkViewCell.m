//
//  BookmarkViewCell.m
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BookmarkViewCell.h"


@implementation BookmarkViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupView];
        
    }
    return self;
}

-(void)setupView{
    [super setupView];
    
    self.eventDate = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, 0.0f, 130.0f, self.frame.size.height)];
    [self.eventDate setBackgroundColor:[UIColor clearColor]];
    [self.eventDate setText:@"date"];
    [self.myContentView addSubview:self.eventDate];
    
    self.tagTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.eventDate.frame) + 10.0f, self.eventDate.frame.origin.y, 100.0f, self.eventDate.frame.size.height)];
    [self.tagTime setBackgroundColor:[UIColor clearColor]];
    [self.tagTime setText:@"time"];
    [self.myContentView addSubview:self.tagTime];
    
    self.tagName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.tagTime.frame) +5.0f, self.tagTime.frame.origin.y, self.frame.size.width - CGRectGetMaxX(self.tagTime.frame) - 42.0f, self.tagTime.frame.size.height)];
    [self.tagName setBackgroundColor:[UIColor clearColor]];
    [self.tagName setText:@"name"];
    [self.tagName setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.myContentView addSubview:self.tagName];
    
    [self.deleteButton setFrame: CGRectMake(390, 0, 70, 44)];
    
    self.indexNum  = [[UILabel alloc] initWithFrame:CGRectMake(3, 12, 20, 20) ];
    [self.indexNum setFont:[UIFont systemFontOfSize:12.0f]];
    [self.indexNum setTextColor:[UIColor lightGrayColor]];
//    UITableView* table          = (UITableView *)[self superview];
//    NSIndexPath* pathOfTheCell  = [table indexPathForCell:self];
//    //        NSInteger sectionOfTheCell  = [pathOfTheCell section];
//    NSInteger rowOfTheCell      = [pathOfTheCell row];
//    [self.indexNum setText: [NSString stringWithFormat:@"%i",rowOfTheCell]];
    [self.myContentView addSubview: self.indexNum];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    if (selected) {
        self.myContentView.backgroundColor = [UIColor lightGrayColor];
    }else{
        self.myContentView.backgroundColor = [UIColor whiteColor];
    }
    
    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (highlighted) {
        self.myContentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    }else{
        self.myContentView.backgroundColor = [UIColor whiteColor];
    }
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    self.deleteButton.hidden = editing;
    self.swipeRecognizer.enabled = !editing;
}

//-(void)updateIndexWith:(int)newIndex
//{
//    [indexNum setText: [NSString stringWithFormat:@"%i",newIndex]];
//}



@end
