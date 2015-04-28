//
//  BookmarkViewCell.m
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BookmarkViewCell.h"

static UIImage *starImage;

@implementation BookmarkViewCell{
    UILabel *ratingLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!starImage) {
            starImage = [self starImage];
        }
        [self setupView];
        
    }
    return self;
}

-(void)setupView{
    [super setupView];
    self.sharingEnabled = YES;
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
    
    [self.deleteButton setFrame: CGRectMake(393, 0, 70, 44)];
    [self.shareButton setFrame: CGRectMake(0, 0, 70, 44)];
    //    self.shareButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    self.shareButton.layer.borderWidth = 0.4f;
    
    self.indexNum  = [[UILabel alloc] initWithFrame:CGRectMake(3, 12, 20, 20) ];
    [self.indexNum setFont:[UIFont systemFontOfSize:12.0f]];
    [self.indexNum setTextColor:[UIColor lightGrayColor]];
    //    UITableView* table          = (UITableView *)[self superview];
    //    NSIndexPath* pathOfTheCell  = [table indexPathForCell:self];
    //    //        NSInteger sectionOfTheCell  = [pathOfTheCell section];
    //    NSInteger rowOfTheCell      = [pathOfTheCell row];
    //    [self.indexNum setText: [NSString stringWithFormat:@"%i",rowOfTheCell]];
    [self.myContentView addSubview: self.indexNum];
    
    self.ratingImage = [[UIImageView alloc] initWithFrame:CGRectMake(390, 4, 36, 36)];
    [self.ratingImage setImage: starImage];
    ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 10, 20, 20)];
    [ratingLabel setTextColor: [UIColor whiteColor]];
    [ratingLabel setText: @"5"];
    [self.ratingImage addSubview: ratingLabel];
    [self.myContentView addSubview: self.ratingImage];
    //    UIView *seperateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 463, 1)];
    //    [seperateLine setBackgroundColor:[UIColor lightGrayColor]];
    //    [self.myContentView addSubview:seperateLine];
    //self.contentView.layoutMargins = UIEdgeInsetsZero;
}

-(void)setRating:(int)rating{
    _rating = rating;
    [ratingLabel setText: [NSString stringWithFormat:@"%i", rating]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    if (selected) {
        self.myContentView.backgroundColor = [UIColor whiteColor];
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
    [self.swipeRecognizerRight setEnabled:!editing];
    [self.swipeRecognizerLeft setEnabled:!editing];
}

-(UIImage *) starImage{
    CGSize imageSize = CGSizeMake(100, 100);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *starPath = [UIBezierPath bezierPath];
    UIBezierPath *outLinePath = [UIBezierPath bezierPath];
    
    [starPath moveToPoint: CGPointMake(17.5, 100)]; // bottom left
    [starPath addLineToPoint: CGPointMake(50, 0)];  // top
    [starPath addLineToPoint: CGPointMake(50 + 32.5, 100)]; // bottom right
    [starPath addLineToPoint: CGPointMake(0, 38.2)]; //left
    [starPath addLineToPoint: CGPointMake(100, 38.2)]; //right
    [starPath addLineToPoint: CGPointMake(17.5, 100)]; // bottom left
    
    
    [outLinePath moveToPoint: CGPointMake(17.5, 100)];
    [outLinePath addLineToPoint: CGPointMake(50, 100 -23.61 )];
    [outLinePath addLineToPoint: CGPointMake(50 + 32.5, 100)];
    [outLinePath addLineToPoint: CGPointMake(70, 61.8)];
    [outLinePath addLineToPoint: CGPointMake(100, 38.2)];
    [outLinePath addLineToPoint: CGPointMake(0, 38.2)];
    [outLinePath addLineToPoint: CGPointMake(50 + 32.5, 100)];
    [outLinePath addLineToPoint: CGPointMake(50, 0)];
    [outLinePath addLineToPoint: CGPointMake(17.5, 100)]; // bottom left
    
    
    [PRIMARY_APP_COLOR setFill];
    [[UIColor blackColor] setStroke];
    
    outLinePath.lineWidth = 5.0;
    [outLinePath stroke];
    [starPath fill];
    
//    UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:14.0];
//    
//    NSDictionary *attributesDict = @{ NSFontAttributeName : font };
//    
//    NSAttributedString *numberString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%i", rating]];
//    
//    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 35, 60, 60)];
//    [numberLabel drawTextInRect:CGRectMake(35, 35, 60, 60)];
////    [numberString drawInRect:CGRectMake(35, 35, 60, 60)];
////    numberString;
//                                  // drawInRect:CGRectMake(35, 35, 60, 60) withAttributes:attributesDict];

    
    UIImage *starImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return starImage;
}
//-(void)updateIndexWith:(int)newIndex
//{
//    [indexNum setText: [NSString stringWithFormat:@"%i",newIndex]];
//}



@end
