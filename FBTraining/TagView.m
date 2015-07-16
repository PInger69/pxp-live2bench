//
//  TagView.m
//  TagRenderer
//
//  Created by Nico Cvitak on 2015-05-08.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import "TagView.h"

@interface TagView ()

@end

@implementation TagView

@synthesize dataSource = _dataSource;
@synthesize tagAlpha = _tagAlpha;
@synthesize tagWidth = _tagWidth;
@synthesize selectionFillColor = _selectionFillColor;
@synthesize selectionStrokeColor = _selectionStrokeColor;
@synthesize selectionStrokeWidth = _selectionStrokeWidth;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set defaults
        
        self.dataSource = nil;
        self.tagAlpha = 1.0;
        self.tagWidth = 5.0;
        self.selectionFillColor = [PRIMARY_APP_COLOR colorWithAlphaComponent:0.5];
        self.selectionStrokeColor = PRIMARY_APP_COLOR;
        self.selectionStrokeWidth = 2.0;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // get drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw background
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    // ensure that there is a data source before we start drawing tags
    if (self.dataSource) {
        
        // get width of pixels to draw
        NSUInteger pixelWidth = rect.size.width;
        
        // obtain data source information
        NSArray *tags = [self.dataSource tagsInTagView:self];
        NSTimeInterval duration = [self.dataSource durationInTagView:self];
        NSTimeInterval selectedTime = [self.dataSource selectedTimeInTagView:self];
        BOOL shouldDisplaySelectedTime = [self.dataSource shouldDisplaySelectedTimeInTagView:self];
        
        // set up draw info
        NSMutableArray *drawInfo = [NSMutableArray arrayWithCapacity:pixelWidth];
        for (NSUInteger x = 0; x < pixelWidth; x++) {
            [drawInfo insertObject:[NSMutableSet set] atIndex:x];
        }
        
        // populate draw info
        for (Tag *tag in tags) {
            // calculate tag dimensions
            NSInteger tagX = pixelWidth * (tag.time) / duration - self.tagWidth / 2.0;
            
            for (NSInteger i = 0; i < self.tagWidth; i++) {
                
                // only insert tag if it will fit in the frame
                NSInteger x = tagX + i;
                if (0 <= x && x < pixelWidth) {
                    
                    // we only need to store the color information
                    NSMutableSet *colorSet = drawInfo[x];
                    
                    // add color to set
                    [colorSet addObject:tag.colour ? tag.colour : @"000000"];
                }
            }
            
        }
        
        // draw tags
        for (NSUInteger x = 0; x < pixelWidth; x++) {
            NSSet *tagColors = drawInfo[x];
            NSUInteger nTags = tagColors.count;
            CGFloat tagHeight = ceil(rect.size.height / nTags);
            
            
            NSUInteger i = 0;
            for (NSString *hex in tagColors) {
                
                // get tag color and apply alpha
                UIColor *color = [[Utility colorWithHexString:hex] colorWithAlphaComponent:self.tagAlpha];
                
                CGContextSetFillColorWithColor(context, color.CGColor);
                CGContextFillRect(context, CGRectMake(x, i * tagHeight, 1, tagHeight));
                i++;
            }
            
        }
        
        // only draw selection if we need to
        if (shouldDisplaySelectedTime) {
            
            // create selection rect
            CGFloat selectionX = pixelWidth * selectedTime / duration - self.tagWidth / 2.0;
            CGRect selectionRect = CGRectMake(selectionX, 0, self.tagWidth, rect.size.height);
            
            // draw selection
            CGContextSetFillColorWithColor(context, self.selectionFillColor.CGColor);
            CGContextFillRect(context, selectionRect);
            
            CGContextSetStrokeColorWithColor(context, self.selectionStrokeColor.CGColor);
            CGContextStrokeRectWithWidth(context, selectionRect, self.selectionStrokeWidth);
        }
        
    }
    
}

@end
