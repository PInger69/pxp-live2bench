//
//  PxpTagDisplayBar.m
//  TagRenderer
//
//  Created by Nico Cvitak on 2015-05-08.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTagDisplayBar.h"
#include <vector>
#include <set>

struct rgbaColor {
    uint8_t r, g, b, a;
};

inline bool operator<(const rgbaColor& l, const rgbaColor& r)
{
    return memcmp(&l, &r, sizeof(rgbaColor)) < 0;
}

@interface PxpTagDisplayBar ()

@property (readonly, strong, nonatomic, nonnull) UIColor *selectionStrokeColor;
@property (readonly, strong, nonatomic, nonnull) UIColor *selectionFillColor;

@end

@implementation PxpTagDisplayBar

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
        NSArray *tags = [self.dataSource tagsInPxpTagDisplayBar:self];
        NSTimeInterval duration = [self.dataSource durationInPxpTagDisplayBar:self];
        NSTimeInterval selectedTime = [self.dataSource selectedTimeInPxpTagDisplayBar:self];
        BOOL shouldDisplaySelectedTime = [self.dataSource shouldDisplaySelectedTimeInPxpTagDisplayBar:self];
        
        // set up draw info.
        std::vector<std::set<rgbaColor>> drawInfo = std::vector<std::set<rgbaColor>>(pixelWidth);
        
        // populate draw info
        for (Tag *tag in tags) {
            // calculate tag dimensions
            NSInteger tagX = pixelWidth * (tag.time) / duration - self.tagWidth / 2.0;
            
            // default tag color (black).
            rgbaColor c = { 0, 0, 0, 255};
            
            // get color string.
            const char *s = tag.colour.UTF8String;
            
            // attempt to parse string to color.
            if (s) {
                sscanf(s, "%02hhx%02hhx%02hhx%02hhx", &c.r, &c.g, &c.b, &c.a);
            };
            
            // update the draw info.
            for (NSInteger i = 0; i < self.tagWidth; i++) {
                // only insert tag if it will fit in the frame
                const NSInteger x = tagX + i;
                if (0 <= x && x < pixelWidth) {
                    // add color to set
                    drawInfo[x].insert(c);
                }
            }
            
        }
        
        // draw tags
        for (NSUInteger x = 0; x < pixelWidth; x++) {
            const std::set<rgbaColor> &color_comps = drawInfo[x];
            if (color_comps.size()) {
                CGFloat tagHeight = ceil(rect.size.height / color_comps.size());
                
                
                NSUInteger i = 0;
                for (std::set<rgbaColor>::iterator it = color_comps.begin(); it != color_comps.end(); it++) {
                    CGContextSetRGBFillColor(context, it->r / 255.0, it->g / 255.0, it->b / 255.0, it->a / 255.0);
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
