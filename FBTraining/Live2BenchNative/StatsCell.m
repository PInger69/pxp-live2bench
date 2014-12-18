//
//  StatsCell.m
//  Live2BenchNative
//
//  Created by DEV on 1/7/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "StatsCell.h"

@implementation StatsCell

//@synthesize columnButtonPositions;
@synthesize columns;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)addColumns:(int)columnNumber :(int)gridCellWidth :(int)titleLabelWidth{
    
    if(columns == nil)
    {
        columns = [[NSMutableArray alloc]init];
    }
    for(int i = 0; i < columnNumber; i++){
        [columns addObject:[NSNumber numberWithFloat:gridCellWidth*i+titleLabelWidth]];
    }
    [columns addObject:[NSNumber numberWithFloat:1]];
    [columns addObject:[NSNumber numberWithFloat:1023]];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Use the same color and width as the default cell separator for now
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(ctx, 0.25);
    
    for (int i = 0; i <[columns count]; i++) {
        CGFloat f = [((NSNumber*) [columns objectAtIndex:i]) floatValue];
        CGContextMoveToPoint(ctx, f, 0);
        CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
    }
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];
    
}

//-(void)presetSize:(int)cNumber :(int)gcWidth :(int)titleWidth{
//    
//    columnNumber = cNumber;
//    gridCellWidth = gcWidth;
//    titleLabelWidth = titleWidth;
//}
/*
 if (columnButtonPositions && [[columnButtonPositions allKeys] containsObject:[NSString stringWithFormat:@"%f", (f-100)/5]]) {
 BorderButton *cellButton = [[BorderButton alloc]initWithFrame:CGRectMake(f-45, 5.0, 40, 40)];
 [cellButton setTitle:[NSString stringWithFormat:@"%d",[[columnButtonPositions objectForKey:[NSString stringWithFormat:@"%f", (f-100)/5] ] count]] forState:UIControlStateNormal];
 
 }
 */

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
