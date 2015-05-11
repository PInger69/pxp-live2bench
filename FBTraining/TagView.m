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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set defaults
        self.dataSource = nil;
        self.tagAlpha = 1.0;
        self.tagWidth = 5.0;
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
        
        // set up draw info
        NSMutableArray *drawInfo = [NSMutableArray arrayWithCapacity:pixelWidth];
        for (NSUInteger x = 0; x < pixelWidth; x++) {
            [drawInfo insertObject:[NSMutableSet set] atIndex:x];
        }
        
        // populate draw info
        for (Tag *tag in tags) {
            // calculate tag dimensions
            NSUInteger tagX = pixelWidth * (tag.time) / duration - self.tagWidth / 2.0;
            NSUInteger tagWidth = self.tagWidth;
            
            for (NSUInteger i = 0; i < tagWidth; i++) {
                // only insert tag if it will fit in the frame
                if (tagX + i < pixelWidth) {
                    
                    // we only need to store the color information
                    NSMutableSet *colorSet = drawInfo[tagX + i];
                    
                    // add color to set
                    [colorSet addObject:tag.colour];
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
                CGFloat tagColor[4] = { [3] = self.tagAlpha };
                [[Utility colorWithHexString:hex] getRed:&tagColor[0] green:&tagColor[1] blue:&tagColor[2] alpha:nil];
                UIColor *color = [UIColor colorWithRed:tagColor[0] green:tagColor[1] blue:tagColor[2] alpha:tagColor[3]];
                
                CGContextSetFillColorWithColor(context, color.CGColor);
                CGContextFillRect(context, CGRectMake(x, i * tagHeight, 1, tagHeight));
                i++;
            }
            
        }
        
    }
    
}


@end
