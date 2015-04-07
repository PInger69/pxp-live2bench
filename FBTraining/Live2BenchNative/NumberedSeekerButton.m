//
//  NumberedSeekerButton.m
//  QuickTest
//
//  Created by dev on 6/19/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "NumberedSeekerButton.h"
#define LITTLE_ICON_DIMENSIONS      30 //the image is really 33x36
#define LARGE_ICON_DIMENSIONS       50 // this image is really 46x51
#define NORMAL                      @"normal"
#define LARGE                       @"large"

static UIImage *circleArrowNorm;
static UIImage *circleArrowLarge;
static NSDictionary    *fonrSizeDict;
static UIColor * normalColor;
static UIColor * selectedColor;



@implementation NumberedSeekerButton
{
    UILabel *numberLabel;
    UIImage *circleArrow;
    NSString *iconType;
    NSArray *fontSizes;
}

/**
 *  Builds all static content when needed
 */
+(void)staticInit
{

    circleArrowNorm         = [[UIImage imageNamed: @"seek.png"]    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleArrowLarge        = [[UIImage imageNamed: @"seeklarge.png"]    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    normalColor             = [UIColor colorWithRed:247/255.f green:148/255.f blue:29/255.f alpha:1]; ;
    selectedColor           = [UIColor colorWithRed:247/255.f*.5 green:148/255.f*.5 blue:29/255.f*.5 alpha:1];
    fonrSizeDict            = @{
                         NORMAL:@[
                                 [NSNumber numberWithFloat:14.00f],
                                 [NSNumber numberWithFloat:19.00f],
                                 [NSNumber numberWithFloat:17.00f]
                                 ],
                         LARGE:@[
                                 [NSNumber numberWithFloat:22.0f],
                                 [NSNumber numberWithFloat:35.0f],
                                 [NSNumber numberWithFloat:26.0f]
                                 ]
                         };
}


-(id)initForwardLargeWithFrame:(CGRect)frame
{
    CGRect nframe = CGRectMake(frame.origin.x,frame.origin.y,LARGE_ICON_DIMENSIONS,LARGE_ICON_DIMENSIONS);
    self = [super initWithFrame:nframe];
    if (self) {
        iconType = LARGE;
        circleArrow = circleArrowLarge;
        [self setupGraphics];
    }
    return self;
}

-(id)initBackwardLargeWithFrame:(CGRect)frame
{
    CGRect nframe = CGRectMake(frame.origin.x,frame.origin.y,LARGE_ICON_DIMENSIONS,LARGE_ICON_DIMENSIONS);
    self = [super initWithFrame:nframe];
    if (self) {
        iconType = LARGE;
        circleArrow = circleArrowLarge;
        [self setupGraphics];
        self.transform = CGAffineTransformMakeScale(-1, 1); 
        numberLabel.transform = CGAffineTransformMakeScale(-1, 1); 
    }
    return self;
}


-(id)initForwardNormalWithFrame:(CGRect)frame
{
    CGRect nframe = CGRectMake(frame.origin.x,frame.origin.y,LITTLE_ICON_DIMENSIONS,LITTLE_ICON_DIMENSIONS);
    self = [super initWithFrame:nframe];
    if (self) {
        iconType = NORMAL;
        circleArrow = circleArrowNorm;
        [self setupGraphics];
    }
    return self;
}

-(id)initBackwardNormalWithFrame:(CGRect)frame
{
    CGRect nframe = CGRectMake(frame.origin.x,frame.origin.y,LITTLE_ICON_DIMENSIONS,LITTLE_ICON_DIMENSIONS);
    self = [super initWithFrame:nframe];
    if (self) {
        iconType = NORMAL;
        circleArrow = circleArrowNorm;
        [self setupGraphics];
        self.transform = CGAffineTransformMakeScale(-1, 1); 
        numberLabel.transform = CGAffineTransformMakeScale(-1, 1); 
    }
    return self;
}





-(void)setupGraphics
{
    // Initialization code
    if (!circleArrowNorm) [NumberedSeekerButton staticInit];
    fontSizes = fonrSizeDict[iconType];
    
    [self setImage:circleArrowLarge forState:UIControlStateNormal];
    numberLabel                 = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.frame.size.width,self.frame.size.height)];
    numberLabel.text            = @"X";
    numberLabel.textColor       = self.tintColor;//normalColor
    numberLabel.textAlignment   = NSTextAlignmentCenter;
    numberLabel.font            = [UIFont fontWithName:numberLabel.font.fontName size:[fontSizes[1]floatValue]];
    [self addSubview:numberLabel];
    
}


/**
 *  This method is part of the UIbutton class and it run when ever the buttond becomes selected
 *
 *  @param highlighted
 */
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted){
         numberLabel.textColor = selectedColor;
    } else {
         numberLabel.textColor = normalColor;
    }
}




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGraphics];
    }
    return self;
}

/**
 *  Enter in a float number to be showen in the center of the icon.
 *  Reccomended range .01 to 999.49. If you go passed these ranges you will see  .00 or  1...
 *
 *  @param num nubmer to be displayed
 */
-(void)setTextNumber:(float)num
{
    NSString * txtNum;
    float fntSize;
    
    if (num < .25){
        txtNum = [NSString stringWithFormat:@"%.02f",num];
        txtNum = @"F";
        fntSize = [fontSizes[1]floatValue];
    } else if (num < 1){
        txtNum = [NSString stringWithFormat:@"%.02f",num];
        txtNum = [txtNum substringFromIndex:1];
        fntSize = [fontSizes[0]floatValue];
    } else if (num >= 1 && num <= 9) {
        txtNum = [NSString stringWithFormat:@"%.f",num];
        fntSize = [fontSizes[1]floatValue];
    } else {
        txtNum = [NSString stringWithFormat:@"%.f",num];
        fntSize = [fontSizes[2]floatValue];
    }

    numberLabel.font = [UIFont fontWithName:numberLabel.font.fontName size:fntSize];
    numberLabel.text = txtNum;
}

-(void)tintColorDidChange
{
    [super tintColorDidChange];
    numberLabel.textColor = self.tintColor;
}

@end
