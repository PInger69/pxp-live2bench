//
//  TagView.m
//  TagRenderer
//
//  Created by Nico Cvitak on 2015-05-08.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import "TagView.h"
#include <vector>
#include <set>

struct color_comp {
    CGFloat r, g, b, a;
};

inline bool operator<(const color_comp& l, const color_comp& r)
{
    return memcmp(&l, &r, sizeof(color_comp)) < 0;
}

@interface TagView ()

@property (readonly, strong, nonatomic, nonnull) UIColor *selectionStrokeColor;
@property (readonly, strong, nonatomic, nonnull) UIColor *selectionFillColor;

@end

@implementation TagView

@synthesize dataSource = _dataSource;
@synthesize tagAlpha = _tagAlpha;
@synthesize tagWidth = _tagWidth;
@synthesize selectionStrokeWidth = _selectionStrokeWidth;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set defaults
        
        self.dataSource = nil;
        self.tagAlpha = 1.0;
        self.tagWidth = 5.0;
        self.selectionStrokeWidth = 2.0;
    }
    return self;
}

- (nonnull UIColor *)selectionStrokeColor {
    return self.tintColor ? self.tintColor : [UIColor clearColor];
}

- (nonnull UIColor *)selectionFillColor {
    return [self.selectionStrokeColor colorWithAlphaComponent:0.5];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsDisplay];
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
        const NSUInteger pixelWidth = rect.size.width;
        
        // obtain data source information
        NSArray *tags = [self.dataSource tagsInTagView:self];
        NSTimeInterval duration = [self.dataSource durationInTagView:self];
        NSTimeInterval selectedTime = [self.dataSource selectedTimeInTagView:self];
        BOOL shouldDisplaySelectedTime = [self.dataSource shouldDisplaySelectedTimeInTagView:self];
        
        // set up draw info.
        std::vector<std::set<color_comp>> drawInfo = std::vector<std::set<color_comp>>(pixelWidth);
        
        // populate draw info
        for (Tag *tag in tags) {
            // calculate tag dimensions
            NSInteger tagX = pixelWidth * (tag.time) / duration - self.tagWidth / 2.0;
            
            for (NSInteger i = 0; i < self.tagWidth; i++) {
                
                // only insert tag if it will fit in the frame
                NSInteger x = tagX + i;
                if (0 <= x && x < pixelWidth) {
                    // add color to set
                    
                    color_comp c = { 0.0, 0.0, 0.0, 1.0};
                    
                    const char *s = tag.colour.UTF8String;
                    uint8_t r, g, b;
                    if (s && sscanf(s, "%02hhx%02hhx%02hhx", &r, &g, &b) == 3) {
                        c.r = r / 255.0;
                        c.g = g / 255.0;
                        c.b = b / 255.0;
                    };
                    drawInfo[x].insert(c);
                }
            }
            
        }
        
        // draw tags
        for (NSUInteger x = 0; x < pixelWidth; x++) {
            const std::set<color_comp> &color_comps = drawInfo[x];
            if (color_comps.size()) {
                CGFloat tagHeight = ceil(rect.size.height / color_comps.size());
                
                
                NSUInteger i = 0;
                for (std::set<color_comp>::iterator it = color_comps.begin(); it != color_comps.end(); it++) {
                    CGContextSetRGBFillColor(context, it->r, it->g, it->b, it->a);
                    CGContextFillRect(context, CGRectMake(x, i * tagHeight, 1, tagHeight));
                    i++;
                }
            }
        }
        
        // only draw selection if we need to
        if (shouldDisplaySelectedTime) {
            
            // create selection rect
            CGFloat selectionX = pixelWidth * selectedTime / duration - self.tagWidth / 2.0;
            
            // adjust the position of the selection rect so that it will not be cut off
            if(selectionX + self.tagWidth > pixelWidth - 1)selectionX = pixelWidth - self.tagWidth - 1;
            if(selectionX < 1)selectionX = 1;
            
            CGRect selectionRect = CGRectMake(selectionX, 0, self.tagWidth, rect.size.height);
            
            // draw selection
            CGContextSetFillColorWithColor(context, self.selectionFillColor.CGColor);
            CGContextFillRect(context, selectionRect);
            
            CGContextSetStrokeColorWithColor(context, self.selectionStrokeColor.CGColor);
            CGContextStrokeRectWithWidth(context, selectionRect, self.selectionStrokeWidth);
        }
        
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, self.selectionStrokeColor.CGColor);
        
        CGContextSetLineWidth(context, 2.0);
        CGContextMoveToPoint(context, 0.0, 0.0);
        CGContextAddLineToPoint(context, 0.0, rect.size.height);
        CGContextMoveToPoint(context, rect.size.width, 0.0);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
        CGContextDrawPath(context, kCGPathStroke);
        
        CGContextRestoreGState(context);
        
    }
    
}

@end
