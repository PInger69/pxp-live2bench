//
//  RatingOutput.m
//  Live2BenchNative
//
//  Created by dev on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import "RatingOutput.h"
#define DISABLE_ALPHA 0.5f


@implementation RatingOutput
{
    
}

static int STAR_SIZE = 20;
static UIImage* rateSelected;
@synthesize rating = _rating;




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
            UIImage *image = [self starImage:YES];
            rateSelected = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            starArray = [NSMutableArray arrayWithCapacity:5];
        
            for(int i = 0;i<5;i++) {
                    
                
                UIImageView * star = [[ UIImageView alloc] initWithFrame:CGRectMake(110 + 40*i, 3, STAR_SIZE, STAR_SIZE)];
                [star setBackgroundColor:[UIColor blackColor]];
                [star setImage: rateSelected];
                [star setContentMode:UIViewContentModeScaleAspectFit];
                [star setHidden:true];
                [self addSubview:star];
                [starArray addObject:star];

                
            }
        }
    
    return self;
}


- (void) setRating:(int)rate{
    if( rate >= 0 && rate <=5)
    {
        _rating = rate;
    }

    for( int i=0; i < _rating; i++)
    {
        [starArray[i] setHidden:false];
    }
    
}

- (int) getRating{
    return _rating;
}



-(UIImage *) starImage: (BOOL) selected{
    CGSize imageSize = CGSizeMake(100 /2, 100/2);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *starPath = [UIBezierPath bezierPath];
    UIBezierPath *outLinePath = [UIBezierPath bezierPath];
    
    [starPath moveToPoint: CGPointMake(17.5/2, 100/2)]; // bottom left
    [starPath addLineToPoint: CGPointMake(50/2, 0)];  // top
    [starPath addLineToPoint: CGPointMake((50 + 32.5)/2, 100/2)]; // bottom right
    [starPath addLineToPoint: CGPointMake(0, 38.2/2)]; //left
    [starPath addLineToPoint: CGPointMake(100/2, 38.2/2)]; //right
    [starPath addLineToPoint: CGPointMake(17.5/2, 100/2)]; // bottom left
    
    
    [outLinePath moveToPoint: CGPointMake(17.5/2, 100/2)];
    [outLinePath addLineToPoint: CGPointMake(50/2, (100 -23.61)/2 )];
    [outLinePath addLineToPoint: CGPointMake((50 + 32.5)/2, 100/2)];
    [outLinePath addLineToPoint: CGPointMake(70/2, 61.8/2)];
    [outLinePath addLineToPoint: CGPointMake(100/2, 38.2/2)];
    [outLinePath addLineToPoint: CGPointMake(0, 38.2/2)];
    [outLinePath addLineToPoint: CGPointMake((50 + 32.5)/2, 100/2)];
    [outLinePath addLineToPoint: CGPointMake(50/2, 0)];
    [outLinePath addLineToPoint: CGPointMake(17.5/2, 100/2)]; // bottom left
    
    
    if (selected) {
        [PRIMARY_APP_COLOR setFill];
        [PRIMARY_APP_COLOR setStroke];
    }else{
        [[UIColor lightGrayColor] setFill];
        [[UIColor lightGrayColor] setStroke];
    }
    
    
    
    outLinePath.lineWidth = 5.0;
    [outLinePath stroke];
    [starPath fill];
    
    UIImage *starImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return starImage;
}



@end


