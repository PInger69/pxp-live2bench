//
//  RatingOutput.m
//  Live2BenchNative
//
//  Created by dev on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import "RatingOutput.h"
#define DISABLE_ALPHA 0.5f

@interface RatingOutput()

@property (nonatomic, strong, nonnull) NSArray* starArray;

@end

@implementation RatingOutput

static int STAR_SIZE = 13;
@synthesize rating = _rating;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage* image = [[self starImage:YES] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        NSMutableArray* temp = [NSMutableArray arrayWithCapacity:5];
    
        for (int i = 0; i<5; i++) {
            UIImageView * star = [[ UIImageView alloc] initWithFrame:CGRectMake(110 + 25*i, 3, STAR_SIZE, STAR_SIZE)];
            [star setImage: image];
            [star setContentMode:UIViewContentModeScaleAspectFit];
            [star setHidden:YES];
            [self addSubview:star];
            [temp addObject:star];
        }
        self.starArray = [NSArray arrayWithArray:temp];
    }
    
    return self;
}


- (void) setRating:(NSInteger) rating {
    if (rating >= 0 && rating <=5) {
        _rating = rating;
    } else if (rating > 0) {
        _rating = 5;
    }

    for( NSInteger i=0; i < 5; i++) {
        ((UIImageView*) self.starArray[i]).hidden = (i >= _rating);
    }
}

- (NSInteger) getRating{
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
    } else {
        [[UIColor lightGrayColor] setFill];
    }
    
    [starPath fill];
    
    UIImage *starImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return starImage;
}

@end


